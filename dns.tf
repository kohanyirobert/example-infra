data "aws_route53_zone" "main" {
  name = "${subdomain}${domain}"
}

resource "aws_route53_record" "web" {
  zone_id = data.aws_route53_zone.main.id
  name    = "web.${data.aws_route53_zone.main.name}"
  type    = "A"
  alias {
    name                   = aws_lb.web.dns_name
    zone_id                = aws_lb.web.zone_id
    evaluate_target_health = true
  }
}
