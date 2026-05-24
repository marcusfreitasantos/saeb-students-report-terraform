
resource "aws_iam_role" "saeb_students_report_deploy_role" {
  name = "saeb-students-report-deploy-role"

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

resource "aws_iam_policy" "saeb_students_report_deploy_policy" {
  name = "saeb-students-report-deploy-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration"
        ]

        Resource = [
          aws_lambda_function.manage_report_questions.arn
        ]
      },
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.lambda_artifacts.arn}/*"
      },
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.lambda_artifacts.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "saeb_students_report_deploy_policy_attachment" {
  role       = aws_iam_role.saeb_students_report_deploy_role.name
  policy_arn = aws_iam_policy.saeb_students_report_deploy_policy.arn
}