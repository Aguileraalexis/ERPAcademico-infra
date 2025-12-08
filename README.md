# ERP Académico - Infraestructura y Lambdas (AWS)

Este paquete contiene:

- `infra/`: definición completa de infraestructura en Terraform.
- `db/flyway/`: script de creación de tablas iniciales.
- `lambdas/`: lambdas en TypeScript para CRUD y procesos asíncronos (PDF, emails, Cognito).
- `.github/workflows/terraform-deploy-develop.yml`: pipeline para desplegar al hacer push a `develop`.

Flujos clave:
- CRUD `admision_estudiante` envía mensaje a SQS cuando el estado es `RG`, lo que dispara generación de PDF CM_<ID> y luego email al estudiante.
- Crear `estudiante` envía mensaje a SQS para crear usuario en Cognito con contraseña fuerte y luego envía email con credenciales.

Antes de aplicar Terraform:
- Configura el backend de `infra/backend.tf` (bucket y tabla DynamoDB).
- Configura los *secrets* en GitHub: `DB_PASSWORD`, `COGNITO_ADMIN_EMAIL`, `SYSTEM_BASE_URL`, `SMTP_FROM_EMAIL`.

Para desplegar:
1. Subir este repo a GitHub.
2. Hacer push a la rama `develop`.
3. El workflow construirá las lambdas, generará los ZIP en `artifacts/` y ejecutará `terraform apply`.
