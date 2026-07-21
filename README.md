# SAEB Students Report Terraform Architecture

This Terraform project provisions the AWS infrastructure for the SAEB Students Report application.

## Architecture Overview

The architecture is built around serverless AWS services with the following components:

- AWS API Gateway v2 (HTTP API)
- AWS Lambda functions
- AWS DynamoDB tables
- AWS S3 buckets
- AWS SQS queue with dead-letter queue
- AWS CloudWatch Logs
- IAM roles and policies for Lambda and API Gateway

## Services and Resources

### API Gateway

- `aws_apigatewayv2_api.saeb_api`
  - HTTP API endpoint to expose REST routes
  - Routes:
    - `POST /questions/create`
    - `GET /questions/all`
    - `POST /interventions/create`
    - `GET /interventions/all`
    - `POST /report/generate-url`

- `aws_apigatewayv2_stage.default`
  - Auto-deploy enabled
  - Access logs forwarded to CloudWatch Logs

### Lambda Functions

- `aws_lambda_function.manage_report_questions`
  - Handler: `main.handler`
  - Runtime: `python3.12`
  - Environment variables:
    - `DYNAMO_QUESTIONS_TABLE`
    - `DYNAMO_INTERVENTIONS_TABLE`

- `aws_lambda_function.generate_presigned_url`
  - Handler: `main.handler`
  - Runtime: `python3.12`
  - Environment variables:
    - `S3_INPUT_BUCKET_NAME`

- `aws_lambda_function.generate_report`
  - Handler: `main.handler`
  - Runtime: `python3.12`
  - Environment variables:
    - `S3_INPUT_BUCKET_NAME`
    - `S3_OUTPUT_BUCKET_NAME`
    - `DYNAMO_REPORTS_TABLE`

### DynamoDB Tables

- `aws_dynamodb_table.saeb_questions`
  - Primary key: `id`
  - TTL enabled
  - Point-in-time recovery enabled
  - Stream enabled

- `aws_dynamodb_table.saeb_interventions`
  - Primary key: `id`
  - Sort key: `category`
  - Global secondary index: `GetByCategoryAndDescriptor`
  - TTL enabled
  - Point-in-time recovery enabled
  - Stream enabled

- `aws_dynamodb_table.saeb_reports`
  - Primary key: `id`
  - Global secondary index: `GetByFilekey`
  - TTL enabled
  - Point-in-time recovery enabled
  - Stream enabled

### S3 Buckets

- `aws_s3_bucket.saeb_output_bucket`
  - Output storage bucket for generated reports

- `aws_s3_bucket.saeb_report_assets`
  - Input bucket for source files and upload events
  - S3 bucket notification configured to trigger the `generate-report` Lambda when objects are created under `input-files/`
  - CORS policy allows PUT from any origin for attachments

- `aws_s3_bucket.lambda_artifacts`
  - Bucket used for Lambda deployment artifacts
  - Lifecycle rule deletes artifacts older than 60 days

### SQS Queues

- `aws_sqs_queue.saeb_report_jobs_queue`
  - Main queue for report jobs
  - Delay seconds: `90`
  - Max message size: `2048`
  - Message retention: `86400`
  - Receive wait time: `10`
  - Redrive policy to dead-letter queue after `4` receives

- `aws_sqs_queue.saeb_report_jobs_deadletter_queue`
  - Dead-letter queue for failed messages

- `aws_sqs_queue_redrive_allow_policy.saeb_report_jobs_queue_redrive_allow_policy`
  - Allows the dead-letter queue to receive messages from the main queue

### CloudWatch

- `aws_cloudwatch_log_group.api_gateway_logs`
  - Stores API Gateway access logs
  - Retention set to 7 days

### IAM Roles and Policies

- `aws_iam_role.saeb_lambda_role`
  - Lambda service role for all Lambda functions
  - Attached policies:
    - `AWSLambdaBasicExecutionRole`
    - Custom DynamoDB access policy
    - Custom S3 access policy

- `aws_iam_role_policy.lambda_dynamodb`
  - Grants Lambda permission for `PutItem`, `GetItem`, `DeleteItem`, `Query`, `Scan` on the DynamoDB tables and the `GetByFilekey` index

- `aws_iam_role_policy.lambda_s3`
  - Grants Lambda permission for `s3:PutObject` and `s3:GetObject` on both input and output buckets

- `aws_iam_role.saeb_students_report_deploy_role`
  - Deployment role used for updating Lambda code and managing artifacts

- `aws_iam_policy.saeb_students_report_deploy_policy`
  - Grants permissions for Lambda code updates and S3 artifact access

- `aws_iam_role.api_gateway_cloudwatch_role`
  - Role for API Gateway to send logs to CloudWatch

## Environment Variable Files

This project uses environment-specific `*.tfvars` files to provide resource names for each deployment environment.

- `dev.tfvars`
  - `DYNAMO_QUESTIONS_TABLE="saeb_questions_dev"`
  - `DYNAMO_INTERVENTIONS_TABLE="saeb_interventions_dev"`
  - `DYNAMO_REPORTS_TABLE="saeb_reports_dev"`
  - `S3_OUTPUT_BUCKET_NAME="saeb-student-report-dev"`
  - `S3_INPUT_BUCKET_NAME="saeb-report-assets-dev"`
  - `SQS_QUEUE_NAME="saeb-report-jobs-dev"`
  - `SQS_DEADLETTER_QUEUE_NAME="saeb-report-jobs-dlq-dev"`

- `prd.tfvars`
  - `DYNAMO_QUESTIONS_TABLE="saeb_questions_prd"`
  - `DYNAMO_INTERVENTIONS_TABLE="saeb_interventions_prd"`
  - `DYNAMO_REPORTS_TABLE="saeb_reports_prd"`
  - `S3_OUTPUT_BUCKET_NAME="saeb-student-report-prd"`
  - `S3_INPUT_BUCKET_NAME="saeb-report-assets-prd"`
  - `SQS_QUEUE_NAME="saeb-report-jobs-prd"`
  - `SQS_DEADLETTER_QUEUE_NAME="saeb-report-jobs-dlq-prd"`

## Terraform Commands

### Initialize Terraform

```bash
terraform init
```

### Create a plan and save it to `tfplan`

For dev:

```bash
terraform plan -var-file=dev.tfvars -out=tfplan
```

For prod:

```bash
terraform plan -var-file=prd.tfvars -out=tfplan
```

### Apply the saved plan

```bash
terraform apply "tfplan"
```

### Inspect the saved plan

```bash
terraform show tfplan
```
