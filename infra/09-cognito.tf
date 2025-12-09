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

resource "aws_cognito_user_in_group" "admin_in_group" {
  user_pool_id = aws_cognito_user_pool.erp.id
  username     = aws_cognito_user.admin_user.username
  group_name   = aws_cognito_user_group.erp_admin_group.name
}

