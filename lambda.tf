resource "aws_lambda_function" "manage_report_questions" {
  function_name = "manage-report-questions"

  filename         = local.lambda_build_path.lambda_placeholder
  source_code_hash = filebase64sha256(local.lambda_build_path.lambda_placeholder)

  role = aws_iam_role.saeb_lambda_role.arn

  handler = "main.handler"
  runtime = "python3.12"
  timeout = 30

  environment {
    variables = {
      DYNAMO_QUESTIONS_TABLE     = var.DYNAMO_QUESTIONS_TABLE
      DYNAMO_INTERVENTIONS_TABLE = var.DYNAMO_INTERVENTIONS_TABLE
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }

  tags = local.common_tags
}

resource "aws_lambda_function" "generate_presigned_url" {
  function_name = "generate-presigned-url"

  filename         = local.lambda_build_path.lambda_placeholder
  source_code_hash = filebase64sha256(local.lambda_build_path.lambda_placeholder)

  role = aws_iam_role.saeb_lambda_role.arn

  handler = "main.handler"
  runtime = "python3.12"
  timeout = 30

  environment {
    variables = {
      S3_ASSETS_BUCKET_NAME = var.S3_ASSETS_BUCKET_NAME
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }

  tags = local.common_tags
}

resource "aws_lambda_function" "generate_report" {
  function_name = "generate-report"

  filename         = local.lambda_build_path.lambda_placeholder
  source_code_hash = filebase64sha256(local.lambda_build_path.lambda_placeholder)

  role = aws_iam_role.saeb_lambda_role.arn

  handler = "main.handler"
  runtime = "python3.12"
  timeout = 30

  environment {
    variables = {
      S3_OUTPUT_BUCKET_NAME = var.S3_OUTPUT_BUCKET_NAME
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }

  tags = local.common_tags
}