import { Request, Response } from 'express';
import { agendaService } from './agenda.service';

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
};
