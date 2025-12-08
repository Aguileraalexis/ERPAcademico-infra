import { CognitoIdentityProviderClient, AdminCreateUserCommand, AdminSetUserPasswordCommand } from "@aws-sdk/client-cognito-identity-provider";
import crypto from "crypto";
import { getConfig } from "./config";

const client = new CognitoIdentityProviderClient({});

export function generateStrongPassword(): string {
  // 14 chars: mezcla de tipos
  const base = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*()_+";
  let pwd = "";
  for (let i = 0; i < 14; i++) {
    const idx = crypto.randomInt(0, base.length);
    pwd += base[idx];
  }
  return pwd;
}

export async function createUserInCognito(email: string): Promise<string> {
  const cfg = getConfig();
  if (!cfg.userPoolId) throw new Error("USER_POOL_ID not configured");

  const password = generateStrongPassword();

  await client.send(new AdminCreateUserCommand({
    UserPoolId: cfg.userPoolId,
    Username: email,
    UserAttributes: [
      { Name: "email", Value: email },
      { Name: "email_verified", Value: "true" },
    ],
    MessageAction: "SUPPRESS",
  }));

  await client.send(new AdminSetUserPasswordCommand({
    UserPoolId: cfg.userPoolId,
    Username: email,
    Password: password,
    Permanent: true,
  }));

  return password;
}
