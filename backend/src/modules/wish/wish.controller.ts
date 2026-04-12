import { Request, Response } from 'express';
import { wishService } from './wish.service';

export const wishController = {
  async list(req: Request, res: Response) {
    try {
      const wishes = await wishService.list(req.params.eventId as string);
      res.json(wishes);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch wishes' });
    }
  },

  async create(req: Request, res: Response) {
    try {
      const { message } = req.body;
      if (!message || !message.trim()) {
        res.status(400).json({ error: 'Wish message is required' });
        return;
      }
      const wish = await wishService.create(req.params.eventId as string, req.userId!, message.trim());
      res.status(201).json(wish);
    } catch (err: any) {
      if (err.message.includes('already sent')) {
        res.status(409).json({ error: err.message });
        return;
      }
      res.status(400).json({ error: err.message });
    }
  },

  async remove(req: Request, res: Response) {
    try {
      await wishService.remove(req.params.wishId as string);
      res.json({ message: 'Wish deleted' });
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },
};
