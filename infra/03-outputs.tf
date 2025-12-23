output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.erp.id
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.address
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "api_gateway_invoke_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

# SES DNS records (para DNS fuera de Route53)
output "ses_verification_record" {
  value = {
    name  = "_amazonses.${var.domain}"
    type  = "TXT"
    value = aws_ses_domain_identity.ses_domain_id.verification_token
  }
}

output "ses_dkim_records" {
  value = [
    for t in aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens : {
      name  = "${t}._domainkey.${var.domain}"
      type  = "CNAME"
      value = "${t}.dkim.amazonses.com"
    }
  ]
}

#output "route53_zone_id" {
#  value       = aws_route53_zone.aws_route53.zone_id
#  description = "Zone ID para usar en SES, ACM, etc."
#}

#output "route53_name_servers" {
#  value       = aws_route53_zone.aws_route53.name_servers
#  description = "Nameservers que debes configurar en tu registrador"
#}
