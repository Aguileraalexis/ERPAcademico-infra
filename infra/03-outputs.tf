output "api_base_url" {
  value = aws_api_gateway_stage.stage.invoke_url
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.erp.id
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}
