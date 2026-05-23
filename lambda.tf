resource "aws_lambda_function" "manage_report_questions" {
  function_name = "manage-report-questions"

  filename         = local.lambda_build_path.manage_report_questions
  source_code_hash = filebase64sha256(local.lambda_build_path.manage_report_questions)

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