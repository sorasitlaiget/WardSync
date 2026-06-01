import { db, FieldValue, Timestamp } from '../../config/firebase.config';
import { NotFoundError, BadRequestError, ConflictError } from '../../core/utils/error';
import { notifyDoctorsNewPatient } from '../../core/utils/notification';
import {
  Patient,
  VitalSigns,
  Treatment,
  CreatePatientDto,
  UpdatePatientStatusDto,
  AddVitalSignsDto,
  AddTreatmentDto,
  UpdateVitalSignsDto,
  UpdateTreatmentDto,
} from './patients.types';
import { TriageRoom } from '../users/users.types';

const PATIENTS = 'patients';
const VITALS = 'vitalSigns';
const TREATMENTS = 'treatments';

export async function createPatient(dto: CreatePatientDto, createdBy: string): Promise<Patient> {
  const existing = await db()
    .collection(PATIENTS)
    .where('wristbandNumber', '==', dto.wristbandNumber)
    .where('status', 'in', ['waiting', 'inTreatment'])
    .get();

  if (!existing.empty) {
    throw new ConflictError(`Wristband ${dto.wristbandNumber} is already in use`);
  }

  const now = FieldValue.serverTimestamp();
  const ref = db().collection(PATIENTS).doc();

  await ref.set({
    wristbandNumber: dto.wristbandNumber,
    triageColor: dto.triageColor,
    photoUrl: dto.photoUrl ?? null,
    sex: dto.sex,
    ageRange: dto.ageRange,
    status: 'waiting',
    assignedRoom: dto.triageColor as TriageRoom,
    statusHistory: [{ status: 'waiting', changedBy: createdBy, changedAt: Timestamp.now() }],
    createdBy,
    createdAt: now,
    updatedAt: now,
  });

  const created = await getPatient(ref.id);
  notifyDoctorsNewPatient(created);
  return created;
}

export async function listPatients(
  room?: TriageRoom | 'all',
  status?: string
): Promise<{ patients: Patient[]; total: number }> {
  let query: FirebaseFirestore.Query = db().collection(PATIENTS);

  if (room && room !== 'all') query = query.where('assignedRoom', '==', room);
  if (status) query = query.where('status', '==', status);

  query = query.orderBy('createdAt', 'desc');

  const snapshot = await query.get();
  const patients = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }) as Patient);
  return { patients, total: patients.length };
}

export async function getPatient(id: string): Promise<Patient> {
  const doc = await db().collection(PATIENTS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');
  return { id: doc.id, ...doc.data() } as Patient;
}

export async function updatePatientStatus(
  id: string,
  dto: UpdatePatientStatusDto,
  changedBy: string
): Promise<Patient> {
  const doc = await db().collection(PATIENTS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');

  const logEntry = { status: dto.status, changedBy, changedAt: Timestamp.now() };

  await db().collection(PATIENTS).doc(id).update({
    status: dto.status,
    statusHistory: FieldValue.arrayUnion(logEntry),
    updatedAt: FieldValue.serverTimestamp(),
  });

  return getPatient(id);
}

// ── Vital Signs ──────────────────────────────────────────────

export async function addVitalSigns(
  patientId: string,
  dto: AddVitalSignsDto,
  recordedBy: string
): Promise<VitalSigns> {
  const doc = await db().collection(PATIENTS).doc(patientId).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');

  const ref = db().collection(PATIENTS).doc(patientId).collection(VITALS).doc();
  const vital = { ...dto, recordedBy, recordedAt: Timestamp.now() };
  await ref.set(vital);
  await db().collection(PATIENTS).doc(patientId).update({ updatedAt: FieldValue.serverTimestamp() });

  return { id: ref.id, ...vital } as VitalSigns;
}

export async function listVitalSigns(patientId: string): Promise<VitalSigns[]> {
  const doc = await db().collection(PATIENTS).doc(patientId).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');

  const snapshot = await db()
    .collection(PATIENTS).doc(patientId).collection(VITALS)
    .orderBy('recordedAt', 'desc')
    .get();

  return snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as VitalSigns);
}

export async function updateVitalSigns(
  patientId: string,
  vitalId: string,
  dto: UpdateVitalSignsDto
): Promise<VitalSigns> {
  const ref = db().collection(PATIENTS).doc(patientId).collection(VITALS).doc(vitalId);
  const doc = await ref.get();
  if (!doc.exists) throw new NotFoundError('Vital signs record not found');

  await ref.update({ ...dto });
  const updated = await ref.get();
  return { id: ref.id, ...updated.data() } as VitalSigns;
}

export async function deleteVitalSigns(patientId: string, vitalId: string): Promise<void> {
  const ref = db().collection(PATIENTS).doc(patientId).collection(VITALS).doc(vitalId);
  const doc = await ref.get();
  if (!doc.exists) throw new NotFoundError('Vital signs record not found');
  await ref.delete();
}

// ── Treatments ───────────────────────────────────────────────

export async function addTreatment(
  patientId: string,
  dto: AddTreatmentDto,
  recordedBy: string
): Promise<Treatment> {
  const doc = await db().collection(PATIENTS).doc(patientId).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');

  if (!dto.diagnosis.trim()) throw new BadRequestError('Diagnosis cannot be empty');

  const ref = db().collection(PATIENTS).doc(patientId).collection(TREATMENTS).doc();
  const treatment = { ...dto, recordedBy, recordedAt: Timestamp.now() };
  await ref.set(treatment);
  await db().collection(PATIENTS).doc(patientId).update({ updatedAt: FieldValue.serverTimestamp() });

  return { id: ref.id, ...treatment } as Treatment;
}

export async function listTreatments(patientId: string): Promise<Treatment[]> {
  const doc = await db().collection(PATIENTS).doc(patientId).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');

  const snapshot = await db()
    .collection(PATIENTS).doc(patientId).collection(TREATMENTS)
    .orderBy('recordedAt', 'desc')
    .get();

  return snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as Treatment);
}

export async function updateTreatment(
  patientId: string,
  treatmentId: string,
  dto: UpdateTreatmentDto
): Promise<Treatment> {
  const ref = db().collection(PATIENTS).doc(patientId).collection(TREATMENTS).doc(treatmentId);
  const doc = await ref.get();
  if (!doc.exists) throw new NotFoundError('Treatment record not found');

  await ref.update({ ...dto });
  const updated = await ref.get();
  return { id: ref.id, ...updated.data() } as Treatment;
}

export async function deleteTreatment(patientId: string, treatmentId: string): Promise<void> {
  const ref = db().collection(PATIENTS).doc(patientId).collection(TREATMENTS).doc(treatmentId);
  const doc = await ref.get();
  if (!doc.exists) throw new NotFoundError('Treatment record not found');
  await ref.delete();
}
