import { APIGatewayProxyHandler } from "aws-lambda";
import { getPool } from "../../common/db";
import { json } from "../../common/response";
import { getConfig } from "../../common/config";
import { v4 as uuidv4 } from "uuid";
import { sendToQueue } from "../../common/sqs";

export const handler: APIGatewayProxyHandler = async (event) => {
  const cfg = getConfig();
  const pool = getPool();
  const entity = cfg.entityName!;
  const method = event.httpMethod;
  const path = event.path;

  const conn = await pool.getConnection();
  try {
    if (method === "GET" && event.pathParameters && event.pathParameters.id) {
      const [rows] = await conn.query(`SELECT * FROM ${entity} WHERE id = ?`, [event.pathParameters.id]);
      return json(200, rows[0] ?? null);
    }

    if (method === "GET") {
      const [rows] = await conn.query(`SELECT * FROM ${entity}`);
      return json(200, rows);
    }

    const body = event.body ? JSON.parse(event.body) : null;

    if (method === "POST") {
      await conn.beginTransaction();
      const items = Array.isArray(body) ? body : [body];
      const inserted: any[] = [];
      for (const item of items) {
        const id = item.id ?? uuidv4();
        const data = { ...item, id };
        const fields = Object.keys(data);
        const values = Object.values(data);
        const placeholders = fields.map(() => "?").join(",");
        await conn.execute(
          `INSERT INTO ${entity} (${fields.join(",")}) VALUES (${placeholders})`,
          values
        );
        inserted.push(data);

        // lógica específica por entidad:
        if (entity === "admision_estudiante" && (data as any).estado === "RG" && cfg.qCmPdfUrl) {
          await sendToQueue(cfg.qCmPdfUrl, { id: data.id });
        }
        if (entity === "estudiante" && cfg.qUserCreateUrl) {
          await sendToQueue(cfg.qUserCreateUrl, { id: data.id, numero_estudiante: data.numero_estudiante });
        }
      }
      await conn.commit();
      return json(201, inserted.length === 1 ? inserted[0] : inserted);
    }

    if (method === "PUT") {
      await conn.beginTransaction();
      const items = Array.isArray(body) ? body : [body];

      for (const item of items) {
        if (!item.id) throw new Error("id is required for update");
        const id = item.id;
        const data = { ...item };
        delete data.id;
        const fields = Object.keys(data);
        const values = Object.values(data);
        const setClause = fields.map((f) => `${f} = ?`).join(", ");
        await conn.execute(
          `UPDATE ${entity} SET ${setClause} WHERE id = ?`,
          [...values, id]
        );

        if (entity === "admision_estudiante" && cfg.qCmPdfUrl) {
          // solo si cambia a RG, idealmente comparar estados
          if ((data as any).estado === "RG") {
            await sendToQueue(cfg.qCmPdfUrl, { id });
          }
        }
      }

      await conn.commit();
      return json(200, { updated: items.length });
    }

    if (method === "DELETE") {
      await conn.beginTransaction();
      const items = Array.isArray(body) ? body : [body];
      for (const item of items) {
        const id = typeof item === "string" ? item : item.id;
        await conn.execute(`DELETE FROM ${entity} WHERE id = ?`, [id]);
      }
      await conn.commit();
      return json(200, { deleted: items.length });
    }

    return json(400, { message: "Unsupported operation" });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    return json(500, { message: "Internal error" });
  } finally {
    conn.release();
  }
};
