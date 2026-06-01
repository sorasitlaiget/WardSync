import { db, messaging } from '../../config/firebase.config';
import { Patient } from '../../modules/patients/patients.types';
import { logger } from './logger';

export async function notifyDoctorsNewPatient(patient: Patient): Promise<void> {
  try {
    const snapshot = await db()
      .collection('users')
      .where('role', '==', 'doctor')
      .where('assignedRoom', '==', patient.assignedRoom)
      .get();

    const tokens: string[] = snapshot.docs
      .map((doc) => doc.data().fcmToken)
      .filter((token): token is string => !!token);

    if (tokens.length === 0) return;

    const message = `New patient #${patient.wristbandNumber} - ${patient.triageColor.toUpperCase()} - ${patient.sex} ${patient.ageRange}`;

    await messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: 'New Patient Assigned',
        body: message,
      },
      data: {
        patientId: patient.id,
        type: 'new_patient',
      },
    });

    logger.info(`FCM sent to ${tokens.length} doctor(s) in room ${patient.assignedRoom}`);
  } catch (err) {
    logger.error('Failed to send FCM notification:', err);
  }
}
