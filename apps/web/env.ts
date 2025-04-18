import { z } from "zod";
import { parseEnv } from "znv";

const _POSTGRESS_USER = "myuser";
const _POSTGRESS_PASSWORD = "mypassword";
const _POSTGRESS_DB = "mydatabase";

function getDatabaseUrl(
  baseUrl: string,
  user: string,
  password: string,
  db: string,
  port: number,
) {
  return `${baseUrl}://${user}:${password}@db:${port}/${db}?schema=public`;
}

export default parseEnv(process.env, {
  NODE_ENV: z.string(),
  DATABASE_URL: z
    .string()
    .url()
    .default(
      getDatabaseUrl(
        "postgresql",
        _POSTGRESS_USER,
        _POSTGRESS_PASSWORD,
        _POSTGRESS_DB,
        5432,
      ),
    ),
  POSTGRES_DB: z.string().default(_POSTGRESS_DB),
  POSTGRES_USER: z.string().default(_POSTGRESS_USER),
  POSTGRES_PASSWORD: z.string().default(_POSTGRESS_PASSWORD),
  WEB_DOCKER_PORT: z.coerce.number().min(1024).max(65535),
});
