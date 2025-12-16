import express from 'express';
import asyncHandler from 'express-async-handler';
import { requireAuth, requireRole } from '../middlewares/auth.js';
import { handleCreateGroup, handleJoinGroup } from '../services/groupService.js';

export const groupRouter = express.Router();

groupRouter.post(
  '/',
  requireAuth,
  requireRole('tutor'),
  asyncHandler(async (req, res) => {
    const result = await handleCreateGroup(req.body, req.user.id);
    res.json(result);
  })
);

groupRouter.post(
  '/join',
  requireAuth,
  requireRole('student'),
  asyncHandler(async (req, res) => {
    const result = await handleJoinGroup(req.body, req.user.id);
    res.json(result);
  })
);
