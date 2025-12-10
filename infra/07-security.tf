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

# IAM para Lambdas
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect = "Allow"
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
    effect = "Allow"
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

data "aws_iam_policy_document" "lambda_auth_cognito" {
  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:InitiateAuth",
    ]
    resources = [
      aws_cognito_user_pool.erp.arn,
    ]
  }
}

resource "aws_iam_policy" "lambda_auth_cognito" {
  name   = "${local.name_prefix}-lambda-auth-cognito"
  policy = data.aws_iam_policy_document.lambda_auth_cognito.json
}

resource "aws_iam_role_policy_attachment" "lambda_auth_cognito_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_auth_cognito.arn
}

resource "aws_iam_policy" "lambda_app" {
  name   = "${local.name_prefix}-lambda-app-policy"
  policy = data.aws_iam_policy_document.lambda_app.json
}

resource "aws_iam_role_policy_attachment" "lambda_app_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_app.arn
}

