import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";
import { getConfig } from "./config";

const sqs = new SQSClient({});

export async function sendToQueue(queueUrl: string | undefined, payload: unknown) {
  if (!queueUrl) return;
  await sqs.send(new SendMessageCommand({
    QueueUrl: queueUrl,
    MessageBody: JSON.stringify(payload),
  }));
}
