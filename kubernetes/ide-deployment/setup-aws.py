#!/usr/bin/env python3
"""Auto-discover ALBs from k8s ingresses and configure Route53 + WAF."""

import json
import subprocess
import time
import boto3

NAMESPACE = "ads-system"
REGION = "us-east-1"
DOMAINS = ["ads.dataiesb.com", "bayarea.dataiesb.com"]
ZONE_DOMAIN = "dataiesb.com"

r53 = boto3.client("route53", region_name=REGION)
waf = boto3.client("wafv2", region_name=REGION)
elbv2 = boto3.client("elbv2", region_name=REGION)


def get_hosted_zone_id():
    zones = r53.list_hosted_zones_by_name(DNSName=ZONE_DOMAIN, MaxItems="1")
    for z in zones["HostedZones"]:
        if z["Name"].rstrip(".") == ZONE_DOMAIN:
            return z["Id"].split("/")[-1]
    raise RuntimeError(f"Hosted zone for {ZONE_DOMAIN} not found")


def get_ingress_albs():
    """Map domain -> ALB DNS from k8s ingress status, wait for ALBs."""
    for attempt in range(12):
        result = subprocess.run(
            ["kubectl", "get", "ingress", "-n", NAMESPACE, "-o", "json"],
            capture_output=True, text=True, check=True,
        )
        ingresses = json.loads(result.stdout)["items"]
        mapping = {}
        for ing in ingresses:
            host = ing["spec"]["rules"][0].get("host", "")
            lbs = ing.get("status", {}).get("loadBalancer", {}).get("ingress", [])
            if host and lbs:
                mapping[host] = lbs[0]["hostname"]
        missing = [d for d in DOMAINS if d not in mapping]
        if not missing:
            return mapping
        print(f"  Waiting for ALBs: {', '.join(missing)} (attempt {attempt+1}/12)")
        time.sleep(10)
    return mapping


def get_alb_arn(dns_name):
    lbs = elbv2.describe_load_balancers()["LoadBalancers"]
    for lb in lbs:
        if lb["DNSName"] == dns_name:
            return lb["LoadBalancerArn"]
    raise RuntimeError(f"ALB not found for {dns_name}")


def get_alb_hosted_zone(dns_name):
    lbs = elbv2.describe_load_balancers()["LoadBalancers"]
    for lb in lbs:
        if lb["DNSName"] == dns_name:
            return lb["CanonicalHostedZoneId"]
    raise RuntimeError(f"ALB not found for {dns_name}")


def upsert_route53(zone_id, domain, alb_dns):
    alb_zone = get_alb_hosted_zone(alb_dns)
    r53.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={
            "Changes": [{
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": domain,
                    "Type": "A",
                    "AliasTarget": {
                        "HostedZoneId": alb_zone,
                        "DNSName": f"dualstack.{alb_dns}",
                        "EvaluateTargetHealth": True,
                    },
                },
            }],
        },
    )
    print(f"  Route53: {domain} -> {alb_dns}")


def get_or_create_waf_acl():
    name = "ads-system-waf"
    # Check existing
    acls = waf.list_web_acls(Scope="REGIONAL")["WebACLs"]
    for acl in acls:
        if acl["Name"] == name:
            print(f"  WAF ACL '{name}' already exists")
            return acl["ARN"]

    resp = waf.create_web_acl(
        Name=name,
        Scope="REGIONAL",
        DefaultAction={"Allow": {}},
        VisibilityConfig={
            "SampledRequestsEnabled": True,
            "CloudWatchMetricsEnabled": True,
            "MetricName": "ads-system-waf",
        },
        Rules=[
            {
                "Name": "RateLimit",
                "Priority": 1,
                "Action": {"Block": {}},
                "Statement": {"RateBasedStatement": {"Limit": 1000, "AggregateKeyType": "IP"}},
                "VisibilityConfig": {
                    "SampledRequestsEnabled": True,
                    "CloudWatchMetricsEnabled": True,
                    "MetricName": "RateLimit",
                },
            },
            {
                "Name": "AWSManagedCommonRules",
                "Priority": 2,
                "OverrideAction": {"None": {}},
                "Statement": {
                    "ManagedRuleGroupStatement": {
                        "VendorName": "AWS",
                        "Name": "AWSManagedRulesCommonRuleSet",
                    }
                },
                "VisibilityConfig": {
                    "SampledRequestsEnabled": True,
                    "CloudWatchMetricsEnabled": True,
                    "MetricName": "AWSManagedCommonRules",
                },
            },
            {
                "Name": "AWSManagedSQLiRules",
                "Priority": 3,
                "OverrideAction": {"None": {}},
                "Statement": {
                    "ManagedRuleGroupStatement": {
                        "VendorName": "AWS",
                        "Name": "AWSManagedRulesSQLiRuleSet",
                    }
                },
                "VisibilityConfig": {
                    "SampledRequestsEnabled": True,
                    "CloudWatchMetricsEnabled": True,
                    "MetricName": "AWSManagedSQLiRules",
                },
            },
        ],
    )
    print(f"  WAF ACL '{name}' created")
    return resp["Summary"]["ARN"]


def associate_waf(waf_arn, alb_arn):
    for attempt in range(5):
        try:
            waf.associate_web_acl(WebACLArn=waf_arn, ResourceArn=alb_arn)
            print(f"  WAF associated with {alb_arn.split('/')[-1]}")
            return
        except waf.exceptions.WAFInvalidParameterException:
            print(f"  WAF already associated with {alb_arn.split('/')[-1]}")
            return
        except waf.exceptions.WAFUnavailableEntityException:
            print(f"  WAF not ready, retrying ({attempt+1}/5)...")
            time.sleep(5)


def main():
    print("Discovering hosted zone...")
    zone_id = get_hosted_zone_id()
    print(f"  Zone: {zone_id}")

    print("Discovering ALBs from ingresses...")
    alb_map = get_ingress_albs()
    for d in DOMAINS:
        if d not in alb_map:
            print(f"  WARNING: {d} ingress not ready yet, skipping")

    print("Configuring Route53...")
    for domain, alb_dns in alb_map.items():
        if domain in DOMAINS:
            upsert_route53(zone_id, domain, alb_dns)

    print("Configuring WAF...")
    waf_arn = get_or_create_waf_acl()
    for domain, alb_dns in alb_map.items():
        if domain == "ads.dataiesb.com":
            alb_arn = get_alb_arn(alb_dns)
            associate_waf(waf_arn, alb_arn)

    print("Done!")


if __name__ == "__main__":
    main()
