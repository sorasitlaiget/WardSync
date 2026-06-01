import { db, FieldValue, Timestamp } from '../../config/firebase.config';
import { NotFoundError, BadRequestError, ConflictError } from '../../core/utils/error';
import {
  Patient,
  CreatePatientDto,
  UpdatePatientStatusDto,
  AddVitalSignsDto,
  AddTreatmentDto,
} from './patients.types';
import { TriageRoom } from '../users/users.types';

const PATIENTS = 'patients';

export async function createPatient(dto: CreatePatientDto, createdBy: string): Promise<Patient> {
  // ตรวจว่า wristbandNumber ซ้ำไหม
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

  const patient = {
    wristbandNumber: dto.wristbandNumber,
    triageColor: dto.triageColor,
    ...(dto.photoUrl && { photoUrl: dto.photoUrl }),
    sex: dto.sex,
    ageRange: dto.ageRange,
    status: 'waiting' as const,
    assignedRoom: dto.triageColor as TriageRoom,
    vitalSigns: [],
    treatments: [],
    createdBy,
    createdAt: now,
    updatedAt: now,
  };

  await ref.set(patient);
  return getPatient(ref.id);
}

export async function listPatients(room?: TriageRoom, status?: string): Promise<Patient[]> {
  let query: FirebaseFirestore.Query = db().collection(PATIENTS);

  if (room) query = query.where('assignedRoom', '==', room);
  if (status) query = query.where('status', '==', status);

  query = query.orderBy('createdAt', 'desc');

  const snapshot = await query.get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }) as Patient);
}

export async function getPatient(id: string): Promise<Patient> {
  const doc = await db().collection(PATIENTS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');
  return { id: doc.id, ...doc.data() } as Patient;
}

export async function updatePatientStatus(
  id: string,
  dto: UpdatePatientStatusDto
): Promise<Patient> {
  const doc = await db().collection(PATIENTS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');

  await db().collection(PATIENTS).doc(id).update({
    status: dto.status,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return getPatient(id);
}

export async function addVitalSigns(
  id: string,
  dto: AddVitalSignsDto,
  recordedBy: string
): Promise<Patient> {
  const doc = await db().collection(PATIENTS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');

  const vital = {
    ...dto,
    recordedBy,
    recordedAt: Timestamp.now(),
  };

  await db()
    .collection(PATIENTS)
    .doc(id)
    .update({
      vitalSigns: FieldValue.arrayUnion(vital),
      updatedAt: FieldValue.serverTimestamp(),
    });

  return getPatient(id);
}

export async function addTreatment(
  id: string,
  dto: AddTreatmentDto,
  recordedBy: string
): Promise<Patient> {
  const doc = await db().collection(PATIENTS).doc(id).get();
  if (!doc.exists) throw new NotFoundError('Patient not found');

  if (!dto.diagnosis.trim()) throw new BadRequestError('Diagnosis cannot be empty');

  const treatment = {
    ...dto,
    recordedBy,
    recordedAt: Timestamp.now(),
  };

  await db()
    .collection(PATIENTS)
    .doc(id)
    .update({
      treatments: FieldValue.arrayUnion(treatment),
      updatedAt: FieldValue.serverTimestamp(),
    });

  return getPatient(id);
}
