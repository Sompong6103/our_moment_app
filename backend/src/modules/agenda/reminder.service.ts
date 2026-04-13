import prisma from '../../config/database';
import { notificationService } from '../notification/notification.service';

export const reminderService = {
  /** Subscribe a user to reminders for an agenda item */
  async subscribe(agendaItemId: string, userId: string) {
    return prisma.agendaReminder.upsert({
      where: { agendaItemId_userId: { agendaItemId, userId } },
      create: { agendaItemId, userId },
      update: {},
    });
  },

  /** Unsubscribe a user from reminders for an agenda item */
  async unsubscribe(agendaItemId: string, userId: string) {
    await prisma.agendaReminder.deleteMany({
      where: { agendaItemId, userId },
    });
  },

  /** Get all agenda item IDs that a user is subscribed to for an event */
  async getUserReminders(eventId: string, userId: string): Promise<string[]> {
    const reminders = await prisma.agendaReminder.findMany({
      where: {
        userId,
        agendaItem: { eventId },
      },
      select: { agendaItemId: true },
    });
    return reminders.map((r) => r.agendaItemId);
  },

  /** Check for upcoming agenda items and send reminder notifications */
  async processReminders() {
    const now = new Date();
    const fifteenMinLater = new Date(now.getTime() + 15 * 60 * 1000);

    // Find reminders where:
    // - agenda item dateTime is within the next 15 minutes
    // - notification hasn't been sent yet (notifiedAt is null)
    const pendingReminders = await prisma.agendaReminder.findMany({
      where: {
        notifiedAt: null,
        agendaItem: {
          dateTime: {
            gt: now,
            lte: fifteenMinLater,
          },
        },
      },
      include: {
        agendaItem: {
          include: {
            event: { select: { id: true, title: true } },
          },
        },
      },
    });

    if (pendingReminders.length === 0) return;

    // Group by user to batch notifications
    for (const reminder of pendingReminders) {
      const { agendaItem } = reminder;
      const eventTitle = agendaItem.event.title;
      const agendaTitle = agendaItem.title;

      await notificationService.createForUser(reminder.userId, {
        eventId: agendaItem.eventId,
        type: 'reminder',
        title: eventTitle,
        message: `"${agendaTitle}" is starting soon!`,
      });

      // Mark as notified
      await prisma.agendaReminder.update({
        where: { id: reminder.id },
        data: { notifiedAt: new Date() },
      });
    }

    if (pendingReminders.length > 0) {
      console.log(`✅ Sent ${pendingReminders.length} agenda reminder(s)`);
    }
  },
};
