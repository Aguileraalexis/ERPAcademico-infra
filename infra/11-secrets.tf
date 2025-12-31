# Secrets
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${local.name_prefix}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials_v" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    url = "jdbc:mysql://${aws_db_instance.mysql.address}:3306/${aws_db_instance.mysql.db_name}?zeroDateTimeBehavior=CONVERT_TO_NULL"
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

