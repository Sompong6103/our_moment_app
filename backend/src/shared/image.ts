import sharp from 'sharp';
import fs from 'fs';
import path from 'path';
import { getUploadDir } from './storage';

interface ProcessImageOptions {
  width?: number;
  height?: number;
  quality?: number;
  format?: 'jpeg' | 'png' | 'webp';
}

const DEFAULT_OPTIONS: ProcessImageOptions = {
  width: 1920,
  height: 1920,
  quality: 80,
  format: 'jpeg',
};

export async function processImage(
  inputPath: string,
  outputRelativePath?: string,
  options: ProcessImageOptions = {}
): Promise<string> {
  const opts = { ...DEFAULT_OPTIONS, ...options };

  // If no output path, process in-place with temp file
  const outputPath = outputRelativePath
    ? path.join(getUploadDir(path.dirname(outputRelativePath)), path.basename(outputRelativePath))
    : inputPath + '.processed';

  await sharp(inputPath)
    .resize(opts.width, opts.height, {
      fit: 'inside',
      withoutEnlargement: true,
    })
    .toFormat(opts.format!, { quality: opts.quality })
    .toFile(outputPath);

  // If processing in-place, replace original
  if (!outputRelativePath) {
    fs.renameSync(outputPath, inputPath);
    return inputPath;
  }

  return outputRelativePath;
}

export async function generateThumbnail(
  inputPath: string,
  outputRelativePath: string,
  size: number = 300
): Promise<string> {
  const outputDir = getUploadDir(path.dirname(outputRelativePath));
  const outputFullPath = path.join(outputDir, path.basename(outputRelativePath));

  await sharp(inputPath)
    .resize(size, size, {
      fit: 'cover',
    })
    .toFormat('jpeg', { quality: 70 })
    .toFile(outputFullPath);

  return outputRelativePath;
}
