export type UserRole = 'nurse' | 'doctor' | 'admin';

export type TriageRoom = 'red' | 'yellow' | 'green' | 'black';

export interface UserProfile {
  uid: string;
  email: string;
  name: string;
  role: UserRole;
  assignedRoom?: TriageRoom; // doctor only
  fcmToken?: string;
  isProfileComplete: boolean;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

export interface CreateUserDto {
  email: string;
  password: string;
  role: UserRole;
  assignedRoom?: TriageRoom;
}

export interface CompleteProfileDto {
  name: string;
}

export interface UpdateUserRoleDto {
  role: UserRole;
  assignedRoom?: TriageRoom;
}
