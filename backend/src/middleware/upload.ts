import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { v4 as uuidv4 } from 'uuid';
import { env } from '../config/env';

const ensureDir = (dir: string) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    const uploadPath = path.resolve(env.uploadDir, 'temp');
    ensureDir(uploadPath);
    cb(null, uploadPath);
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${uuidv4()}${ext}`);
  },
});

const fileFilter = (_req: Express.Request, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  const allowedMimes = [
    'image/jpeg', 'image/png', 'image/webp', 'image/gif',
    'image/heic', 'image/heif', 'image/bmp', 'image/tiff',
    'image/svg+xml', 'image/avif',
  ];
  const allowedExts = [
    '.jpg', '.jpeg', '.png', '.webp', '.gif',
    '.heic', '.heif', '.bmp', '.tiff', '.tif',
    '.svg', '.avif',
  ];
  const ext = path.extname(file.originalname).toLowerCase();
  // Accept if mime starts with image/ OR mime is in list OR extension matches
  if (file.mimetype.startsWith('image/') || allowedMimes.includes(file.mimetype) || allowedExts.includes(ext)) {
    cb(null, true);
  } else if (file.mimetype === 'application/octet-stream' && allowedExts.includes(ext)) {
    // iOS sometimes sends HEIC as octet-stream
    cb(null, true);
  } else {
    cb(new Error('Only image files are allowed'));
  }
};

export const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: env.maxFileSize },
});
