import { Request, Response, NextFunction } from 'express';
import { AppError, ValidationError } from '../core/utils/error';
import { logger } from '../core/utils/logger';
import { isDev } from '../config/env.config';

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void {
  // Log error
  logger.error(`${req.method} ${req.path} - ${err.message}`, {
    stack: isDev ? err.stack : undefined,
  });

  // Validation errors
  if (err instanceof ValidationError) {
    res.status(err.statusCode).json({
      error: err.message,
      fields: err.fields,
    });
    return;
  }

  // Known operational errors
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      error: err.message,
    });
    return;
  }

  // Unknown errors - don't leak details in production
  res.status(500).json({
    error: isDev ? err.message : 'Internal server error',
    ...(isDev && { stack: err.stack }),
  });
}

// 404 handler - register AFTER all routes
export function notFoundHandler(req: Request, res: Response): void {
  res.status(404).json({
    error: `Route not found: ${req.method} ${req.path}`,
  });
}
