import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import { parse } from 'url';

dotenv.config();

const databaseUrl = process.env.DATABASE_URL;

function createPool() {
  if (!databaseUrl) {
    throw new Error('DATABASE_URL is required');
  }
  const parsed = parse(databaseUrl);
  const [user, password] = (parsed.auth || '').split(':');
  const db = (parsed.path || '').replace('/', '');

  return mysql.createPool({
    host: parsed.hostname,
    port: parsed.port ? Number(parsed.port) : 3306,
    user,
    password,
    database: db,
    waitForConnections: true,
    ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
    connectionLimit: 10,
  });
}

export const pool = createPool();
