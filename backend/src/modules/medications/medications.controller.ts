import { Request, Response, NextFunction } from 'express';
import * as svc from './medications.service';
import { CreateMedicationDto, UpdateMedicationDto, UpdateStockDto } from './medications.types';

export async function createMedication(req: Request, res: Response, next: NextFunction) {
  try {
    res.status(201).json(await svc.createMedication(req.body as CreateMedicationDto));
  } catch (err) { next(err); }
}

export async function listMedications(req: Request, res: Response, next: NextFunction) {
  try {
    const search = req.query.search as string | undefined;
    res.json(await svc.listMedications(search));
  } catch (err) { next(err); }
}

export async function getMedication(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.getMedication(req.params.id));
  } catch (err) { next(err); }
}

export async function updateMedication(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.updateMedication(req.params.id, req.body as UpdateMedicationDto));
  } catch (err) { next(err); }
}

export async function deleteMedication(req: Request, res: Response, next: NextFunction) {
  try {
    await svc.deleteMedication(req.params.id);
    res.status(204).send();
  } catch (err) { next(err); }
}

export async function updateStock(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.updateStock(req.params.id, req.body as UpdateStockDto));
  } catch (err) { next(err); }
}
