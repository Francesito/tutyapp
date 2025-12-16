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
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import PDFDocument from 'pdfkit';

dotenv.config();

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

// helper middleware: allows token via header (normal) or ?token=... for downloads
function authFromHeaderOrQuery(req, res, next) {
  const header = req.headers.authorization;
  const queryToken = req.query.token;
  if (!header && !queryToken) return res.status(401).json({ message: 'No token' });
  const token = header?.split(' ')[1] || queryToken;
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    if (payload.role !== 'tutor') return res.status(403).json({ message: 'Forbidden' });
    req.user = payload;
    next();
  } catch (e) {
    return res.status(401).json({ message: 'Invalid token' });
  }
}

tutorRouter.get(
  '/reports/pdf',
  authFromHeaderOrQuery,
  asyncHandler(async (req, res) => {
    const summary = await tutorPanel(req.user.id);
    const doc = new PDFDocument();
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename="reporte.pdf"');
    doc.pipe(res);
    doc.fontSize(18).text('Reporte Tuty');
    doc.moveDown();
    doc.fontSize(12).text(`Grupo: ${summary.code ?? 'N/A'}`);
    doc.text(`Estudiantes: ${summary.students ?? 0}`);
    doc.end();
  })
);

tutorRouter.get(
  '/reports/excel',
  authFromHeaderOrQuery,
  asyncHandler(async (req, res) => {
    const summary = await tutorPanel(req.user.id);
    const csv = 'grupo,estudiantes\n' + `${summary.code ?? ''},${summary.students ?? 0}\n`;
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="reporte.csv"');
    res.send(csv);
  })
);
