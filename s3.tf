# S3 Bucket for hosting static website files
resource "aws_s3_bucket" "website_bucket" {
  bucket        = "ekaterina-nutritionist.com"
  acl    = "public-read"
  policy = data.aws_iam_policy_document.allow_public_read.json

    cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://${var.domain_name}"]
    max_age_seconds = 3000
  }

  website {
    index_document = "index.html"
  }
}

# Block public access to the S3 bucket at the account level
#resource "aws_s3_bucket_public_access_block" "website_bucket" {
#  bucket                  = aws_s3_bucket.website_bucket.id
#  block_public_acls       = false
#  block_public_policy     = false
#  ignore_public_acls      = false
#  restrict_public_buckets = false
#}

# Upload website files to the S3 bucket
resource "aws_s3_object" "provision_source_files" {
    bucket  = aws_s3_bucket.website_bucket.id

    for_each = fileset("web-files/", "**/*.*")

    key    = each.value
    source = "web-files/${each.value}"
}

# IAM policy document for CloudFront access to S3
data "aws_iam_policy_document" "allow_public_read" {
  statement {
    sid    = "PublicReadGetObject"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    principals {
      type        = "AWS"
      identifiers = "*"
    }

    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]
  }
}
