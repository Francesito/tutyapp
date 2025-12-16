import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const databaseUrl = process.env.DATABASE_URL;

function createPool() {
  if (!databaseUrl) {
    throw new Error('DATABASE_URL is required');
  }

  const url = new URL(databaseUrl);
  const useSsl =
    process.env.DB_SSL === 'true' ||
    url.searchParams.get('ssl-mode')?.toLowerCase() === 'required';

  return mysql.createPool({
    host: url.hostname,
    port: url.port ? Number(url.port) : 3306,
    user: decodeURIComponent(url.username),
    password: decodeURIComponent(url.password),
    database: url.pathname.replace('/', ''),
    waitForConnections: true,
    ssl: useSsl ? { rejectUnauthorized: false } : undefined,
    connectionLimit: 10,
  });
}

export const pool = createPool();
