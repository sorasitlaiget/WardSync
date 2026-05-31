import dotenv from 'dotenv';

dotenv.config();

interface EnvConfig {
  port: number;
  nodeEnv: 'development' | 'production' | 'test';
  useFirebaseEmulator: boolean;
  firebaseProjectId: string;
  firebaseStorageBucket: string;
  firestoreEmulatorHost: string;
  firebaseAuthEmulatorHost: string;
  firebaseStorageEmulatorHost: string;
  corsOrigin: string[];
  logLevel: string;
}

function getEnv(key: string, fallback?: string): string {
  const value = process.env[key] ?? fallback;
  if (value === undefined) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

export const env: EnvConfig = {
  port: parseInt(getEnv('PORT', '3000'), 10),
  nodeEnv: getEnv('NODE_ENV', 'development') as EnvConfig['nodeEnv'],
  useFirebaseEmulator: getEnv('USE_FIREBASE_EMULATOR', 'false') === 'true',
  firebaseProjectId: getEnv('FIREBASE_PROJECT_ID'),
  firebaseStorageBucket: getEnv('FIREBASE_STORAGE_BUCKET'),
  firestoreEmulatorHost: getEnv('FIRESTORE_EMULATOR_HOST', '127.0.0.1:8080'),
  firebaseAuthEmulatorHost: getEnv('FIREBASE_AUTH_EMULATOR_HOST', '127.0.0.1:9099'),
  firebaseStorageEmulatorHost: getEnv('FIREBASE_STORAGE_EMULATOR_HOST', '127.0.0.1:9199'),
  corsOrigin: getEnv('CORS_ORIGIN', 'http://localhost:3000').split(','),
  logLevel: getEnv('LOG_LEVEL', 'info'),
};

export const isDev = env.nodeEnv === 'development';
export const isProd = env.nodeEnv === 'production';