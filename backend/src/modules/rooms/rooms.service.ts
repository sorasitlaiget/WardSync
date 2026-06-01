import { db, FieldValue, Timestamp } from '../../config/firebase.config';
import { BadRequestError } from '../../core/utils/error';
import { RoomCapacityStatus, SetRoomCapacityDto, WarningLevel } from './rooms.types';

const ROOMS = ['red', 'yellow', 'green', 'black'] as const;
const CAPACITY_COL = 'roomCapacity';
const PATIENTS_COL = 'patients';
const DEFAULT_MAX_CAPACITY = 10;

function computeWarning(percentage: number): WarningLevel {
  if (percentage >= 95) return 'full';
  if (percentage >= 80) return 'nearFull';
  return 'normal';
}

export async function getAllRoomCapacity(): Promise<RoomCapacityStatus[]> {
  const [configSnap, patientSnap] = await Promise.all([
    db().collection(CAPACITY_COL).get(),
    db()
      .collection(PATIENTS_COL)
      .where('status', 'in', ['waiting', 'inTreatment'])
      .get(),
  ]);

  const configMap: Record<string, number> = {};
  configSnap.docs.forEach((d) => {
    configMap[d.id] = d.data().maxCapacity;
  });

  const countMap: Record<string, number> = { red: 0, yellow: 0, green: 0, black: 0 };
  patientSnap.docs.forEach((d) => {
    const room = d.data().assignedRoom as string;
    if (room in countMap) countMap[room]++;
  });

  return ROOMS.map((room) => {
    const maxCapacity = configMap[room] ?? DEFAULT_MAX_CAPACITY;
    const current = countMap[room];
    const percentage = maxCapacity > 0 ? Math.round((current / maxCapacity) * 100) : 0;
    return {
      room,
      current,
      maxCapacity,
      percentage,
      warning: computeWarning(percentage),
    };
  });
}

export async function getRoomCapacity(room: string): Promise<RoomCapacityStatus> {
  if (!ROOMS.includes(room as typeof ROOMS[number])) {
    throw new BadRequestError(`Invalid room: ${room}`);
  }

  const [configDoc, patientSnap] = await Promise.all([
    db().collection(CAPACITY_COL).doc(room).get(),
    db()
      .collection(PATIENTS_COL)
      .where('assignedRoom', '==', room)
      .where('status', 'in', ['waiting', 'inTreatment'])
      .get(),
  ]);

  const maxCapacity = configDoc.exists ? configDoc.data()!.maxCapacity : DEFAULT_MAX_CAPACITY;
  const current = patientSnap.size;
  const percentage = maxCapacity > 0 ? Math.round((current / maxCapacity) * 100) : 0;

  return { room, current, maxCapacity, percentage, warning: computeWarning(percentage) };
}

export async function setRoomCapacity(
  room: string,
  dto: SetRoomCapacityDto,
  updatedBy: string
): Promise<RoomCapacityStatus> {
  if (!ROOMS.includes(room as typeof ROOMS[number])) {
    throw new BadRequestError(`Invalid room: ${room}`);
  }
  if (dto.maxCapacity < 1) throw new BadRequestError('maxCapacity must be at least 1');

  await db().collection(CAPACITY_COL).doc(room).set({
    maxCapacity: dto.maxCapacity,
    updatedBy,
    updatedAt: Timestamp.now(),
  });

  return getRoomCapacity(room);
}
