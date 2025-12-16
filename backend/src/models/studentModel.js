import { pool } from '../config/db.js';

export async function createMood({ studentId, emoji, note }) {
  await pool.query(
    'INSERT INTO mood_entries (student_id, emoji, note) VALUES (?, ?, ?)',
    [studentId, emoji, note]
  );
}

export async function listMood(studentId) {
  const [rows] = await pool.query(
    'SELECT emoji, note, created_at as date FROM mood_entries WHERE student_id = ? ORDER BY created_at DESC',
    [studentId]
  );
  return rows;
}

export async function createPerception({ studentId, subject, perception }) {
  await pool.query(
    'INSERT INTO perception_entries (student_id, subject, perception) VALUES (?, ?, ?)',
    [studentId, subject, perception]
  );
}

export async function listPerceptions(studentId) {
  const [rows] = await pool.query(
    'SELECT subject, perception, week_of as weekOf FROM perception_entries WHERE student_id = ? ORDER BY week_of DESC',
    [studentId]
  );
  return rows;
}

export async function createJustification({ studentId, reason, evidenceUrl, term }) {
  const [result] = await pool.query(
    'INSERT INTO justifications (student_id, reason, evidence_url, term) VALUES (?, ?, ?, ?)',
    [studentId, reason, evidenceUrl, term]
  );
  return result.insertId;
}

export async function listJustifications(studentId) {
  const [rows] = await pool.query(
    'SELECT id, reason, evidence_url as evidenceUrl, status FROM justifications WHERE student_id = ? ORDER BY created_at DESC',
    [studentId]
  );
  return rows;
}

export async function countJustificationsForTerm(studentId, term) {
  const [rows] = await pool.query(
    'SELECT COUNT(*) as total FROM justifications WHERE student_id = ? AND term = ?',
    [studentId, term]
  );
  return rows[0]?.total ?? 0;
}
