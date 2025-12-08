import { APIGatewayProxyHandler } from "aws-lambda";
import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { getConfig } from "../../common/config";
import { json } from "../../common/response";

const s3 = new S3Client({});

export const handler: APIGatewayProxyHandler = async (event) => {
  const cfg = getConfig();
  const id = event.queryStringParameters?.id;
  if (!id) {
    return json(400, { message: "id requerido" });
  }

  const key = `CM_${id}.pdf`;
  const command = new GetObjectCommand({
    Bucket: cfg.certMatriculaBucket,
    Key: key,
  });

  const url = await getSignedUrl(s3, command, { expiresIn: 300 }); // 5 min

  return json(200, { url });
};
