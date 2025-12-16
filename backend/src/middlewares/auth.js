import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

export function requireAuth(req, res, next) {
  const header = req.headers.authorization;
  const queryToken = req.query.token;
  const token = header?.split(' ')[1] || queryToken;
  if (!token) return res.status(401).json({ message: 'No token' });
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = payload;
    return next();
  } catch (e) {
    return res.status(401).json({ message: 'Invalid token' });
  }
}

export function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ message: 'Unauthenticated' });
    if (req.user.role !== role) {
      return res.status(403).json({ message: 'Forbidden' });
    }
    return next();
  };
}
