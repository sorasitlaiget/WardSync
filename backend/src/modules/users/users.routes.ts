import { Router } from 'express';
import { authenticate, requireRole } from '../../middleware/auth.middleware';
import * as ctrl from './users.controller';

const router = Router();

// ทุก role — ดู/แก้ไข profile ตัวเอง
router.get('/profile', authenticate, ctrl.getMyProfile);
router.patch('/profile', authenticate, ctrl.completeProfile);
router.patch('/fcm-token', authenticate, ctrl.updateFcmToken);

// admin only
router.get('/', authenticate, requireRole('admin'), ctrl.listUsers);
router.post('/', authenticate, requireRole('admin'), ctrl.createUser);
router.patch('/:uid/role', authenticate, requireRole('admin'), ctrl.updateUserRole);

export default router;
