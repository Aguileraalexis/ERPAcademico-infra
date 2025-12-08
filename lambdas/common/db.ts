import mysql from "mysql2/promise";
import { getConfig } from "./config";

let pool: mysql.Pool | null = null;

export function getPool(): mysql.Pool {
  if (!pool) {
    const cfg = getConfig();
    pool = mysql.createPool({
      host: cfg.dbHost,
      user: cfg.dbUser,
      password: cfg.dbPassword,
      database: cfg.dbName,
      waitForConnections: true,
      connectionLimit: 10,
    });
  }
  return pool;
}
