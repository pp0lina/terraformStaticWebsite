# Resources Block

# S3 Bucket for hosting static website files
resource "aws_s3_bucket" "website_bucket" {
  bucket = "nutritionist-website-bucket-11co11v"
}

# Block public access to the S3 bucket
resource "aws_s3_account_public_access_block" "website_bucket" {
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# Upload website files to the S3 bucket
resource "aws_s3_object" "provision_source_files" {
    bucket  = aws_s3_bucket.website_bucket.id
    for_each = fileset("web-files/", "**/*.*")

    key    = each.value
    source = "web-files/${each.value}"
}

# Upload the index.html file to the S3 bucket
#resource "aws_s3_object" "website_bucket" {
#  bucket       = aws_s3_bucket.website_bucket.id
#  key          = "index.html"
#  source       = "C:/Users/79122/p/terraform/web-files/templates/index.html"
#  content_type = "text/html"
#}

# Cloudfront for website files distribution
resource "aws_cloudfront_distribution" "cdn_static_site" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "my-s3-origin" 
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my-s3-origin"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

    viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
    
  aliases = [
    var.domain_name_simple,
    var.domain_name
  ]
}

# ACM Certificate for HTTPS
resource "aws_acm_certificate" "cert" {
  provider                  = aws.use_default_region
  domain_name               = "*.${var.domain_name_simple}"
  validation_method         = "DNS"
  subject_alternative_names = [var.domain_name_simple]

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 hosted zone for the domain
data "aws_route53_zone" "zone" {
  provider     = aws.use_default_region
  name         = var.domain_name_simple
  private_zone = false
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

# Validating the ACM certificate
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.use_default_region
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
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

# CloudFront origin access control
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "s3-cloudfront-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Output the CloudFront URL
output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn_static_site.domain_name
}

# IAM policy document for CloudFront access to S3
data "aws_iam_policy_document" "website_bucket" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    condition {
      test     = "StringEquals"
      values   = [aws_cloudfront_distribution.cdn_static_site.arn]
      variable = "aws:SourceArn"
    }
  }
}

# Applying the IAM policy to the S3 bucket
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.website_bucket.json
}

# .
