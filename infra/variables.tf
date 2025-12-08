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
}

variable "system_base_url" {
  type = string
}

variable "smtp_from_email" {
  type = string
}
