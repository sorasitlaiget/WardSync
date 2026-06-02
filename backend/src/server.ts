import { createApp } from './app';
import { env } from './config/env.config';
import { initFirebase } from './config/firebase.config';
import { logger } from './core/utils/logger';

async function bootstrap(): Promise<void> {
  try {
    // 1. Initialize Firebase Admin SDK
    initFirebase();

    // 2. Create Express app
    const app = createApp();

    // 3. Start server
    const server = app.listen(env.port, () => {
      logger.info(`🚀 WardSync Backend running on port ${env.port}`);
      logger.info(`📍 Environment: ${env.nodeEnv}`);
      logger.info(`🏥 Health check: http://localhost:${env.port}/health`);
      if (env.useFirebaseEmulator) {
        logger.info(`🔧 Emulator UI:  http://localhost:4000`);
      }
    });

    // Graceful shutdown
    const shutdown = (signal: string) => {
      logger.info(`Received ${signal}, shutting down gracefully...`);
      server.close(() => {
        logger.info('Server closed');
        process.exit(0);
      });
    };

    process.on('SIGTERM', () => shutdown('SIGTERM'));
    process.on('SIGINT', () => shutdown('SIGINT'));

    // Catch unhandled errors
    process.on('unhandledRejection', (reason) => {
      logger.error('Unhandled Promise Rejection:', reason);
    });

    process.on('uncaughtException', (error) => {
      logger.error('Uncaught Exception:', error);
      process.exit(1);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

bootstrap();
