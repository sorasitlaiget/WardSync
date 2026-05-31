import { UserRole } from '../../modules/users/users.types';

declare global {
  namespace Express {
    interface Request {
      user?: {
        uid: string;
        email?: string;
        role: UserRole;
        assignedRoom?: string; // for doctors
      };
    }
  }
}

export {};
