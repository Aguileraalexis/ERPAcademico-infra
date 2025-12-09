# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name = "${local.name_prefix}-api"
}

# /proceso-admision
resource "aws_api_gateway_resource" "proceso_admision" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "proceso-admision"
}

resource "aws_api_gateway_method" "proceso_admision_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proceso_admision.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proceso_admision_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proceso_admision.id
  http_method             = aws_api_gateway_method.proceso_admision_any.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda-proceso-admision-crud.invoke_arn
}

resource "aws_lambda_permission" "apigw_invoke_proceso_admision" {
  statement_id  = "AllowAPIGatewayInvokeProcesoAdmision"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-proceso-admision-crud.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# endpoint signed-url /certificado
resource "aws_api_gateway_resource" "certificado" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "certificado"
}

resource "aws_api_gateway_method" "certificado_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.certificado.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "certificado_get_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.certificado.id
  http_method             = aws_api_gateway_method.certificado_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda-pdf-signed-url.invoke_arn
}

resource "aws_lambda_permission" "apigw_invoke_pdf_signed" {
  statement_id  = "AllowAPIGatewayInvokePdfSigned"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-pdf-signed-url.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeploy = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name    = "dev"
}
