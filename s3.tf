resource "aws_s3_bucket" "saeb_bucket" {
  bucket = var.S3_BUCKET_NAME
  tags = local.common_tags
}

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "saeb-lambda-artifacts"
  tags = local.common_tags
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_artifacts.id

  key    = "manage-report-questions.zip"
  source = local.lambda_build_path.manage_report_questions

  etag = filemd5(local.lambda_build_path.manage_report_questions)
}