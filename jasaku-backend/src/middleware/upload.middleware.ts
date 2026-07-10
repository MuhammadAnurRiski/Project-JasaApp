import multer from 'multer';
import path from 'path';
import fs from 'fs';

const baseDir = 'uploads';
const proofDir = 'uploads/payment-proofs';
if (!fs.existsSync(baseDir)) fs.mkdirSync(baseDir, { recursive: true });
if (!fs.existsSync(proofDir)) fs.mkdirSync(proofDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req: any, file: any, cb: any) => {
    const dir = file.fieldname === 'proof' ? proofDir : baseDir;
    cb(null, dir);
  },
  filename: (_req: any, file: any, cb: any) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

const fileFilter = (_req: any, file: any, cb: any) => {
  const allowed = ['.jpg', '.jpeg', '.png'];
  const ext = path.extname(file.originalname).toLowerCase();
  cb(null, allowed.includes(ext));
};

export const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
});