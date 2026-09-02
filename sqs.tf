resource "aws_sqs_queue" "saeb_report_jobs_queue" {
  name                       = var.SQS_QUEUE_NAME
  delay_seconds              = 0
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 60
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.saeb_report_jobs_deadletter_queue.arn
    maxReceiveCount     = 4
  })

  tags = local.common_tags
}

resource "aws_sqs_queue" "saeb_report_jobs_deadletter_queue" {
  name = var.SQS_DEADLETTER_QUEUE_NAME
  tags = local.common_tags
}

resource "aws_lambda_event_source_mapping" "saeb_report_jobs_queue_invoke_generate_report" {
  event_source_arn = aws_sqs_queue.saeb_report_jobs_queue.arn
  function_name    = aws_lambda_function.generate_report.arn
  batch_size       = 1

  scaling_config {
    maximum_concurrency = 100
  }

  depends_on = [
    aws_iam_role_policy.lambda_sqs,
  ]
}
