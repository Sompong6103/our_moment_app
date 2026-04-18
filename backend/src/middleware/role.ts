import { Request, Response, NextFunction } from 'express';
import prisma from '../config/database';

/**
 * Middleware: require user to be the host (organizer) of the event.
 * Expects `req.params.eventId` and `req.userId` to be set.
 */
export const requireHost = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const eventId = req.params.eventId as string;

  const event = await prisma.event.findFirst({
    where: { id: eventId, deletedAt: null },
    select: { organizerId: true },
  });

  if (!event) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }

  if (event.organizerId !== req.userId) {
    res.status(403).json({ error: 'Only the event host can perform this action' });
    return;
  }

  next();
};

/**
 * Middleware: require user to be a guest of the event (or the host).
 */
export const requireEventAccess = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const eventId = req.params.eventId as string;

  const event = await prisma.event.findFirst({
    where: { id: eventId, deletedAt: null },
    select: { organizerId: true },
  });

  if (!event) {
    res.status(404).json({ error: 'Event not found' });
    return;
  }

  // Host always has access
  if (event.organizerId === req.userId) {
    next();
    return;
  }

  // Check if user is a guest
  const guest = await prisma.eventGuest.findUnique({
    where: { eventId_userId: { eventId, userId: req.userId! } },
  });

  if (!guest) {
    res.status(403).json({ error: 'You do not have access to this event' });
    return;
  }

  next();
};
