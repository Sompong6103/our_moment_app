import { Request, Response } from 'express';
import { guestService } from './guest.service';

export const guestController = {
  async join(req: Request, res: Response) {
    try {
      const { allergies, followersCount, wish } = req.body;
      const guest = await guestService.joinEvent(req.userId!, req.params.eventId as string, { allergies, followersCount, wish });
      res.status(201).json(guest);
    } catch (err: any) {
      const message = err instanceof Error ? err.message : 'Request failed';
      const status = message.toLowerCase().includes('not found')
        ? 404
        : message.toLowerCase().includes('already')
            ? 409
            : 400;
      res.status(status).json({ error: message });
    }
  },

  async checkIn(req: Request, res: Response) {
    try {
      const result = await guestService.checkIn(req.params.eventId as string, req.userId!);
      res.json(result);
    } catch (err: any) {
      const message = err instanceof Error ? err.message : 'Request failed';
      const status = message.toLowerCase().includes('not found') ? 404 : 400;
      res.status(status).json({ error: message });
    }
  },

  async list(req: Request, res: Response) {
    try {
      const guests = await guestService.list(req.params.eventId as string, req.query.status as string | undefined);
      res.json(guests);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch guests' });
    }
  },

  async getDetail(req: Request, res: Response) {
    try {
      const detail = await guestService.getDetail(req.params.eventId as string, req.params.guestId as string);
      res.json(detail);
    } catch (err: any) {
      const message = err instanceof Error ? err.message : 'Guest not found';
      res.status(404).json({ error: message });
    }
  },

  async update(req: Request, res: Response) {
    try {
      const { allergies, followersCount } = req.body;
      const guest = await guestService.updateGuest(req.params.eventId as string, req.params.guestId as string, { allergies, followersCount });
      res.json(guest);
    } catch (err: any) {
      const message = err instanceof Error ? err.message : 'Update failed';
      res.status(400).json({ error: message });
    }
  },

  async myStatus(req: Request, res: Response) {
    try {
      const status = await guestService.getGuestStatus(req.params.eventId as string, req.userId!);
      res.json(status || { status: null });
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch status' });
    }
  },

  async leave(req: Request, res: Response) {
    try {
      const result = await guestService.leaveEvent(req.params.eventId as string, req.userId!);
      res.json(result);
    } catch (err: any) {
      const message = err instanceof Error ? err.message : 'Request failed';
      const status = message.toLowerCase().includes('not found') ? 404 : 400;
      res.status(status).json({ error: message });
    }
  },
};
