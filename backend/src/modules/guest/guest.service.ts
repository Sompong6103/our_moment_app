import prisma from '../../config/database';
import { emitToEvent } from '../../shared/socket';

export const guestService = {
  async joinEvent(userId: string, eventId: string, data?: { allergies?: string; followersCount?: number }) {
    const event = await prisma.event.findFirst({
      where: { id: eventId, deletedAt: null, status: 'published' },
    });
    if (!event) throw new Error('Event not found');
    if (event.organizerId === userId) throw new Error('Host cannot join as guest');

    const existing = await prisma.eventGuest.findUnique({
      where: { eventId_userId: { eventId, userId } },
    });
    if (existing) throw new Error('Already joined this event');

    const guest = await prisma.eventGuest.create({
      data: {
        eventId,
        userId,
        allergies: data?.allergies,
        followersCount: data?.followersCount || 0,
        status: 'joined',
      },
      include: { user: { select: { id: true, fullName: true, avatarUrl: true } } },
    });

    // Real-time notification
    emitToEvent(eventId, 'guest:joined', {
      id: guest.id,
      user: guest.user,
      joinedAt: guest.joinedAt,
    });

    return guest;
  },

  async checkIn(eventId: string, guestUserId: string) {
    const guest = await prisma.eventGuest.findUnique({
      where: { eventId_userId: { eventId, userId: guestUserId } },
    });

    if (!guest) throw new Error('Guest not found');
    if (guest.status === 'checked_in') throw new Error('Already checked in');

    const updated = await prisma.eventGuest.update({
      where: { id: guest.id },
      data: { status: 'checked_in', checkedInAt: new Date() },
      include: { user: { select: { id: true, fullName: true, avatarUrl: true } } },
    });

    emitToEvent(eventId, 'guest:checked-in', {
      id: updated.id,
      user: updated.user,
      checkedInAt: updated.checkedInAt,
    });

    return updated;
  },

  async list(eventId: string, status?: string) {
    const where: any = { eventId };
    if (status) where.status = status;

    return prisma.eventGuest.findMany({
      where,
      include: {
        user: { select: { id: true, fullName: true, email: true, avatarUrl: true } },
      },
      orderBy: { joinedAt: 'desc' },
    });
  },

  async getDetail(eventId: string, guestUserId: string) {
    const guest = await prisma.eventGuest.findUnique({
      where: { eventId_userId: { eventId, userId: guestUserId } },
      include: {
        user: { select: { id: true, fullName: true, email: true, avatarUrl: true, phoneNumber: true } },
      },
    });
    if (!guest) throw new Error('Guest not found');

    // Get photo count and wish
    const [photoCount, wish] = await Promise.all([
      prisma.photo.count({ where: { eventId, uploaderId: guestUserId, deletedAt: null } }),
      prisma.wish.findUnique({ where: { eventId_userId: { eventId, userId: guestUserId } } }),
    ]);

    return { ...guest, photoCount, wish };
  },

  async updateGuest(eventId: string, guestUserId: string, data: { allergies?: string; followersCount?: number }) {
    const guest = await prisma.eventGuest.findUnique({
      where: { eventId_userId: { eventId, userId: guestUserId } },
    });
    if (!guest) throw new Error('Guest not found');

    return prisma.eventGuest.update({
      where: { id: guest.id },
      data,
    });
  },

  async getGuestStatus(eventId: string, userId: string) {
    const guest = await prisma.eventGuest.findUnique({
      where: { eventId_userId: { eventId, userId } },
      select: { status: true, joinedAt: true, checkedInAt: true },
    });
    return guest;
  },
};
