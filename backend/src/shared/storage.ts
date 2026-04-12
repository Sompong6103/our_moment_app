import fs from 'fs';
import path from 'path';
import { env } from '../config/env';

const UPLOAD_DIR = env.uploadDir;

export function getUploadDir(...subPaths: string[]): string {
  const dir = path.join(UPLOAD_DIR, ...subPaths);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return dir;
}

export function getFilePath(relativePath: string): string {
  return path.join(UPLOAD_DIR, relativePath);
}

export function deleteFile(relativePath: string): void {
  const fullPath = path.join(UPLOAD_DIR, relativePath);
  if (fs.existsSync(fullPath)) {
    fs.unlinkSync(fullPath);
  }
}

export function moveFile(sourcePath: string, destDir: string, filename: string): string {
  const fullDestDir = path.join(UPLOAD_DIR, destDir);
  if (!fs.existsSync(fullDestDir)) {
    fs.mkdirSync(fullDestDir, { recursive: true });
  }

  const destRelativePath = path.join(destDir, filename);
  const destFullPath = path.join(UPLOAD_DIR, destRelativePath);
  fs.renameSync(sourcePath, destFullPath);
  return destRelativePath;
}

export function getPublicUrl(relativePath: string): string {
  return `/uploads/${relativePath.replace(/\\/g, '/')}`;
}
