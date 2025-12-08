import { SQSEvent } from "aws-lambda";
import { createUserInCognito } from "../../common/cognito";
import { sendToQueue } from "../../common/sqs";
import { getConfig } from "../../common/config";

interface UserCreateMsg {
  id: string;
  numero_estudiante: string;
  email?: string;
}

export const handler = async (event: SQSEvent) => {
  const cfg = getConfig();

  for (const record of event.Records) {
    const msg: UserCreateMsg = JSON.parse(record.body);

    if (!msg.email) {
      console.warn("Mensaje sin email, omitiendo creación de usuario", msg);
      continue;
    }

    const password = await createUserInCognito(msg.email);

    await sendToQueue(cfg.qUserPasswordEmailUrl, {
      email: msg.email,
      password,
      numero_estudiante: msg.numero_estudiante,
    });
  }

  return {};
};
