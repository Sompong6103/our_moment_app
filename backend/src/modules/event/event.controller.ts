import { Request, Response } from 'express';
import { eventService } from './event.service';

export const eventController = {
  async create(req: Request, res: Response) {
    try {
      const event = await eventService.create(req.userId!, req.body);
      res.status(201).json(event);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async getById(req: Request, res: Response) {
    try {
      const event = await eventService.getById(req.params.eventId as string);
      res.json(event);
    } catch (err: any) {
      res.status(404).json({ error: err.message });
    }
  },

  async getByJoinCode(req: Request, res: Response) {
    try {
      const event = await eventService.getByJoinCode(req.params.joinCode as string);
      res.json(event);
    } catch (err: any) {
      res.status(404).json({ error: err.message });
    }
  },

  async list(req: Request, res: Response) {
    try {
      const events = await eventService.listByUser(req.userId!);
      res.json(events);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch events' });
    }
  },

  async update(req: Request, res: Response) {
    try {
      const event = await eventService.update(req.params.eventId as string, req.body);
      res.json(event);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async uploadCover(req: Request, res: Response) {
    try {
      if (!req.file) {
        res.status(400).json({ error: 'No file uploaded' });
        return;
      }
      const result = await eventService.uploadCover(req.params.eventId as string, req.file.path, req.file.filename);
      res.json(result);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async publish(req: Request, res: Response) {
    try {
      const event = await eventService.publish(req.params.eventId as string);
      res.json(event);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async remove(req: Request, res: Response) {
    try {
      await eventService.softDelete(req.params.eventId as string);
      res.json({ message: 'Event deleted' });
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },
};
