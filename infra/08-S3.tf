# S3 buckets
resource "aws_s3_bucket" "bkt-lambdas" {
  bucket = "${local.name_prefix}-lambdas"
}

resource "aws_s3_bucket" "bkt_archivos" {
  bucket = "${local.name_prefix}-archivos-${var.spring_env["SPRING_PROFILES_ACTIVE"]}"
}

resource "aws_s3_bucket" "bkt_local" {
  bucket = "${local.name_prefix}-archivos-local"
}

