import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { authRouter } from './routes/auth.js';
import { groupRouter } from './routes/groups.js';
import { studentRouter } from './routes/students.js';
import { tutorRouter } from './routes/tutors.js';
import { uploadRouter } from './routes/uploads.js';

dotenv.config();

const app = express();
app.use(cors({ origin: process.env.CORS_ORIGIN || '*' }));
app.use(express.json());
app.use(morgan('dev'));
app.use('/uploads', express.static('uploads'));

app.get('/health', (_req, res) => res.json({ ok: true }));
app.use('/auth', authRouter);
app.use('/groups', groupRouter);
app.use('/students', studentRouter);
app.use('/tutor', tutorRouter);
app.use('/uploads', uploadRouter);

// basic error handler
app.use((err, req, res, _next) => {
  console.error(err);
  const status = err.status || 400;
  res.status(status).json({ message: err.message || 'Server error' });
});

const port = process.env.PORT || 4000;
app.listen(port, () => {
  console.log(`TutorTrack API listening on ${port}`);
});
