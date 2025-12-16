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
     FROM \`groups\` g LEFT JOIN group_members gm ON gm.group_id = g.id
     WHERE g.tutor_id = ? GROUP BY g.id LIMIT 1`,
    [tutorId]
  );
  return rows[0] || {};
}

export async function updateJustificationStatus({ id, status }) {
  await pool.query('UPDATE justifications SET status = ? WHERE id = ?', [status, id]);
  return { id, status };
}

export async function listTutorGroupsWithMembers(tutorId) {
  const [rows] = await pool.query(
    `SELECT g.id as groupId, g.code, g.term, u.id as studentId, u.name, u.email
     FROM \`groups\` g
     LEFT JOIN group_members gm ON gm.group_id = g.id
     LEFT JOIN users u ON u.id = gm.student_id
     WHERE g.tutor_id = ?
     ORDER BY g.code, u.name`,
    [tutorId]
  );
  return rows;
}

export async function listTutorJustifications(tutorId) {
  const [rows] = await pool.query(
    `SELECT j.id, j.reason, j.evidence_url as evidenceUrl, j.status, j.created_at as createdAt,
            u.name as studentName, u.email as studentEmail, g.code as groupCode
     FROM justifications j
     JOIN users u ON u.id = j.student_id
     LEFT JOIN group_members gm ON gm.student_id = j.student_id
     LEFT JOIN \`groups\` g ON g.id = gm.group_id
     WHERE g.tutor_id = ?
     ORDER BY j.created_at DESC LIMIT 100`,
    [tutorId]
  );
  return rows;
}
