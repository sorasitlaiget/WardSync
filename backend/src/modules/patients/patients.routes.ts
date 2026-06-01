import { Router } from 'express';
import { authenticate, requireRole } from '../../middleware/auth.middleware';
import * as ctrl from './patients.controller';
import { uploadMiddleware } from './patients.upload';

const router = Router();

// ── Patients ─────────────────────────────────────────────────
router.post('/', authenticate, requireRole('nurse'), uploadMiddleware, ctrl.createPatient);
router.get('/stats', authenticate, requireRole('admin'), ctrl.getPatientStats);
router.get('/', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.listPatients);
router.get('/:id', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.getPatient);
router.patch('/:id/status', authenticate, requireRole('doctor'), ctrl.updatePatientStatus);

// ── Vital Signs ──────────────────────────────────────────────
router.post('/:id/vitals', authenticate, requireRole('nurse', 'doctor'), ctrl.addVitalSigns);
router.get('/:id/vitals', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.listVitalSigns);
router.patch('/:id/vitals/:vitalId', authenticate, requireRole('nurse', 'doctor'), ctrl.updateVitalSigns);
router.delete('/:id/vitals/:vitalId', authenticate, requireRole('nurse', 'doctor'), ctrl.deleteVitalSigns);

// ── Treatments ───────────────────────────────────────────────
router.post('/:id/treatments', authenticate, requireRole('doctor'), ctrl.addTreatment);
router.get('/:id/treatments', authenticate, requireRole('nurse', 'doctor', 'admin'), ctrl.listTreatments);
router.patch('/:id/treatments/:treatmentId', authenticate, requireRole('doctor'), ctrl.updateTreatment);
router.delete('/:id/treatments/:treatmentId', authenticate, requireRole('doctor'), ctrl.deleteTreatment);

export default router;
