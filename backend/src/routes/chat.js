import express from 'express';
import asyncHandler from 'express-async-handler';
import { requireAuth } from '../middlewares/auth.js';
import { listMessages, saveMessage } from '../models/chatModel.js';
import { studentGroupForTerm, findGroupByCode } from '../models/groupModel.js';

export const chatRouter = express.Router();

chatRouter.use(requireAuth);

// GET /chat?groupCode=... (tutor) or without for student (uses membership)
chatRouter.get(
  '/',
  asyncHandler(async (req, res) => {
    let groupId;
    if (req.user.role === 'tutor') {
      const code = req.query.groupCode;
      if (!code) return res.status(400).json({ message: 'groupCode requerido' });
      const group = await findGroupByCode(code);
      if (!group || group.tutor_id !== req.user.id) {
        return res.status(404).json({ message: 'Grupo no encontrado' });
      }
      groupId = group.id;
    } else {
      const group = await studentGroupForTerm(req.user.id, null);
      if (!group) return res.status(400).json({ message: 'Únete a un grupo para chatear' });
      groupId = group.id;
    }
    const items = await listMessages(groupId);
    res.json({ items });
  })
);

chatRouter.post(
  '/',
  asyncHandler(async (req, res) => {
    const message = (req.body.message || '').toString();
    if (!message.trim()) return res.status(400).json({ message: 'Mensaje vacío' });
    let groupId;
    if (req.user.role === 'tutor') {
      const code = req.body.groupCode;
      if (!code) return res.status(400).json({ message: 'groupCode requerido' });
      const group = await findGroupByCode(code);
      if (!group || group.tutor_id !== req.user.id) {
        return res.status(404).json({ message: 'Grupo no encontrado' });
      }
      groupId = group.id;
    } else {
      const group = await studentGroupForTerm(req.user.id, null);
      if (!group) return res.status(400).json({ message: 'Únete a un grupo para chatear' });
      groupId = group.id;
    }
    await saveMessage({ groupId, userId: req.user.id, message });
    res.json({ ok: true });
  })
);

