# Route 53 Hosted Zone
resource "aws_route53_zone" "ads_zone" {
  name = "dataiesb.com"
}

# Data source to get the current ALB created by ingress
data "aws_lb" "ide_alb" {
  name = "k8s-adssyste-ideingre-8b99b3b39c"
}

# A record pointing to ALB
resource "aws_route53_record" "ads_record" {
  zone_id = aws_route53_zone.ads_zone.zone_id
  name    = "ads.dataiesb.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.ide_alb.dns_name
    zone_id                = data.aws_lb.ide_alb.zone_id
    evaluate_target_health = true
  }
}

# Outputs
output "nameservers" {
  value = aws_route53_zone.ads_zone.name_servers
}
