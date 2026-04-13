import prisma from '../../config/database';
import { emitToEvent, emitToUser } from '../../shared/socket';

export const notificationService = {
  async list(userId: string) {
    return prisma.notification.findMany({
      where: { userId },
      include: { event: { select: { id: true, title: true } } },
      orderBy: { createdAt: 'desc' },
    });
  },

  async markAsRead(notificationId: string, userId: string) {
    return prisma.notification.updateMany({
      where: { id: notificationId, userId },
      data: { readAt: new Date() },
    });
  },

  async markAllRead(userId: string) {
    return prisma.notification.updateMany({
      where: { userId, readAt: null },
      data: { readAt: new Date() },
    });
  },

  async announce(eventId: string, title: string, message: string, target: 'all' | 'checked_in' = 'all') {
    const event = await prisma.event.findFirst({
      where: { id: eventId, deletedAt: null },
      select: { id: true, title: true },
    });
    if (!event) throw new Error('Event not found');

    const notifTitle = event.title;
    const notifMessage = `📢 Announcement from Host: ${message}`;

    // Get guests based on target
    const whereClause: any = { eventId };
    if (target === 'checked_in') {
      whereClause.status = 'checked_in';
    }
    const guests = await prisma.eventGuest.findMany({
      where: whereClause,
      select: { userId: true },
    });

    // Create notifications for all guests
    if (guests.length > 0) {
      await prisma.notification.createMany({
        data: guests.map((g:any) => ({
          userId: g.userId,
          eventId,
          type: 'update' as const,
          title: notifTitle,
          message: notifMessage,
        })),
      });

      // Real-time push to each user
      for (const g of guests) {
        emitToUser(g.userId, 'notification', { type: 'update', title: notifTitle, message: notifMessage, eventId, eventName: event.title, createdAt: new Date() });
      }
    }

    // Real-time broadcast
    emitToEvent(eventId, 'announcement', { title: notifTitle, message: notifMessage, eventId });

    return { recipientCount: guests.length };
  },

  async createForUser(userId: string, data: { eventId?: string; type: 'ceremony' | 'reminder' | 'update' | 'offer'; title: string; message: string }) {
    const notification = await prisma.notification.create({
      data: {
        userId,
        eventId: data.eventId,
        type: data.type,
        title: data.title,
        message: data.message,
      },
    });

    // Real-time push to user
    emitToUser(userId, 'notification', {
      id: notification.id,
      type: data.type,
      title: data.title,
      message: data.message,
      eventId: data.eventId,
      createdAt: notification.createdAt,
    });

    return notification;
  },
};
