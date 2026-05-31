import admin from 'firebase-admin';
import { env } from './env.config';
import { logger } from '../core/utils/logger';

let firebaseApp: admin.app.App | null = null;

export function initFirebase(): admin.app.App {
  if (firebaseApp) return firebaseApp;

  try {
    if (env.useFirebaseEmulator) {
      // Emulator mode - บอก Admin SDK ให้ใช้ emulator
      process.env.FIRESTORE_EMULATOR_HOST = env.firestoreEmulatorHost;
      process.env.FIREBASE_AUTH_EMULATOR_HOST = env.firebaseAuthEmulatorHost;
      process.env.FIREBASE_STORAGE_EMULATOR_HOST = env.firebaseStorageEmulatorHost;

      firebaseApp = admin.initializeApp({
        projectId: env.firebaseProjectId,
        storageBucket: env.firebaseStorageBucket,
      });

      logger.info('🔧 Firebase Admin SDK initialized in EMULATOR mode');
      logger.info(`   ├─ Firestore: ${env.firestoreEmulatorHost}`);
      logger.info(`   ├─ Auth:      ${env.firebaseAuthEmulatorHost}`);
      logger.info(`   └─ Storage:   ${env.firebaseStorageEmulatorHost}`);
    } else {
      // Production mode - ใช้ service account
      const serviceAccount = require('../../firebase-service-account.json');

      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: env.firebaseStorageBucket,
      });

      logger.info('🚀 Firebase Admin SDK initialized in PRODUCTION mode');
    }

    return firebaseApp;
  } catch (error) {
    logger.error('Failed to initialize Firebase Admin SDK:', error);
    throw error;
  }
}

// Lazy getters - เรียกหลัง initFirebase() แล้ว
export const db = (): admin.firestore.Firestore => admin.firestore();
export const auth = (): admin.auth.Auth => admin.auth();
export const storage = (): admin.storage.Storage => admin.storage();
export const messaging = (): admin.messaging.Messaging => admin.messaging();

// Firestore helpers
export const FieldValue = admin.firestore.FieldValue;
export const Timestamp = admin.firestore.Timestamp;