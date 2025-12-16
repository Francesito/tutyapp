import express from 'express';
import asyncHandler from 'express-async-handler';
import { requireAuth, requireRole } from '../middlewares/auth.js';
import {
  justificationHistory,
  moodHistory,
  perceptionHistory,
  submitJustification,
  submitMood,
  submitPerception,
} from '../services/studentService.js';

export const studentRouter = express.Router();

studentRouter.use(requireAuth, requireRole('student'));

studentRouter.post(
  '/mood',
  asyncHandler(async (req, res) => {
    const data = await submitMood(req.body, req.user.id);
    res.json(data);
  })
);

studentRouter.get(
  '/mood',
  asyncHandler(async (req, res) => {
    const items = await moodHistory(req.user.id);
    res.json({ items });
  })
);

studentRouter.post(
  '/perceptions',
  asyncHandler(async (req, res) => {
    const data = await submitPerception(req.body, req.user.id);
    res.json(data);
  })
);

studentRouter.get(
  '/perceptions',
  asyncHandler(async (req, res) => {
    const items = await perceptionHistory(req.user.id);
    res.json({ items });
  })
);

studentRouter.post(
  '/justifications',
  asyncHandler(async (req, res) => {
    const data = await submitJustification(req.body, req.user.id);
    res.json(data);
  })
);

studentRouter.get(
  '/justifications',
  asyncHandler(async (req, res) => {
    const items = await justificationHistory(req.user.id);
    res.json({ items });
  })
);
