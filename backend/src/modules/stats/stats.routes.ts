import { Router } from 'express';
import { authenticate, requireRole } from '../../middleware/auth.middleware';
import * as ctrl from './stats.controller';

const router = Router();

router.get('/charts', authenticate, requireRole('admin'), ctrl.getChartStats);

export default router;
