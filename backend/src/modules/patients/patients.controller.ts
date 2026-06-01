import { Request, Response, NextFunction } from 'express';
import * as patientsService from './patients.service';
import { uploadToStorage } from './patients.upload';
import {
  CreatePatientDto,
  UpdatePatientStatusDto,
  AddVitalSignsDto,
  AddTreatmentDto,
} from './patients.types';
import { TriageRoom } from '../users/users.types';

export async function createPatient(req: Request, res: Response, next: NextFunction) {
  try {
    const dto = req.body as CreatePatientDto;
    if (req.file) {
      dto.photoUrl = await uploadToStorage(req.file);
    }
    const patient = await patientsService.createPatient(dto, req.user!.uid);
    res.status(201).json(patient);
  } catch (err) {
    next(err);
  }
}

export async function listPatients(req: Request, res: Response, next: NextFunction) {
  try {
    const room = req.query.room as TriageRoom | undefined;
    const status = req.query.status as string | undefined;
    const patients = await patientsService.listPatients(room, status);
    res.json(patients);
  } catch (err) {
    next(err);
  }
}

export async function getPatient(req: Request, res: Response, next: NextFunction) {
  try {
    const patient = await patientsService.getPatient(req.params.id);
    res.json(patient);
  } catch (err) {
    next(err);
  }
}

export async function updatePatientStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const dto = req.body as UpdatePatientStatusDto;
    const patient = await patientsService.updatePatientStatus(req.params.id, dto);
    res.json(patient);
  } catch (err) {
    next(err);
  }
}

export async function addVitalSigns(req: Request, res: Response, next: NextFunction) {
  try {
    const dto = req.body as AddVitalSignsDto;
    const patient = await patientsService.addVitalSigns(req.params.id, dto, req.user!.uid);
    res.status(201).json(patient);
  } catch (err) {
    next(err);
  }
}

export async function addTreatment(req: Request, res: Response, next: NextFunction) {
  try {
    const dto = req.body as AddTreatmentDto;
    const patient = await patientsService.addTreatment(req.params.id, dto, req.user!.uid);
    res.status(201).json(patient);
  } catch (err) {
    next(err);
  }
}
