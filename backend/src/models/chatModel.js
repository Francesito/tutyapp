import { pool } from '../config/db.js';

export async function saveMessage({ groupId, userId, message }) {
  await pool.query(
    'INSERT INTO chat_messages (group_id, user_id, message) VALUES (?, ?, ?)',
    [groupId, userId, message]
  );
}

export async function listMessages(groupId, limit = 100) {
  const [rows] = await pool.query(
    `SELECT m.id, m.message, m.created_at as createdAt, u.name, u.email, u.role
     FROM chat_messages m JOIN users u ON u.id = m.user_id
     WHERE m.group_id = ? ORDER BY m.created_at DESC LIMIT ?`,
    [groupId, limit]
  );
  return rows.reverse();
}
