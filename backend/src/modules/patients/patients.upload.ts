import multer from 'multer';
import { storage } from '../../config/firebase.config';
import { env } from '../../config/env.config';

export const uploadMiddleware = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (!file.mimetype.startsWith('image/')) {
      cb(new Error('Only image files are allowed'));
    } else {
      cb(null, true);
    }
  },
}).single('photo');

export async function uploadToStorage(file: Express.Multer.File): Promise<string> {
  const filename = `patients/${Date.now()}_${file.originalname}`;
  const bucket = storage().bucket();
  const bucketFile = bucket.file(filename);

  await bucketFile.save(file.buffer, {
    metadata: { contentType: file.mimetype },
  });

  await bucketFile.makePublic();
  let url = bucketFile.publicUrl();

  // Android emulator ไม่สามารถเข้า 127.0.0.1 ได้ ต้องใช้ 10.0.2.2 แทน
  if (env.useFirebaseEmulator) {
    url = url.replace('127.0.0.1', '10.0.2.2');
  }

  return url;
}
