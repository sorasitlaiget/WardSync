import { auth, db, FieldValue } from '../../config/firebase.config';
import { NotFoundError, ConflictError, BadRequestError } from '../../core/utils/error';
import {
  UserProfile,
  CreateUserDto,
  CompleteProfileDto,
  UpdateUserRoleDto,
} from './users.types';

const USERS = 'users';

export async function getProfile(uid: string): Promise<UserProfile> {
  const doc = await db().collection(USERS).doc(uid).get();
  if (!doc.exists) throw new NotFoundError('User not found');
  return { uid: doc.id, ...doc.data() } as UserProfile;
}

export async function completeProfile(uid: string, dto: CompleteProfileDto): Promise<UserProfile> {
  const name = dto.name.trim();
  if (!name) throw new BadRequestError('Name cannot be empty');

  await db().collection(USERS).doc(uid).update({
    name,
    isProfileComplete: true,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return getProfile(uid);
}

export async function createUser(dto: CreateUserDto): Promise<UserProfile> {
  // สร้าง Firebase Auth user
  let firebaseUser;
  try {
    firebaseUser = await auth().createUser({
      email: dto.email,
      password: dto.password,
    });
  } catch (err: any) {
    if (err.code === 'auth/email-already-exists') {
      throw new ConflictError('Email already in use');
    }
    throw err;
  }

  // สร้าง Firestore doc พร้อม role ที่ admin กำหนด
  const now = FieldValue.serverTimestamp();
  const userDoc = {
    email: dto.email,
    name: '',
    role: dto.role,
    ...(dto.assignedRoom && { assignedRoom: dto.assignedRoom }),
    isProfileComplete: false,
    createdAt: now,
    updatedAt: now,
  };

  await db().collection(USERS).doc(firebaseUser.uid).set(userDoc);

  return getProfile(firebaseUser.uid);
}

export async function listUsers(): Promise<UserProfile[]> {
  const snapshot = await db().collection(USERS).orderBy('createdAt', 'desc').get();
  return snapshot.docs.map((doc) => ({ uid: doc.id, ...doc.data() }) as UserProfile);
}

export async function updateFcmToken(uid: string, fcmToken: string): Promise<void> {
  await db().collection(USERS).doc(uid).update({
    fcmToken,
    updatedAt: FieldValue.serverTimestamp(),
  });
}

export async function updateUserRole(uid: string, dto: UpdateUserRoleDto): Promise<UserProfile> {
  const doc = await db().collection(USERS).doc(uid).get();
  if (!doc.exists) throw new NotFoundError('User not found');

  const update: Record<string, any> = {
    role: dto.role,
    updatedAt: FieldValue.serverTimestamp(),
  };

  // ถ้าเปลี่ยนจาก doctor → role อื่น ลบ assignedRoom ออก
  if (dto.role !== 'doctor') {
    update.assignedRoom = FieldValue.delete();
  } else if (dto.assignedRoom) {
    update.assignedRoom = dto.assignedRoom;
  }

  await db().collection(USERS).doc(uid).update(update);
  return getProfile(uid);
}
