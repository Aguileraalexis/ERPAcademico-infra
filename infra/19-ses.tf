############################
# 1) SES: Domain identity
############################
resource "aws_ses_domain_identity" "ses_domain_id" {
  domain = var.domain
}

# TXT de verificación (solo si usas Route53)
resource "aws_route53_record" "ses_verification" {
  count   = var.use_route53 ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.ses_domain_id.verification_token]
}

############################
# 2) SES: DKIM
############################
resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = aws_ses_domain_identity.ses_domain_id.domain
}

# CNAMEs DKIM (solo si usas Route53)
resource "aws_route53_record" "ses_dkim" {
  count   = var.use_route53 ? 3 : 0
  zone_id = var.route53_zone_id
  name    = "${aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens[count.index]}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = 600
  records = ["${aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

############################
# 3) SES: Email templates
############################
resource "aws_ses_template" "ses_template_bienvenida" {
  name    = "${var.ses_template_prefix}_bienvenida"
  subject = "Hola {{name}}"
  html    = file("${path.module}/templates/bienvenida.html")
  text    = file("${path.module}/templates/bienvenida.txt")
}

resource "aws_ses_template" "ses_template_cert_matricula" {
  name    = "${var.ses_template_prefix}_cert_matricula"
  subject = "Hola {{name}}"
  html    = file("${path.module}/templates/cert_matricula.html")
  text    = file("${path.module}/templates/cert_matricula.txt")
}

resource "aws_ses_template" "ses_template_cert_preinscripcion" {
  name    = "${var.ses_template_prefix}_cert_preinscripcion"
  subject = "Hola {{name}}"
  html    = file("${path.module}/templates/cert_preinscripcion.html")
  text    = file("${path.module}/templates/cert_preinscripcion.txt")
}

############################
# 4) IAM: Permisos SES para la Lambda
############################
resource "aws_iam_policy" "lambda_ses_send" {
  name = "${aws_iam_role.lambda_role.name}-ses-send"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowSendTemplatedOrSimple"
      Effect = "Allow"
      Action = [
        "ses:SendEmail",
        "ses:SendRawEmail",
        "ses:SendTemplatedEmail"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ses_send.arn
}
