resource "aws_s3_bucket" "saeb_bucket" {
  bucket = var.S3_BUCKET_NAME
  tags = local.common_tags
}

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "saeb-lambda-artifacts"
  tags = local.common_tags
}