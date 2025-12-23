# --- Función helper para crear Lambda desde zip (conceptual, aquí explícito) ---

resource "aws_lambda_function" "lambda-email-enviar" {
  function_name = "${local.name_prefix}-lambda-email-enviar"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  filename         = local.bootstrap_zip
  source_code_hash = filebase64sha256(local.bootstrap_zip)

  lifecycle {
    ignore_changes = [ filename, source_code_hash ]
  }

}

# Event source mappings

resource "aws_lambda_event_source_mapping" "q-email-enviar-mapping" {
  event_source_arn = aws_sqs_queue.q-email-enviar.arn
  function_name    = aws_lambda_function.lambda-email-enviar.arn
  batch_size       = 5
}
