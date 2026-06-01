import { TriageRoom } from '../users/users.types';

export type PatientStatus = 'waiting' | 'inTreatment' | 'discharged' | 'deceased';
export type Sex = 'male' | 'female';
export type AgeRange = 'infant' | 'child' | 'adult' | 'elder';

export interface VitalSigns {
  id: string;
  bloodPressure: string;
  heartRate: number;
  respiratoryRate: number;
  temperature: number;
  oxygenSaturation: number;
  recordedAt: FirebaseFirestore.Timestamp;
  recordedBy: string;
}

export interface Treatment {
  id: string;
  diagnosis: string;
  treatment: string;
  notes?: string;
  recordedAt: FirebaseFirestore.Timestamp;
  recordedBy: string;
}

export interface Patient {
  id: string;
  wristbandNumber: string;
  triageColor: TriageRoom;
  photoUrl: string | null;
  sex: Sex;
  ageRange: AgeRange;
  status: PatientStatus;
  assignedRoom: TriageRoom;
  statusHistory: StatusLog[];
  createdBy: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

export interface CreatePatientDto {
  wristbandNumber: string;
  triageColor: TriageRoom;
  photoUrl?: string;
  sex: Sex;
  ageRange: AgeRange;
}

export interface StatusLog {
  status: PatientStatus;
  changedBy: string;
  changedAt: FirebaseFirestore.Timestamp;
}

export interface UpdatePatientStatusDto {
  status: PatientStatus;
}

export interface AddVitalSignsDto {
  bloodPressure: string;
  heartRate: number;
  respiratoryRate: number;
  temperature: number;
  oxygenSaturation: number;
}

export interface AddTreatmentDto {
  diagnosis: string;
  treatment: string;
  notes?: string;
}

export interface UpdateVitalSignsDto {
  bloodPressure?: string;
  heartRate?: number;
  respiratoryRate?: number;
  temperature?: number;
  oxygenSaturation?: number;
}

export interface UpdateTreatmentDto {
  diagnosis?: string;
  treatment?: string;
  notes?: string;
}
