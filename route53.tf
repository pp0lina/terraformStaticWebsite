# Route 53 hosted zone for the domain
data "aws_route53_zone" "zone" {
  provider     = aws.use_default_region
  name         = var.domain_name_simple
  private_zone = false
}

# Route 53 record for www subdomain
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "www.${var.domain_name_simple}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn_static_site.domain_name
    zone_id                = aws_cloudfront_distribution.cdn_static_site.hosted_zone_id
    evaluate_target_health = false
  }
}

# Route 53 record for the root domain
resource "aws_route53_record" "apex" {
  name    = var.domain_name_simple
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.cdn_static_site.domain_name
    zone_id                = aws_cloudfront_distribution.cdn_static_site.hosted_zone_id
  }
}

# DNS validation records for ACM certificate
resource "aws_route53_record" "cert_validation" {
  provider = aws.use_default_region
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
  ttl             = 60
}