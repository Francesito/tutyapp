import express from 'express';
import asyncHandler from 'express-async-handler';
import { requireAuth, requireRole } from '../middlewares/auth.js';
import {
  fetchAlerts,
  tutorPanel,
  updateJustificationStatus,
  listTutorGroupsWithMembers,
  listTutorJustifications,
} from '../services/tutorService.js';

export const tutorRouter = express.Router();

tutorRouter.use(requireAuth, requireRole('tutor'));

tutorRouter.get(
  '/alerts',
  asyncHandler(async (req, res) => {
    const items = await fetchAlerts(req.user.id);
    res.json({ items });
  })
);

tutorRouter.get(
  '/panel',
  asyncHandler(async (req, res) => {
    const data = await tutorPanel(req.user.id);
    res.json(data);
  })
);

tutorRouter.post(
  '/justifications',
  asyncHandler(async (req, res) => {
    const { id, status } = req.body;
    const data = await updateJustificationStatus({ id, status });
    res.json(data);
  })
);

tutorRouter.get(
  '/groups',
  asyncHandler(async (req, res) => {
    const items = await listTutorGroupsWithMembers(req.user.id);
    res.json({ items });
  })
);

tutorRouter.get(
  '/justifications',
  asyncHandler(async (req, res) => {
    const items = await listTutorJustifications(req.user.id);
    res.json({ items });
  })
);
