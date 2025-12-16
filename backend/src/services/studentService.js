import { z } from 'zod';
import {
  countJustificationsForTerm,
  createJustification,
  createMood,
  createPerception,
  listJustifications,
  listMood,
  listPerceptions,
} from '../models/studentModel.js';
import { studentGroupForTerm } from '../models/groupModel.js';

const moodSchema = z.object({ emoji: z.string().min(1), note: z.string().optional() });
const perceptionSchema = z.object({ subject: z.string().min(2), perception: z.string().min(2) });
const justificationSchema = z.object({
  reason: z.string().min(3),
  evidenceUrl: z.string().url(),
});

export async function submitMood(body, studentId) {
  const data = moodSchema.parse(body);
  try {
    await createMood({ studentId, emoji: data.emoji, note: data.note });
  } catch (e) {
    if (e?.code === 'ER_DUP_ENTRY') {
      const err = new Error('Ya registraste tu estado de ánimo hoy');
      err.status = 400;
      throw err;
    }
    throw e;
  }
  return { ok: true };
}

export async function submitPerception(body, studentId) {
  const data = perceptionSchema.parse(body);
  await createPerception({
    studentId,
    subject: data.subject,
    perception: data.perception,
  });
  return { ok: true };
}

export async function submitJustification(body, studentId) {
  const data = justificationSchema.parse(body);
  const currentGroup = await studentGroupForTerm(studentId, null);
  const term = currentGroup?.term || 'default';
  const count = await countJustificationsForTerm(studentId, term);
  if (count >= 2) throw new Error('Límite de justificantes alcanzado');
  const id = await createJustification({
    studentId,
    reason: data.reason,
    evidenceUrl: data.evidenceUrl,
    term,
  });
  return { id };
}

export async function moodHistory(studentId) {
  return listMood(studentId);
}

export async function perceptionHistory(studentId) {
  return listPerceptions(studentId);
}

export async function justificationHistory(studentId) {
  return listJustifications(studentId);
}
