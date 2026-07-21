resource "aws_sqs_queue" "saeb_report_jobs_queue" {
    name         = var.SQS_QUEUE_NAME
    delay_seconds             = 90
    max_message_size          = 2048
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10
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