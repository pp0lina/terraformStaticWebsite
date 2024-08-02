# outputs.tf
output "s3_bucket_website_url" {
  description = "The URL of the S3 static website"
  value       = "http://${aws_s3_bucket.website_bucket.bucket}.s3-website.${var.region}.amazonaws.com"
}

output "website_url" {
  description = "The URL of the website"
  value       = "domain_name_simple"
}
