import { Request, Response } from 'express';
import { photoService } from './photo.service';

export const photoController = {
  async upload(req: Request, res: Response) {
    try {
      if (!req.file) {
        res.status(400).json({ error: 'No file uploaded' });
        return;
      }
      const photo = await photoService.upload(req.params.eventId as string, req.userId!, req.file.path, req.file.filename);
      res.status(201).json(photo);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async list(req: Request, res: Response) {
    try {
      const photos = await photoService.list(req.params.eventId as string);
      res.json(photos);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch photos' });
    }
  },

  async remove(req: Request, res: Response) {
    try {
      await photoService.remove(req.params.eventId as string, req.params.photoId as string);
      res.json({ message: 'Photo deleted' });
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async bulkRemove(req: Request, res: Response) {
    try {
      const { photoIds } = req.body;
      await photoService.bulkRemove(req.params.eventId as string, photoIds);
      res.json({ message: 'Photos deleted' });
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async searchByFace(req: Request, res: Response) {
    try {
      if (!req.file) {
        res.status(400).json({ error: 'No selfie uploaded' });
        return;
      }
      const results = await photoService.searchByFace(
        req.params.eventId as string,
        req.file.path,
      );
      res.json(results);
    } catch (err: any) {
      res.status(500).json({ error: 'Face search failed' });
    }
  },
};
