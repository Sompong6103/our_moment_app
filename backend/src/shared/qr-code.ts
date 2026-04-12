import QRCode from 'qrcode';
import path from 'path';
import { getUploadDir } from './storage';

export async function generateQRCode(
  data: string,
  outputRelativePath: string
): Promise<string> {
  const outputDir = getUploadDir(path.dirname(outputRelativePath));
  const outputFullPath = path.join(outputDir, path.basename(outputRelativePath));

  await QRCode.toFile(outputFullPath, data, {
    type: 'png',
    width: 512,
    margin: 2,
    color: {
      dark: '#000000',
      light: '#FFFFFF',
    },
  });

  return outputRelativePath;
}

export async function generateQRCodeDataURL(data: string): Promise<string> {
  return QRCode.toDataURL(data, {
    width: 512,
    margin: 2,
  });
}
