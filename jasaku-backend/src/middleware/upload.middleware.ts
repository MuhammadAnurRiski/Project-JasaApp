import multer from 'multer';
import path from 'path';

const storage = multer.memoryStorage();

const IMAGE_EXTS = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
const DOC_EXTS = [
  '.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp',
  '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.zip',
];
const IMAGE_ONLY_FIELDS = ['profile_photo', 'ktp_photo', 'selfie_photo'];

const fileFilter = (_req: any, file: any, cb: any) => {
  const ext = path.extname(file.originalname).toLowerCase();
  const allowed = IMAGE_ONLY_FIELDS.includes(file.fieldname) ? IMAGE_EXTS : DOC_EXTS;
  if (allowed.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error(`Tipe file tidak didukung: ${ext}. Hanya JPG, PNG, PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, ZIP yang diizinkan.`));
  }
};

export const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 },
});

