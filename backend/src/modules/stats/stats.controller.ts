import { Request, Response, NextFunction } from 'express';
import * as svc from './stats.service';

export async function getChartStats(req: Request, res: Response, next: NextFunction) {
  try {
    const days = req.query.days ? parseInt(req.query.days as string, 10) : 7;
    const fromDate = req.query.fromDate ? new Date(req.query.fromDate as string) : undefined;
    const toDate = req.query.toDate ? new Date(req.query.toDate as string) : undefined;
    res.json(await svc.getChartStats(days, fromDate, toDate));
  } catch (err) { next(err); }
}
