import { Request, Response } from 'express';
import { analyticsService } from './analytics.service';

export const analyticsController = {
  async getOverview(req: Request, res: Response) {
    try {
      const overview = await analyticsService.getOverview(req.params.eventId as string);
      res.json(overview);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch analytics' });
    }
  },

  async getTopContributors(req: Request, res: Response) {
    try {
      const contributors = await analyticsService.getTopContributors(req.params.eventId as string);
      res.json(contributors);
    } catch (err: any) {
      res.status(500).json({ error: 'Failed to fetch contributors' });
    }
  },
};
