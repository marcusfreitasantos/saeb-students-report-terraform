resource "aws_apigatewayv2_api" "saeb_api" {
  name          = "saeb-students-report-api"
  protocol_type = "HTTP"

  tags = local.common_tags

}

moved {
  from = aws_apigatewayv2_integration.lambda
  to   = aws_apigatewayv2_integration.manage_report_questions_integration
}

#------------- MANAGE REPORT QUESTION API -------------#
resource "aws_apigatewayv2_integration" "manage_report_questions_integration" {
  api_id = aws_apigatewayv2_api.saeb_api.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.manage_report_questions.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_question" {
  api_id = aws_apigatewayv2_api.saeb_api.id

  route_key = "POST /questions/create"
  target    = "integrations/${aws_apigatewayv2_integration.manage_report_questions_integration.id}"
}

resource "aws_apigatewayv2_route" "list_questions" {
  api_id = aws_apigatewayv2_api.saeb_api.id

  route_key = "GET /questions/all"
  target    = "integrations/${aws_apigatewayv2_integration.manage_report_questions_integration.id}"
}

resource "aws_apigatewayv2_route" "create_intervention" {
  api_id = aws_apigatewayv2_api.saeb_api.id

  route_key = "POST /interventions/create"
  target    = "integrations/${aws_apigatewayv2_integration.manage_report_questions_integration.id}"
}

resource "aws_apigatewayv2_route" "list_interventions" {
  api_id = aws_apigatewayv2_api.saeb_api.id

  route_key = "GET /interventions/all"
  target    = "integrations/${aws_apigatewayv2_integration.manage_report_questions_integration.id}"
}


#------------- GENERATE PRESIGNED URL API -------------#
resource "aws_apigatewayv2_integration" "generate_presigned_url_integration" {
  api_id = aws_apigatewayv2_api.saeb_api.id

  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.generate_presigned_url.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "generate_presigned_url" {
  api_id = aws_apigatewayv2_api.saeb_api.id

  route_key = "POST /report/generate-url"
  target    = "integrations/${aws_apigatewayv2_integration.generate_presigned_url_integration.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  for_each     = toset([aws_lambda_function.manage_report_questions.function_name, aws_lambda_function.generate_presigned_url.function_name])
  statement_id = "AllowExecutionFromAPIGateway-${each.key}"
  action       = "lambda:InvokeFunction"
  function_name = each.value
  principal    = "apigateway.amazonaws.com"
  source_arn   = "${aws_apigatewayv2_api.saeb_api.execution_arn}/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.saeb_api.id

  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      integrationLatency = "$context.integration.latency"
      error          = "$context.error.message"
      integrationError  = "$context.integrationErrorMessage"
    })
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy.api_gateway_cloudwatch_policy
  ]
}

output "api_url" {
  value = aws_apigatewayv2_api.saeb_api.api_endpoint
}