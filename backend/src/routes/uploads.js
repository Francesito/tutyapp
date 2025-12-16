import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { requireAuth, requireRole } from '../middlewares/auth.js';

const uploadDir = 'uploads';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
  destination: function (_req, _file, cb) {
    cb(null, uploadDir);
  },
  filename: function (_req, file, cb) {
    const ext = path.extname(file.originalname).toLowerCase();
    const name = `${Date.now()}-${Math.round(Math.random() * 1e6)}${ext}`;
    cb(null, name);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    if (ext !== '.jpg' && ext !== '.jpeg') {
      return cb(new Error('Solo se permiten JPG (<2MB)'));
    }
    cb(null, true);
  },
});

export const uploadRouter = express.Router();

uploadRouter.post(
  '/justification-image',
  requireAuth,
  requireRole('student'),
  upload.single('file'),
  (req, res) => {
    const base = process.env.FILE_BASE_URL || `${req.protocol}://${req.get('host')}`;
    const url = `${base}/uploads/${req.file.filename}`;
    res.json({ url });
  }
);
