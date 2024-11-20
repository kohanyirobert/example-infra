data "aws_route53_zone" "main" {
  name = "${subdomain}${domain}"
}

resource "aws_route53_record" "frontend" {
  zone_id = data.aws_route53_zone.main.id
  name    = "frontend.${data.aws_route53_zone.main.name}"
  type    = "A"
  alias {
    name                   = aws_lb.frontend.dns_name
    zone_id                = aws_lb.frontend.zone_id
    evaluate_target_health = true
  }
}
