# S3 buckets
resource "aws_s3_bucket" "bkt-lambdas" {
  bucket = "${local.name_prefix}-lambdas"
}

resource "aws_s3_bucket" "bkt-fotos" {
  bucket = "${local.name_prefix}-fotos"
}

resource "aws_s3_bucket" "bkt-resumen-matricula" {
  bucket = "${local.name_prefix}-resumen-matricula"
}

resource "aws_s3_bucket" "bkt-cert-preinscripcion" {
  bucket = "${local.name_prefix}-cert-preinscripcion"
}

resource "aws_s3_bucket" "bkt-cert-matricula" {
  bucket = "${local.name_prefix}-cert-matricula"
}

