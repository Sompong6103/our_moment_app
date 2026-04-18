import { Request, Response, NextFunction } from 'express';

export const errorHandler = (err: Error, _req: Request, res: Response, _next: NextFunction): void => {
  console.error('[Error]', err.message);

  if (err.message.includes('Only JPEG, PNG, WebP, and GIF')) {
    res.status(400).json({ error: err.message });
    return;
  }

  if (err.message.includes('File too large')) {
    res.status(400).json({ error: 'File size exceeds limit' });
    return;
  }

  res.status(500).json({ error: 'Internal server error' });
};
