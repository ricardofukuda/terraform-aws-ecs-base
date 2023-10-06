resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}