# --- Función helper para crear Lambda desde zip (conceptual, aquí explícito) ---

# Lambda CRUD ejemplo: proceso_admision
resource "aws_lambda_function" "lambda-proceso-admision-crud" {
  function_name = "${local.name_prefix}-lambda-proceso-admision-crud"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  s3_bucket = var.lambda_artifacts_bucket
  s3_key    = "${local.const_entity_proceso_admision}.zip"

  # hash calculado en el pipeline de build de lambdas
  source_code_hash = "${local.const_entity_proceso_admision}-hash"

  environment {
    variables = {
      DB_HOST       = aws_db_instance.mysql.address
      DB_NAME       = aws_db_instance.mysql.db_name
      DB_USER       = var.db_username
      DB_PASSWORD   = var.db_password
      ENTITY_NAME   = "${local.const_entity_proceso_admision}"
    }
  }

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.db_sg.id]
  }
}

# Lambda CRUD estudiante
resource "aws_lambda_function" "lambda-estudiante-crud" {
  function_name = "${local.name_prefix}-lambda-estudiante-crud"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  s3_bucket = var.lambda_artifacts_bucket
  s3_key    = "${local.const_entity_estudiante}.zip"

  # hash calculado en el pipeline de build de lambdas
  source_code_hash = "${local.const_entity_estudiante}-hash"

  environment {
    variables = {
      DB_HOST       = aws_db_instance.mysql.address
      DB_NAME       = aws_db_instance.mysql.db_name
      DB_USER       = var.db_username
      DB_PASSWORD   = var.db_password
      ENTITY_NAME   = "${local.const_entity_estudiante}"
    }
  }

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.db_sg.id]
  }
}

# Lambda CRUD admision_estudiante
  resource "aws_lambda_function" "lambda-proceso_admision_estudiante-crud" {
  function_name = "${local.name_prefix}-lambda-proceso_admision_estudiante-crud"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  s3_bucket = var.lambda_artifacts_bucket
  s3_key    = "${local.const_entity_proceso_admision_estudiante}.zip"

  # hash calculado en el pipeline de build de lambdas
  source_code_hash = "${local.const_entity_proceso_admision_estudiante}-hash"

  environment {
    variables = {
      DB_HOST       = aws_db_instance.mysql.address
      DB_NAME       = aws_db_instance.mysql.db_name
      DB_USER       = var.db_username
      DB_PASSWORD   = var.db_password
      ENTITY_NAME   = "${local.const_entity_proceso_admision_estudiante}"
      Q_CERT_MATRICULA  = aws_sqs_queue.q-cert-matricula.id
    }
  }

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.db_sg.id]
  }
}

resource "aws_lambda_function" "lambda-usuario-crud" {
  function_name = "${local.name_prefix}-lambda-usuario-crud"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  s3_bucket = var.lambda_artifacts_bucket
  s3_key    = "${local.const_entity_usuario}.zip"

  # hash calculado en el pipeline de build de lambdas
  source_code_hash = "${local.const_entity_usuario}-hash"

  environment {
    variables = {
      COGNITO_REGION    = var.aws_region
      COGNITO_CLIENT_ID = aws_cognito_user_pool_client.erp_client.id
      COGNITO_USER_POOL = aws_cognito_user_pool.erp.id
    }
  }

}

# Lambdas auxiliares
resource "aws_lambda_function" "lambda-pdf-signed-url" {
  function_name = "${local.name_prefix}-lambda-pdf-signed-url"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  s3_bucket = var.lambda_artifacts_bucket
  s3_key    = "${local.const_art_signed_url}.zip"

  # hash calculado en el pipeline de build de lambdas
  source_code_hash = "${local.const_art_signed_url}-hash"

  environment {
    variables = {
      CERT_MATRICULA_BUCKET = aws_s3_bucket.bkt-cert-matricula.bucket
      CERT_PREINSCRIPCION_BUCKET = aws_s3_bucket.bkt-cert-preinscripcion.bucket
    }
  }
}

resource "aws_lambda_function" "lambda-cert_matricula" {
  function_name = "${local.name_prefix}-lambda-cert_matricula"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  s3_bucket = var.lambda_artifacts_bucket
  s3_key    = "${local.const_bkt_key_cert_matricula}.zip"

  # hash calculado en el pipeline de build de lambdas
  source_code_hash = "${local.const_bkt_key_cert_matricula}-hash"

  environment {
    variables = {
      CERT_MATRICULA_BUCKET = aws_s3_bucket.bkt-cert-matricula.bucket
    }
  }
}

resource "aws_lambda_function" "lambda-resumen-matricula" {
  function_name = "${local.name_prefix}-lambda-resumen_matricula"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  s3_bucket = var.lambda_artifacts_bucket
  s3_key    = "${local.const_bkt_key_resumen_matricula}.zip"

  # hash calculado en el pipeline de build de lambdas
  source_code_hash = "${local.const_bkt_key_resumen_matricula}-hash"

  environment {
    variables = {
      RESUMEN_MATRICULA_BUCKET = aws_s3_bucket.bkt-resumen-matricula.bucket
    }
  }
}

resource "aws_lambda_function" "lambda-cert-preinscripcion" {
  function_name = "${local.name_prefix}-lambda-cert-preinscripcion"
  role          = aws_iam_role.lambda_role.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"

  s3_bucket = var.lambda_artifacts_bucket
  s3_key    = "${local.const_bkt_key_cert_preinscripcion}.zip"

  # hash calculado en el pipeline de build de lambdas
  source_code_hash = "${local.const_bkt_key_cert_preinscripcion}-hash"

  environment {
    variables = {
      CERT_PREINSCRIPCION_BUCKET = aws_s3_bucket.bkt-cert-preinscripcion.bucket
    }
  }
}

# Event source mappings

resource "aws_lambda_event_source_mapping" "q_cert_matricula_to_lambda" {
  event_source_arn = aws_sqs_queue.q-cert-matricula.arn
  function_name    = aws_lambda_function.lambda-cert_matricula.arn
  batch_size       = 5
}

resource "aws_lambda_event_source_mapping" "q_cert_preinscripcion_to_lambda" {
  event_source_arn = aws_sqs_queue.q-cert-preinscripcion.arn
  function_name    = aws_lambda_function.lambda-cert-preinscripcion.arn
  batch_size       = 5
}

resource "aws_lambda_event_source_mapping" "q-resumen-matricula-to-lambda" {
  event_source_arn = aws_sqs_queue.q-resumen-matricula.arn
  function_name    = aws_lambda_function.lambda-resumen-matricula.arn
  batch_size       = 5
}
