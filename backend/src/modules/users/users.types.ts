export type UserRole = 'nurse' | 'doctor' | 'admin';

export type TriageRoom = 'red' | 'yellow' | 'green' | 'black';

export interface UserProfile {
  uid: string;
  email: string;
  name: string;
  role: UserRole;
  assignedRoom?: TriageRoom; // doctor only
  fcmToken?: string;
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}
