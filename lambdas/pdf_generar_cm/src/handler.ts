import { SQSEvent } from "aws-lambda";
import { generarCertificadoMatricula } from "../../common/pdf";
import { sendToQueue } from "../../common/sqs";
import { getConfig } from "../../common/config";

interface CmMessage {
  id: string;
  email?: string;
  nombre?: string;
}

export const handler = async (event: SQSEvent) => {
  const cfg = getConfig();

  for (const record of event.Records) {
    const msg: CmMessage = JSON.parse(record.body);

    await generarCertificadoMatricula(msg.id, {
      nombre: msg.nombre ?? "Estudiante",
    });

    await sendToQueue(cfg.qCmPdfUrl, {
      type: "PDF_GENERADO_CM",
      id: msg.id,
      email: msg.email,
    });
  }

  return {};
};
