import { SQSEvent } from "aws-lambda";
import { sendEmail } from "../../common/email";
import { getConfig } from "../../common/config";

interface EmailMsg {
  id: string;
  email: string;
}

export const handler = async (event: SQSEvent) => {
  const cfg = getConfig();

  for (const record of event.Records) {
    const msg: EmailMsg = JSON.parse(record.body);

    const link = `${cfg.systemBaseUrl}/certificado?id=${encodeURIComponent(msg.id)}`;

    const html = `
      <p>Estimado estudiante,</p>
      <p>Su certificado de matrícula está disponible.</p>
      <p>Puede descargarlo desde el siguiente enlace:</p>
      <p><a href="${link}">${link}</a></p>
    `;

    await sendEmail(msg.email, "Certificado de matrícula", html);
  }

  return {};
};
