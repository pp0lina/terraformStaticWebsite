# outputs.tf
output "s3_bucket_website_url" {
  description = "The URL of the S3 static website"
  value       = aws_s3_bucket.static_website.website_endpoint
}
