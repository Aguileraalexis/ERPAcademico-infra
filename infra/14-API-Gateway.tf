############################
# API Gateway HTTP API + VPC Link + Proxy ($default)
############################
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"
}

# SG para VPC Link: permite egress al ALB (80)
resource "aws_security_group" "vpclink_sg" {
  name        = "${local.name_prefix}-vpclink-sg"
  description = "API GW VPC Link egress to ALB"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
}

resource "aws_apigatewayv2_vpc_link" "vpclink" {
  name               = "${local.name_prefix}-vpclink"
  subnet_ids         = local.subnet_ids
  security_group_ids = [aws_security_group.vpclink_sg.id]
}

# Integración proxy hacia ALB Listener
resource "aws_apigatewayv2_integration" "alb_proxy" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.vpclink.id
  integration_uri        = aws_lb_listener.http.arn
  payload_format_version = "1.0"
}

# $default = proxy total (incluye /actuator/**)
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.alb_proxy.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}


