**Configurar AWS CLI localmente**

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

**Configurar Rol IAM para Terraform**

Crear Identity provider y rol para github en la consola de AWS:
- Crear Identity Provider en la consola de AWS con estos datos (solo una vez):
  - Nombre: github-actions
  - Tipo: OpenID Connect
  - url: https://token.actions.githubusercontent.com
  - Audiencia: sts.amazonaws.com

(
  Opcionalmente, con el CLI:
    aws iam create-open-id-connect-provider \
      --url https://token.actions.githubusercontent.com \
      --client-id-list sts.amazonaws.com \
      --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
)

Luego crear el rol IAM con permisos para Terraform en la consola de AWS:
  - nombre: terraform-github-actions
  - Trusted entity type: Web Identity
  - Proveedor de identidad: El anterior
  - Audiencia: sts.amazonaws.com
  - GitHub organization: (ver en gitthub, ej: alexisaguilera)
  - GitHub repository: (ver nombre en github, ej: erp_academico_infra)
  - branch: master u otra que se determine

Se espera una trusted policy como esta:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:OWNER/REPO:ref:refs/heads/develop"
        }
      }
    }
  ]
}

Agregar Permission Policy: PowerUserAccess

**Crear Pipeline en GitHub Actions:**


**Instalar Terraform Localmente**
- Descargar archivo .zip desde https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli, clic en Instalacion Manual. Descomprimir, ej: en C:\terraform y poner carpeta en el el.
- Crear Bucket el **S3: erp-academico-terraform-1**
- Agregar politica que permita a usuarios Listar Buckets y Obtener Ubicacion del Bucket para el nuevo bucket (resource: **arn:aws:s3:::erp-academico-terraform-1**). Ademas Get, Put y Delete en **arn:aws:s3:::erp-academico-terraform-1/erp-academico/front/\***.
- Luego de cada cambio y antes de enviar a repo.
  - terraform validate
  - terraform fmt

