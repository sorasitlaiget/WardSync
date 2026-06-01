import { db, FieldValue, Timestamp } from '../../config/firebase.config';
import { NotFoundError, BadRequestError } from '../../core/utils/error';
import { notifyAdminLowStock } from '../../core/utils/notification';
import {
  Medication,
  MedicationStatus,
  CreateMedicationDto,
  UpdateMedicationDto,
  UpdateStockDto,
  TreatmentMedication,
} from './medications.types';

const MEDICATIONS = 'medications';
const DEFAULT_LOW_STOCK_THRESHOLD = 10;

function computeStatus(quantity: number, threshold: number): MedicationStatus {
  if (quantity <= 0) return 'outOfStock';
  if (quantity <= threshold) return 'lowStock';
  return 'inStock';
}

export async function createMedication(dto: CreateMedicationDto): Promise<Medication> {
  const threshold = dto.lowStockThreshold ?? DEFAULT_LOW_STOCK_THRESHOLD;
  const status = computeStatus(dto.quantity, threshold);
  const now = FieldValue.serverTimestamp();
  const ref = db().collection(MEDICATIONS).doc();

  await ref.set({
    name: dto.name,
    dosage: dto.dosage,
    quantity: dto.quantity,
    lowStockThreshold: threshold,
    status,
    createdAt: now,
    updatedAt: now,
  });

  return getMedication(ref.id);
}

export async function listMedications(search?: string): Promise<Medication[]> {
  const snapshot = await db().collection(MEDICATIONS).orderBy('name').get();
  let meds = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as Medication);

  if (search) {
    const q = search.toLowerCase();
    meds = meds.filter((m) => m.name.toLowerCase().includes(q));
  }

  return meds;
}

export async function getMedication(id: string): Promise<Medication> {
  const doc = await db().collection(MEDICATIONS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Medication not found');
  return { id: doc.id, ...doc.data() } as Medication;
}

export async function updateMedication(id: string, dto: UpdateMedicationDto): Promise<Medication> {
  const doc = await db().collection(MEDICATIONS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Medication not found');

  await db().collection(MEDICATIONS).doc(id).update({ ...dto, updatedAt: FieldValue.serverTimestamp() });
  return getMedication(id);
}

export async function deleteMedication(id: string): Promise<void> {
  const doc = await db().collection(MEDICATIONS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Medication not found');
  await db().collection(MEDICATIONS).doc(id).delete();
}

export async function updateStock(id: string, dto: UpdateStockDto): Promise<Medication> {
  const doc = await db().collection(MEDICATIONS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Medication not found');

  const data = doc.data()!;
  const newQuantity = data.quantity + dto.delta;
  if (newQuantity < 0) throw new BadRequestError('Stock cannot go below zero');

  const threshold: number = data.lowStockThreshold;
  const status = computeStatus(newQuantity, threshold);

  await db().collection(MEDICATIONS).doc(id).update({
    quantity: newQuantity,
    status,
    updatedAt: FieldValue.serverTimestamp(),
  });

  const updated = await getMedication(id);

  if (status === 'lowStock' || status === 'outOfStock') {
    notifyAdminLowStock(updated);
  }

  return updated;
}

export async function decrementStock(medicationId: string, name: string): Promise<void> {
  const ref = db().collection(MEDICATIONS).doc(medicationId);
  const doc = await ref.get();
  if (!doc.exists) return;

  const data = doc.data()!;
  const newQuantity = Math.max(0, data.quantity - 1);
  const threshold: number = data.lowStockThreshold;
  const status = computeStatus(newQuantity, threshold);

  await ref.update({ quantity: newQuantity, status, updatedAt: FieldValue.serverTimestamp() });

  if (status === 'lowStock' || status === 'outOfStock') {
    const updated = await getMedication(medicationId);
    notifyAdminLowStock(updated);
  }
}

export async function resolveMedications(
  items: { medicationId: string; dosage?: string }[]
): Promise<TreatmentMedication[]> {
  const resolved: TreatmentMedication[] = [];

  for (const item of items) {
    const med = await getMedication(item.medicationId);
    if (med.status === 'outOfStock') {
      throw new BadRequestError(`${med.name} is out of stock`);
    }
    resolved.push({
      medicationId: med.id,
      name: med.name,
      dosage: item.dosage ?? med.dosage,
    });
  }

  return resolved;
}
