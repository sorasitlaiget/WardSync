import { Router } from 'express';
import { authenticate, requireRole } from '../../middleware/auth.middleware';
import * as ctrl from './patients.controller';
import { uploadMiddleware } from './patients.upload';

const router = Router();

// nurse สร้าง patient (พร้อมรูปถ้ามี)
router.post('/', authenticate, requireRole('nurse'), uploadMiddleware, ctrl.createPatient);

// ทุก role ดูได้
router.get('/', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.listPatients);
router.get('/:id', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.getPatient);

// doctor เท่านั้น
router.patch('/:id/status', authenticate, requireRole('doctor'), ctrl.updatePatientStatus);
router.post('/:id/vitals', authenticate, requireRole('doctor'), ctrl.addVitalSigns);
router.post('/:id/treatments', authenticate, requireRole('doctor'), ctrl.addTreatment);

export default router;
