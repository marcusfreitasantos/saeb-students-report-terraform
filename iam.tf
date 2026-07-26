resource "aws_iam_role" "saeb_lambda_role" {
  name = "saeb-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.saeb_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "lambda-dynamodb-policy"

  role = aws_iam_role.saeb_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]

        Resource = [
          aws_dynamodb_table.saeb_questions.arn,
          aws_dynamodb_table.saeb_interventions.arn,
          aws_dynamodb_table.saeb_reports.arn,
          "${aws_dynamodb_table.saeb_reports.arn}/index/GetByFilekey"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_s3" {
  name = "lambda-s3-policy"

  role = aws_iam_role.saeb_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]

        Resource = [
          "${aws_s3_bucket.saeb_report_assets.arn}/*",
          "${aws_s3_bucket.saeb_output_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_sqs" {
  name = "lambda-sqs-policy"

  role = aws_iam_role.saeb_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:ChangeMessageVisibility",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]

        Resource = [
          aws_sqs_queue.saeb_report_jobs_queue.arn
        ]
      }
    ]
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "saeb_report_jobs_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.saeb_report_jobs_deadletter_queue.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.saeb_report_jobs_queue.arn]
  })
}