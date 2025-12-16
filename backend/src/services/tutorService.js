import { pool } from '../config/db.js';

export async function fetchAlerts(tutorId) {
  const [rows] = await pool.query(
    `SELECT a.id, a.type, a.message FROM alerts a
     JOIN \`groups\` g ON a.group_id = g.id
     WHERE g.tutor_id = ? ORDER BY a.created_at DESC LIMIT 50`,
    [tutorId]
  );
  return rows;
}

export async function tutorPanel(tutorId) {
  const [rows] = await pool.query(
    `SELECT g.code, COUNT(gm.student_id) as students
     FROM groups g LEFT JOIN group_members gm ON gm.group_id = g.id
     WHERE g.tutor_id = ? GROUP BY g.id LIMIT 1`,
    [tutorId]
  );
  return rows[0] || {};
}

export async function updateJustificationStatus({ id, status }) {
  await pool.query('UPDATE justifications SET status = ? WHERE id = ?', [status, id]);
  return { id, status };
}
