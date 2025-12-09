variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "erp-academico"
}

variable "db_username" {
  type    = string
  default = "erp_academico_root"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "cognito_admin_email" {
  type = string
  default = "admin@erp-academico.com"
}

variable "system_base_url" {
  type = string
  default = "https://erp-academico.com"
}

variable "smtp_from_email" {
  type = string
  default = "erp-academico@erp-academico.com"
}

variable "lambdas_path" {
  type = string
  default = "lambdas"
}

variable "lambda_artifacts_bucket" {
  type = string
  default = "erp-academico-lambda-artifacts"
}

 