import { Request, Response, NextFunction } from 'express';
import * as svc from './patients.service';
import { uploadToStorage } from './patients.upload';
import {
  CreatePatientDto,
  UpdatePatientStatusDto,
  AddVitalSignsDto,
  AddTreatmentDto,
  UpdateVitalSignsDto,
  UpdateTreatmentDto,
} from './patients.types';
import { TriageRoom } from '../users/users.types';

export async function createPatient(req: Request, res: Response, next: NextFunction) {
  try {
    const dto = req.body as CreatePatientDto;
    if (req.file) dto.photoUrl = await uploadToStorage(req.file);
    res.status(201).json(await svc.createPatient(dto, req.user!.uid));
  } catch (err) { next(err); }
}

export async function listPatients(req: Request, res: Response, next: NextFunction) {
  try {
    const user = req.user!;
    const queryRoom = req.query.room as string | undefined;
    const status = req.query.status as string | undefined;
    const triageColor = req.query.triageColor as TriageRoom | undefined;
    const wristband = req.query.wristband as string | undefined;
    const today = req.query.today === 'true';
    const fromTime = req.query.fromTime ? new Date(req.query.fromTime as string) : undefined;
    const toTime = req.query.toTime ? new Date(req.query.toTime as string) : undefined;

    let room: TriageRoom | 'all' | undefined;
    if (user.role === 'doctor') {
      if (!user.assignedRoom) {
        res.json({ patients: [], warning: 'Doctor has no assigned room' });
        return;
      }
      room = queryRoom === 'all' ? 'all' : (user.assignedRoom as TriageRoom);
    } else {
      room = queryRoom as TriageRoom | 'all' | undefined;
    }
    res.json(await svc.listPatients(room, status, triageColor, wristband, today, fromTime, toTime));
  } catch (err) { next(err); }
}

export async function getPatientStats(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.getPatientStats());
  } catch (err) { next(err); }
}

export async function getPatient(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.getPatient(req.params.id));
  } catch (err) { next(err); }
}

export async function updatePatientStatus(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.updatePatientStatus(req.params.id, req.body as UpdatePatientStatusDto, req.user!.uid));
  } catch (err) { next(err); }
}

export async function updatePatientRoom(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.updatePatientRoom(req.params.id, req.body, req.user!.uid));
  } catch (err) { next(err); }
}

// ── Vital Signs ──────────────────────────────────────────────

export async function addVitalSigns(req: Request, res: Response, next: NextFunction) {
  try {
    res.status(201).json(await svc.addVitalSigns(req.params.id, req.body as AddVitalSignsDto, req.user!.uid));
  } catch (err) { next(err); }
}

export async function listVitalSigns(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.listVitalSigns(req.params.id));
  } catch (err) { next(err); }
}

export async function updateVitalSigns(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.updateVitalSigns(req.params.id, req.params.vitalId, req.body as UpdateVitalSignsDto));
  } catch (err) { next(err); }
}

export async function deleteVitalSigns(req: Request, res: Response, next: NextFunction) {
  try {
    await svc.deleteVitalSigns(req.params.id, req.params.vitalId);
    res.status(204).send();
  } catch (err) { next(err); }
}

// ── Treatments ───────────────────────────────────────────────

export async function addTreatment(req: Request, res: Response, next: NextFunction) {
  try {
    res.status(201).json(await svc.addTreatment(req.params.id, req.body as AddTreatmentDto, req.user!.uid));
  } catch (err) { next(err); }
}

export async function listTreatments(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.listTreatments(req.params.id));
  } catch (err) { next(err); }
}

export async function updateTreatment(req: Request, res: Response, next: NextFunction) {
  try {
    res.json(await svc.updateTreatment(req.params.id, req.params.treatmentId, req.body as UpdateTreatmentDto));
  } catch (err) { next(err); }
}

export async function deleteTreatment(req: Request, res: Response, next: NextFunction) {
  try {
    await svc.deleteTreatment(req.params.id, req.params.treatmentId);
    res.status(204).send();
  } catch (err) { next(err); }
}
