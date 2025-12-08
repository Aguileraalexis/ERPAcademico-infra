# VPC por defecto
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# SG para BD y Lambdas
resource "aws_security_group" "db_sg" {
  name        = "${local.name_prefix}-db-sg"
  description = "Permite acceso a MySQL desde Lambdas"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # AJUSTAR A SUBREDES PRIVADAS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Subnet group para RDS
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

# Secrets
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${local.name_prefix}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials_v" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

resource "aws_secretsmanager_secret" "system_config" {
  name = "${local.name_prefix}-system-config"
}

resource "aws_secretsmanager_secret_version" "system_config_v" {
  secret_id = aws_secretsmanager_secret.system_config.id
  secret_string = jsonencode({
    system_base_url = var.system_base_url
  })
}

# COGNITO
resource "aws_cognito_user_pool" "erp" {
  name = "${local.name_prefix}-user-pool"

  alias_attributes = ["email"]

  password_policy {
    minimum_length    = 10
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "erp_client" {
  name         = "${local.name_prefix}-client"
  user_pool_id = aws_cognito_user_pool.erp.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

resource "aws_cognito_user_group" "erp_admin_group" {
  name         = "ERPAcademicoAdmin"
  user_pool_id = aws_cognito_user_pool.erp.id
  description  = "Administradores ERP Académico"
}

resource "aws_cognito_user" "admin_user" {
  user_pool_id = aws_cognito_user_pool.erp.id
  username     = var.cognito_admin_email

  attributes = {
    email          = var.cognito_admin_email
    email_verified = "true"
  }

  message_action = "SUPPRESS"

  lifecycle {
    ignore_changes = [password]
  }
}

resource "aws_cognito_user_group_membership" "admin_in_group" {
  user_pool_id = aws_cognito_user_pool.erp.id
  username     = aws_cognito_user.admin_user.username
  group_name   = aws_cognito_user_group.erp_admin_group.name
}

# RDS MySQL
resource "aws_db_instance" "mysql" {
  identifier        = "${local.name_prefix}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "erp_academico"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  skip_final_snapshot = true
  publicly_accessible = false
}

# S3 buckets
resource "aws_s3_bucket" "fotos" {
  bucket = "${local.name_prefix}-fotos"
}

resource "aws_s3_bucket" "excel_resumen_matricula" {
  bucket = "${local.name_prefix}-excel-resumen-matricula"
}

resource "aws_s3_bucket" "cert_preinscripcion" {
  bucket = "${local.name_prefix}-cert-preinscripcion"
}

resource "aws_s3_bucket" "cert_matricula" {
  bucket = "${local.name_prefix}-cert-matricula"
}

# SQS
resource "aws_sqs_queue" "q_cm_pdf" {
  name = "${local.name_prefix}-cm-pdf-queue"
}

resource "aws_sqs_queue" "q_email" {
  name = "${local.name_prefix}-email-queue"
}

resource "aws_sqs_queue" "q_user_create" {
  name = "${local.name_prefix}-user-create-queue"
}

resource "aws_sqs_queue" "q_user_password_email" {
  name = "${local.name_prefix}-user-password-email-queue"
}

# IAM para Lambdas
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_app" {
  statement {
    actions = [
      "rds-db:connect",
      "secretsmanager:GetSecretValue",
      "sqs:*",
      "s3:*",
      "cognito-idp:*",
      "ses:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_app" {
  name   = "${local.name_prefix}-lambda-app-policy"
  policy = data.aws_iam_policy_document.lambda_app.json
}

resource "aws_iam_role_policy_attachment" "lambda_app_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_app.arn
}

# --- Función helper para crear Lambda desde zip (conceptual, aquí explícito) ---

# Lambda CRUD ejemplo: proceso_admision
resource "aws_lambda_function" "proceso_admision" {
  function_name = "${local.name_prefix}-proceso-admision-crud"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  filename         = "${local.artifacts_path}/proceso_admision.zip"
  source_code_hash = filebase64sha256("${local.artifacts_path}/proceso_admision.zip")

  environment {
    variables = {
      DB_HOST       = aws_db_instance.mysql.address
      DB_NAME       = aws_db_instance.mysql.db_name
      DB_USER       = var.db_username
      DB_PASSWORD   = var.db_password
      ENTITY_NAME   = "proceso_admision"
      Q_CM_PDF_URL  = aws_sqs_queue.q_cm_pdf.id
    }
  }

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.db_sg.id]
  }
}

# Lambda CRUD estudiante
resource "aws_lambda_function" "estudiante" {
  function_name = "${local.name_prefix}-estudiante-crud"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  filename         = "${local.artifacts_path}/estudiante.zip"
  source_code_hash = filebase64sha256("${local.artifacts_path}/estudiante.zip")

  environment {
    variables = {
      DB_HOST         = aws_db_instance.mysql.address
      DB_NAME         = aws_db_instance.mysql.db_name
      DB_USER         = var.db_username
      DB_PASSWORD     = var.db_password
      ENTITY_NAME     = "estudiante"
      Q_USER_CREATE   = aws_sqs_queue.q_user_create.id
    }
  }

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.db_sg.id]
  }
}

# Lambda CRUD admision_estudiante
resource "aws_lambda_function" "admision_estudiante" {
  function_name = "${local.name_prefix}-admision-estudiante-crud"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  filename         = "${local.artifacts_path}/admision_estudiante.zip"
  source_code_hash = filebase64sha256("${local.artifacts_path}/admision_estudiante.zip")

  environment {
    variables = {
      DB_HOST      = aws_db_instance.mysql.address
      DB_NAME      = aws_db_instance.mysql.db_name
      DB_USER      = var.db_username
      DB_PASSWORD  = var.db_password
      ENTITY_NAME  = "admision_estudiante"
      Q_CM_PDF_URL = aws_sqs_queue.q_cm_pdf.id
    }
  }

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.db_sg.id]
  }
}

# Lambdas auxiliares
resource "aws_lambda_function" "pdf_generar_cm" {
  function_name = "${local.name_prefix}-pdf-generar-cm"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  filename         = "${local.artifacts_path}/pdf_generar_cm.zip"
  source_code_hash = filebase64sha256("${local.artifacts_path}/pdf_generar_cm.zip")

  environment {
    variables = {
      CERT_MATRICULA_BUCKET = aws_s3_bucket.cert_matricula.bucket
      Q_EMAIL_URL           = aws_sqs_queue.q_email.id
    }
  }
}

resource "aws_lambda_function" "pdf_signed_url" {
  function_name = "${local.name_prefix}-pdf-signed-url"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  filename         = "${local.artifacts_path}/pdf_signed_url.zip"
  source_code_hash = filebase64sha256("${local.artifacts_path}/pdf_signed_url.zip")

  environment {
    variables = {
      CERT_MATRICULA_BUCKET = aws_s3_bucket.cert_matricula.bucket
    }
  }
}

resource "aws_lambda_function" "email_enviar_cm" {
  function_name = "${local.name_prefix}-email-enviar-cm"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  filename         = "${local.artifacts_path}/email_enviar_cm.zip"
  source_code_hash = filebase64sha256("${local.artifacts_path}/email_enviar_cm.zip")

  environment {
    variables = {
      SMTP_FROM_EMAIL = var.smtp_from_email
    }
  }
}

resource "aws_lambda_function" "cognito_crear_usuario" {
  function_name = "${local.name_prefix}-cognito-crear-usuario"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  filename         = "${local.artifacts_path}/cognito_crear_usuario.zip"
  source_code_hash = filebase64sha256("${local.artifacts_path}/cognito_crear_usuario.zip")

  environment {
    variables = {
      USER_POOL_ID              = aws_cognito_user_pool.erp.id
      Q_USER_PASSWORD_EMAIL_URL = aws_sqs_queue.q_user_password_email.id
    }
  }
}

resource "aws_lambda_function" "email_enviar_password" {
  function_name = "${local.name_prefix}-email-enviar-password"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  filename         = "${local.artifacts_path}/email_enviar_password.zip"
  source_code_hash = filebase64sha256("${local.artifacts_path}/email_enviar_password.zip")

  environment {
    variables = {
      SMTP_FROM_EMAIL = var.smtp_from_email
      SYSTEM_BASE_URL = var.system_base_url
    }
  }
}

# Event source mappings

resource "aws_lambda_event_source_mapping" "q_cm_pdf_to_lambda" {
  event_source_arn = aws_sqs_queue.q_cm_pdf.arn
  function_name    = aws_lambda_function.pdf_generar_cm.arn
  batch_size       = 5
}

resource "aws_lambda_event_source_mapping" "q_email_to_lambda" {
  event_source_arn = aws_sqs_queue.q_email.arn
  function_name    = aws_lambda_function.email_enviar_cm.arn
  batch_size       = 5
}

resource "aws_lambda_event_source_mapping" "q_user_create_to_lambda" {
  event_source_arn = aws_sqs_queue.q_user_create.arn
  function_name    = aws_lambda_function.cognito_crear_usuario.arn
  batch_size       = 5
}

resource "aws_lambda_event_source_mapping" "q_user_password_email_to_lambda" {
  event_source_arn = aws_sqs_queue.q_user_password_email.arn
  function_name    = aws_lambda_function.email_enviar_password.arn
  batch_size       = 5
}

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
  uri                     = aws_lambda_function.proceso_admision.invoke_arn
}

resource "aws_lambda_permission" "apigw_invoke_proceso_admision" {
  statement_id  = "AllowAPIGatewayInvokeProcesoAdmision"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.proceso_admision.function_name
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
  uri                     = aws_lambda_function.pdf_signed_url.invoke_arn
}

resource "aws_lambda_permission" "apigw_invoke_pdf_signed" {
  statement_id  = "AllowAPIGatewayInvokePdfSigned"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pdf_signed_url.function_name
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
