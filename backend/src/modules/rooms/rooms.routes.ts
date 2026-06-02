import { Router } from 'express';
import { authenticate, requireRole } from '../../middleware/auth.middleware';
import * as ctrl from './rooms.controller';

const router = Router();

router.get('/capacity', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.getAllRoomCapacity);
router.get('/capacity/:room', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.getRoomCapacity);
router.put('/capacity/:room', authenticate, requireRole('admin'), ctrl.setRoomCapacity);

export default router;
