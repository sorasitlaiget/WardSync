import { FirebaseFirestore } from '@firebase/app-types';

export type MedicationStatus = 'inStock' | 'lowStock' | 'outOfStock';

export interface Medication {
  id: string;
  name: string;
  dosage: string;
  quantity: number;
  lowStockThreshold: number;
  status: MedicationStatus;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

export interface CreateMedicationDto {
  name: string;
  dosage: string;
  quantity: number;
  lowStockThreshold?: number;
}

export interface UpdateMedicationDto {
  name?: string;
  dosage?: string;
  lowStockThreshold?: number;
}

export interface UpdateStockDto {
  delta: number;
}

export interface TreatmentMedication {
  medicationId: string;
  name: string;
  dosage: string;
}
