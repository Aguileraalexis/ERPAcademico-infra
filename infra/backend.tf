terraform {
  backend "s3" {
    bucket = "sig-erp-academico-terraform-1"  # debe existir
    key    = "erp-academico/front/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    # dynamodb_table = "terraform-locks"   # ELIMINADO (deprecado)
  }
}
