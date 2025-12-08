import { SQSEvent } from "aws-lambda";
import { sendEmail } from "../../common/email";
import { getConfig } from "../../common/config";

interface PasswordMsg {
  email: string;
  password: string;
  numero_estudiante: string;
}

export const handler = async (event: SQSEvent) => {
  const cfg = getConfig();

  for (const record of event.Records) {
    const msg: PasswordMsg = JSON.parse(record.body);

    const link = cfg.systemBaseUrl;

    const html = `
      <p>Estimado estudiante,</p>
      <p>Se ha creado su usuario en el sistema ERP Académico.</p>
      <p><strong>Usuario:</strong> ${msg.email}</p>
      <p><strong>Contraseña temporal:</strong> ${msg.password}</p>
      <p>Puede acceder al sistema en: <a href="${link}">${link}</a></p>
      <p>Se le pedirá cambiar la contraseña en el primer ingreso.</p>
    `;

    await sendEmail(msg.email, "Usuario creado en ERP Académico", html);
  }

  return {};
};
