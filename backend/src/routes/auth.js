import express from 'express';
import asyncHandler from 'express-async-handler';
import { loginUser, registerUser } from '../services/authService.js';

export const authRouter = express.Router();

authRouter.post(
  '/register',
  asyncHandler(async (req, res) => {
    const { user, token } = await registerUser(req.body);
    res.json({ user, token });
  })
);

authRouter.post(
  '/login',
  asyncHandler(async (req, res) => {
    const { user, token } = await loginUser(req.body);
    res.json({ user, token });
  })
);
