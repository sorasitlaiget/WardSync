import { Request, Response, NextFunction } from 'express';
import { auth, db } from '../config/firebase.config';
import { UnauthorizedError, ForbiddenError } from '../core/utils/error';
import { UserRole } from '../modules/users/users.types';

export async function authenticate(req: Request, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      throw new UnauthorizedError('Missing or invalid Authorization header');
    }

    const token = authHeader.slice(7);
    const decoded = await auth().verifyIdToken(token);

    const userDoc = await db().collection('users').doc(decoded.uid).get();
    if (!userDoc.exists) {
      throw new UnauthorizedError('User profile not found');
    }

    const userData = userDoc.data()!;
    req.user = {
      uid: decoded.uid,
      email: decoded.email,
      role: userData.role as UserRole,
      assignedRoom: userData.assignedRoom,
    };

    next();
  } catch (err) {
    next(err);
  }
}

// ใช้หลัง authenticate() เพื่อจำกัด role
export function requireRole(...roles: UserRole[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(new ForbiddenError('Insufficient permissions'));
    }
    next();
  };
}
