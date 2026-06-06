resource "aws_s3_bucket" "saeb_output_bucket" {
  bucket = var.S3_OUTPUT_BUCKET_NAME
  tags   = local.common_tags
}

resource "aws_s3_bucket" "saeb_report_assets" {
  bucket = var.S3_INPUT_BUCKET_NAME
  tags   = local.common_tags
}

resource "aws_lambda_permission" "saeb_report_assets_s3_invoke_generate_report" {
  statement_id  = "AllowS3InvokeGenerateReport"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.generate_report.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.saeb_report_assets.arn
}

resource "aws_s3_bucket_notification" "saeb_report_assets" {
  bucket = aws_s3_bucket.saeb_report_assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.generate_report.arn
    events              = ["s3:ObjectCreated:*"]

    filter_prefix = "input-files/"
  }

  depends_on = [
    aws_lambda_permission.saeb_report_assets_s3_invoke_generate_report,
  ]
}

resource "aws_s3_bucket_cors_configuration" "saeb_report_assets_cors" {
  bucket = aws_s3_bucket.saeb_report_assets.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "lambda_artifacts" {
  bucket = "saeb-lambda-artifacts"
  tags   = local.common_tags
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
