**AWS**

- Descargar y ejecutar instalador MSI o equivalente desde https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- verificar instalacion: aws --version
- Crear o usar usuario IAM con estos permisos recomendados: AmazonDRSFullAccess, AmazonEC2FullAccess, AmazonS3FullAccess, AmazonDynamoDBFullAccess, AmazonRoute53FullAccess, IAMFullAccess
- Crear access key para el usuario (AWS console/IAM)
- aws configure --profile ERPAcademico. Indicar Access key, secret access key, default region: us-east-1 y default output format (solo enter).
- Indicar el perfil es opcional, solo si se tiene configurados otros perfiles/proyectos en AWS.
- verificar acceso:
  - aws s3 ls
  - Powershell: Get-Content $HOME\.aws\credentials
  - Powershell: Get-Content $HOME\.aws\config

**Terraform**
- Descargar archivo .zip desde https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli, clic en Instalacion Manual. Descomprimir, ej: en C:\terraform y poner carpeta en el path.
- Crear Bucket el **S3: erp-academico-terraform-1**
- Agregar politica que permita a usuarios Listar Buckets y Obtener Ubicacion del Bucket para el nuevo bucket (resource: **arn:aws:s3:::sig-erp-academico-terraform-1**). Ademas Get, Put y Delete en **arn:aws:s3:::sig-erp-academico-terraform-1/erp-academico/front/\***.
- Luego de cada cambio y antes de enviar a repo.
  - terraform validate
  - terraform fmt

