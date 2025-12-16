import { pool } from '../config/db.js';

export async function createGroup({ code, term, tutorId }) {
  const [result] = await pool.query(
    'INSERT INTO `groups` (code, term, tutor_id) VALUES (?, ?, ?)',
    [code, term, tutorId]
  );
  return result.insertId;
}

export async function findGroupByCode(code) {
  const [rows] = await pool.query('SELECT * FROM `groups` WHERE code = ?', [code]);
  return rows[0];
}

export async function addStudentToGroup({ studentId, groupId }) {
  await pool.query(
    'INSERT INTO group_members (group_id, student_id) VALUES (?, ?)',
    [groupId, studentId]
  );
}

export async function removeStudentFromGroups(studentId) {
  await pool.query('DELETE FROM group_members WHERE student_id = ?', [studentId]);
}

export async function studentGroupForTerm(studentId, term) {
  let sql =
    'SELECT g.* FROM group_members gm JOIN `groups` g ON gm.group_id = g.id WHERE gm.student_id = ?';
  const params = [studentId];
  if (term) {
    sql += ' AND g.term = ?';
    params.push(term);
  }
  sql += ' ORDER BY gm.created_at DESC LIMIT 1';
  const [rows] = await pool.query(sql, params);
  return rows[0];
}

export async function groupSummaryForTutor(tutorId) {
  const [rows] = await pool.query(
    'SELECT g.id, g.code, g.term, COUNT(gm.student_id) as students FROM `groups` g LEFT JOIN group_members gm ON gm.group_id = g.id WHERE g.tutor_id = ? GROUP BY g.id',
    [tutorId]
  );
  return rows;
}
