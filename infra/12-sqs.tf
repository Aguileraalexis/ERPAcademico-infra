# SQS
resource "aws_sqs_queue" "q-cert-matricula" {
  name = "queue-cert-matricula"
}

resource "aws_sqs_queue" "q-cert-preinscripcion" {
  name = "queue-cert-preinscripcion"
}

resource "aws_sqs_queue" "q-resumen-matricula" {
  name = "queue-resumen-matricula"
}
