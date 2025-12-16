import { z } from 'zod';
import { comparePassword, hashPassword, signJwt } from '../utils/security.js';
import { createUser, findUserByEmail } from '../models/userModel.js';

const registerSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(6),
  role: z.enum(['student', 'tutor']),
});

export async function registerUser(body) {
  const data = registerSchema.parse(body);
  const existing = await findUserByEmail(data.email);
  if (existing) throw new Error('Email already used');
  const passwordHash = await hashPassword(data.password);
  const user = await createUser({
    name: data.name,
    email: data.email,
    passwordHash,
    role: data.role,
  });
  const token = signJwt({ id: user.id, role: user.role, email: user.email });
  return { user, token };
}

export async function loginUser({ email, password }) {
  const user = await findUserByEmail(email);
  if (!user) throw new Error('Invalid credentials');
  const valid = await comparePassword(password, user.password);
  if (!valid) throw new Error('Invalid credentials');
  const token = signJwt({ id: user.id, role: user.role, email: user.email });
  return {
    user: { id: user.id, name: user.name, email: user.email, role: user.role },
    token,
  };
}
