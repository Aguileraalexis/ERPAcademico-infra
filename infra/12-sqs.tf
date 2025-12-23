# SQS
resource "aws_sqs_queue" "q-email-enviar" {
  name = "queue-email-enviar"
}
