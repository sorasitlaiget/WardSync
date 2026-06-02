import { Router } from 'express';
import { authenticate, requireRole } from '../../middleware/auth.middleware';
import * as ctrl from './medications.controller';

const router = Router();

router.post('/', authenticate, requireRole('admin'), ctrl.createMedication);
router.get('/', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.listMedications);
router.get('/:id', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.getMedication);
router.patch('/:id', authenticate, requireRole('admin'), ctrl.updateMedication);
router.delete('/:id', authenticate, requireRole('admin'), ctrl.deleteMedication);
router.patch('/:id/stock', authenticate, requireRole('admin'), ctrl.updateStock);

export default router;
