# Use existing hosted zone (the original one by ID)
data "aws_route53_zone" "dataiesb_zone" {
  zone_id = "Z05014761ROYBA3Z5YKY2"
}

# Data source to get the current ALB created by ingress
data "aws_lb" "ide_alb" {
  name = "k8s-adssyste-ideingre-8b99b3b39c"
}

# A record pointing to ALB
resource "aws_route53_record" "ads_record" {
  zone_id = data.aws_route53_zone.dataiesb_zone.zone_id
  name    = "ads.dataiesb.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.ide_alb.dns_name
    zone_id                = data.aws_lb.ide_alb.zone_id
    evaluate_target_health = true
  }
}
