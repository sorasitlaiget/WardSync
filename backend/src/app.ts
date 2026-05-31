import express, { Express, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { env } from './config/env.config';
import { errorHandler, notFoundHandler } from './middleware/error-handler.middleware';
import { logger } from './core/utils/logger';

export function createApp(): Express {
  const app = express();

  // Security
  app.use(helmet());

  // CORS
  app.use(
    cors({
      origin: env.corsOrigin,
      credentials: true,
    })
  );

  // Body parsing
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // Logging (HTTP requests)
  app.use(
    morgan('dev', {
      stream: { write: (msg) => logger.debug(msg.trim()) },
    })
  );

  // Health check
  app.get('/health', (_req: Request, res: Response) => {
    res.json({
      status: 'ok',
      service: 'wardsync-backend',
      timestamp: new Date().toISOString(),
    });
  });

  // Welcome
  app.get('/', (_req: Request, res: Response) => {
    res.json({
      message: 'WardSync Backend API',
      version: '1.0.0',
      docs: '/api/docs',
    });
  });

  // Register module routes — uncomment as each module is built
  // app.use('/api/users', userRoutes);
  // app.use('/api/patients', patientRoutes);
  // app.use('/api/vital-signs', vitalSignsRoutes);
  // app.use('/api/treatments', treatmentRoutes);
  // app.use('/api/notifications', notificationRoutes);

  // Usage pattern for protected routes:
  // import { authenticate, requireRole } from './middleware/auth.middleware';
  // router.get('/', authenticate, handler);                          // any logged-in user
  // router.post('/', authenticate, requireRole('nurse'), handler);   // nurse only
  // router.patch('/', authenticate, requireRole('doctor'), handler); // doctor only
  // router.get('/dashboard', authenticate, requireRole('admin'), handler); // admin only

  // 404 handler (must be after all routes)
  app.use(notFoundHandler);

  // Error handler (must be LAST)
  app.use(errorHandler);

  return app;
}
