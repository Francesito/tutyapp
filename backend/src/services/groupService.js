import { z } from 'zod';
import {
  addStudentToGroup,
  createGroup,
  findGroupByCode,
  removeStudentFromGroups,
  groupSummaryForTutor,
  studentGroupForTerm,
} from '../models/groupModel.js';

const createGroupSchema = z.object({
  code: z.string().min(4),
  term: z.string().min(3),
});

export async function handleCreateGroup(body, tutorId) {
  const data = createGroupSchema.parse(body);
  const exists = await findGroupByCode(data.code);
  if (exists) throw new Error('Código duplicado');
  await createGroup({ code: data.code, term: data.term, tutorId });
  return { code: data.code, term: data.term };
}

const joinSchema = z.object({ code: z.string().min(3) });

export async function handleJoinGroup(body, studentId) {
  const data = joinSchema.parse(body);
  const group = await findGroupByCode(data.code);
  if (!group) throw new Error('Grupo no encontrado');
  const existing = await studentGroupForTerm(studentId, group.term);
  if (existing) throw new Error('Alumno ya está en un grupo para el mismo término');
  await addStudentToGroup({ studentId, groupId: group.id });
  return { groupId: group.id };
}

export async function handleLeaveGroup(studentId) {
  await removeStudentFromGroups(studentId);
  return { ok: true };
}

export async function tutorGroups(tutorId) {
  return groupSummaryForTutor(tutorId);
}
