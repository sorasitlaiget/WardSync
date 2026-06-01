export type WarningLevel = 'normal' | 'nearFull' | 'full';

export interface RoomCapacityConfig {
  room: string;
  maxCapacity: number;
  updatedAt: FirebaseFirestore.Timestamp;
  updatedBy: string;
}

export interface RoomCapacityStatus {
  room: string;
  current: number;
  maxCapacity: number;
  percentage: number;
  warning: WarningLevel;
}

export interface SetRoomCapacityDto {
  maxCapacity: number;
}
