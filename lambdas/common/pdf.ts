import PDFDocument from "pdfkit";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getConfig } from "./config";

const s3 = new S3Client({});

export async function generarCertificadoMatricula(id: string, contenido: { nombre: string; carrera?: string }) {
  const cfg = getConfig();
  if (!cfg.certMatriculaBucket) throw new Error("CERT_MATRICULA_BUCKET not configured");

  const doc = new PDFDocument();
  const chunks: Buffer[] = [];

  return await new Promise<void>((resolve, reject) => {
    doc.on("data", (chunk) => chunks.push(Buffer.from(chunk)));
    doc.on("end", async () => {
      const pdfBuffer = Buffer.concat(chunks);
      const key = `CM_${id}.pdf`;

      await s3.send(new PutObjectCommand({
        Bucket: cfg.certMatriculaBucket,
        Key: key,
        Body: pdfBuffer,
        ContentType: "application/pdf",
      }));
      resolve();
    });
    doc.on("error", reject);

    doc.fontSize(20).text("Certificado de Matrícula", { align: "center" });
    doc.moveDown();
    doc.fontSize(14).text(`Estudiante: ${contenido.nombre}`);
    if (contenido.carrera) {
      doc.text(`Programa: ${contenido.carrera}`);
    }
    doc.text(`ID: ${id}`);
    doc.end();
  });
}
