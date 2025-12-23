data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.vpc_subnets.ids)
  id       = each.value
}

locals {
  name_prefix    = var.project_name
  const_entity_proceso_admision = "proceso_admision"  
  const_entity_estudiante = "estudiante"  
  const_entity_usuario = "usuario"  
  const_entity_proceso_admision_estudiante = "proceso_admision_estudiante"  

  const_art_cert_preinscripcion = "cert-preinscripcion"  
  const_art_cert_matricula = "cert-matricula"  
  const_art_resumen_matricula = "resumen-matricula"  
  const_art_password = "password"  
  const_art_signed_url = "signed-url"  

  const_bkt_key_foto = "img_foto"
  const_bkt_key_cert_preinscripcion = "bkt-key-cert-preinscripcion"
  const_bkt_key_cert_matricula = "bkt-key-cert-matricula"
  const_bkt_key_resumen_matricula = "bkt-key-resumen-matricula"

  const_q_cert_preinscripcion = "q-cert-preinscripcion"
  const_q_cert_matricula = "q-cert-matricula"
  const_q_resumen_matricula = "q-resumen-matricula"

  subnet_ids = [
    for s in values(data.aws_subnet.details) : s.id
    if s.availability_zone_id != "use1-az3"
  ]

  bootstrap_zip = "${path.module}/bootstrap.zip"
}

