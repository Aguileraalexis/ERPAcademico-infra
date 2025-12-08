import { SESClient, SendEmailCommand } from "@aws-sdk/client-ses";
import { getConfig } from "./config";

const ses = new SESClient({});

export async function sendEmail(to: string, subject: string, htmlBody: string) {
  const cfg = getConfig();
  if (!cfg.smtpFromEmail) throw new Error("SMTP_FROM_EMAIL not configured");

  await ses.send(new SendEmailCommand({
    Destination: { ToAddresses: [to] },
    Source: cfg.smtpFromEmail,
    Message: {
      Subject: { Data: subject, Charset: "UTF-8" },
      Body: {
        Html: { Data: htmlBody, Charset: "UTF-8" },
      },
    },
  }));
}
