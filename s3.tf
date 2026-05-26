resource "aws_s3_bucket" "saeb_bucket" {
  bucket = var.S3_OUTPUT_BUCKET_NAME
  tags = local.common_tags
}

resource "aws_s3_bucket" "saeb_report_assets" {
  bucket = var.S3_ASSETS_BUCKET_NAME
  tags = local.common_tags
}

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "saeb-lambda-artifacts"
  tags = local.common_tags
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_artifacts_lifecycle" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  rule {
    id     = "delete-old-artifacts"
    status = "Enabled"
    filter {}

    expiration {
      days = 60
    }
  }
}