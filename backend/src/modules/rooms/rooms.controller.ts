import { Request, Response, NextFunction } from 'express';
import * as svc from './rooms.service';
import { SetRoomCapacityDto } from './rooms.types';

export async function getAllRoomCapacity(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.getAllRoomCapacity());
  } catch (err) { next(err); }
}

export async function getRoomCapacity(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.getRoomCapacity(req.params.room));
  } catch (err) { next(err); }
}

export async function setRoomCapacity(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.setRoomCapacity(req.params.room, req.body as SetRoomCapacityDto, req.user!.uid));
  } catch (err) { next(err); }
}
