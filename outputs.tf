# outputs.tf
output "s3_bucket_website_url" {
  description = "The URL of the S3 static website"
  value       = "http://${aws_s3_bucket.website_bucket.bucket}.s3-website.${var.region}.amazonaws.com"
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn_static_site.domain_name
}
