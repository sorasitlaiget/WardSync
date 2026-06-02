import multer from 'multer';
import { storage } from '../../config/firebase.config';

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
  return bucketFile.publicUrl();
}
