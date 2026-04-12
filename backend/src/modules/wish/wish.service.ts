import prisma from '../../config/database';
import { emitToEvent } from '../../shared/socket';

export const wishService = {
  async list(eventId: string) {
    return prisma.wish.findMany({
      where: { eventId },
      include: { user: { select: { id: true, fullName: true, avatarUrl: true } } },
      orderBy: { createdAt: 'desc' },
    });
  },

  async create(eventId: string, userId: string, message: string) {
    // Check one-wish-per-guest
    const existing = await prisma.wish.findUnique({
      where: { eventId_userId: { eventId, userId } },
    });
    if (existing) throw new Error('You have already sent a wish for this event');

    const wish = await prisma.wish.create({
      data: { eventId, userId, message },
      include: { user: { select: { id: true, fullName: true, avatarUrl: true } } },
    });

    emitToEvent(eventId, 'wish:new', wish);
    return wish;
  },

  async remove(wishId: string) {
    await prisma.wish.delete({ where: { id: wishId } });
  },
};
