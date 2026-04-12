import { Request, Response } from 'express';
import { notificationService } from './notification.service';

export const notificationController = {
  async list(req: Request, res: Response) {
    try {
      const notifications = await notificationService.list(req.userId!);
      res.json(notifications);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch notifications' });
    }
  },

  async markAsRead(req: Request, res: Response) {
    try {
      await notificationService.markAsRead(req.params.id as string, req.userId!);
      res.json({ message: 'Notification marked as read' });
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async announce(req: Request, res: Response) {
    try {
      const { title, message } = req.body;
      if (!title || !message) {
        res.status(400).json({ error: 'Title and message are required' });
        return;
      }
      const result = await notificationService.announce(req.params.eventId as string, title, message);
      res.json(result);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },
};
