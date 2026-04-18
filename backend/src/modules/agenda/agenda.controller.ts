import { Request, Response } from 'express';
import { agendaService } from './agenda.service';
import { reminderService } from './reminder.service';

export const agendaController = {
  async list(req: Request, res: Response) {
    try {
      const items = await agendaService.list(req.params.eventId as string);
      res.json(items);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch agenda' });
    }
  },

  async create(req: Request, res: Response) {
    try {
      const item = await agendaService.create(req.params.eventId as string, req.body);
      res.status(201).json(item);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async update(req: Request, res: Response) {
    try {
      const item = await agendaService.update(req.params.itemId as string, req.body);
      res.json(item);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async remove(req: Request, res: Response) {
    try {
      await agendaService.remove(req.params.itemId as string);
      res.json({ message: 'Agenda item deleted' });
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async subscribeReminder(req: Request, res: Response) {
    try {
      const userId = req.userId!;
      await reminderService.subscribe(req.params.itemId as string, userId);
      res.json({ subscribed: true });
    } catch (err: any) {
      res.status(400).json({ error: err instanceof Error ? err.message : 'Failed to subscribe' });
    }
  },

  async unsubscribeReminder(req: Request, res: Response) {
    try {
      const userId = req.userId!;
      await reminderService.unsubscribe(req.params.itemId as string, userId);
      res.json({ subscribed: false });
    } catch (err: any) {
      res.status(400).json({ error: err instanceof Error ? err.message : 'Failed to unsubscribe' });
    }
  },

  async getUserReminders(req: Request, res: Response) {
    try {
      const userId = req.userId!;
      const itemIds = await reminderService.getUserReminders(req.params.eventId as string, userId);
      res.json(itemIds);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch reminders' });
    }
  },
};
