export interface AppConfig {
  dbHost: string;
  dbUser: string;
  dbPassword: string;
  dbName: string;
  entityName?: string;
  qCmPdfUrl?: string;
  qUserCreateUrl?: string;
  qUserPasswordEmailUrl?: string;
  certMatriculaBucket?: string;
  smtpFromEmail?: string;
  systemBaseUrl?: string;
  userPoolId?: string;
}

export function getConfig(): AppConfig {
  return {
    dbHost: process.env.DB_HOST!,
    dbUser: process.env.DB_USER ?? "erp_academico_root",
    dbPassword: process.env.DB_PASSWORD!,
    dbName: process.env.DB_NAME ?? "erp_academico",
    entityName: process.env.ENTITY_NAME,
    qCmPdfUrl: process.env.Q_CM_PDF_URL,
    qUserCreateUrl: process.env.Q_USER_CREATE,
    qUserPasswordEmailUrl: process.env.Q_USER_PASSWORD_EMAIL_URL,
    certMatriculaBucket: process.env.CERT_MATRICULA_BUCKET,
    smtpFromEmail: process.env.SMTP_FROM_EMAIL,
    systemBaseUrl: process.env.SYSTEM_BASE_URL,
    userPoolId: process.env.USER_POOL_ID
  };
}
