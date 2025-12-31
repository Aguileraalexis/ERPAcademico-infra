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
  default = "aguileraalexis@yahoo.com"
}

variable "cognito_admin_username" {
  type = string
  default = "administrador"
}

variable "system_base_url" {
  type = string
  default = "https://smart-sai.com"
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
  default = "erp-academico-lambdas"
}

############################
# variables para el contenedor
############################

# pasar esta en el pipeline luego de construir la imagen docker
variable "container_port" { 
  type = number
  default = 8080 
}

variable "desired_count"  { 
  type = number
  default = 1 
}

variable "ecs_cpu" { 
  type = number
  default = 512 
}

variable "ecs_memory" { 
  type = number
  default = 1024 
}

# pasar en el pipeline por ahora con dev.
variable "spring_env" {
  type    = map(string)
  default = {
    SPRING_PROFILES_ACTIVE = "prod"
  }
}

############
# para emails
############

variable "use_route53" {
  type        = bool
  default     = false
  description = "true si tu DNS está en Route53 y quieres que TF cree los records"
}

variable "route53_zone_id" {
  type        = string
  default     = ""
  description = "Hosted Zone ID (solo si use_route53=true)"
}

variable "domain" {
  type        = string
  default        = "sai.sigroup.net.pe"
  description = "Dominio a verificar en SES"
}

variable "from_address" {
  type        = string
  default        = "sistema@sai.sigroup.net.pe"
  description = "From: que usarás (ej: sistema@sai.sigroup.net.pe)"
}

variable "ses_template_prefix" {
  type    = string
  default = "ses_template_v1"
}
