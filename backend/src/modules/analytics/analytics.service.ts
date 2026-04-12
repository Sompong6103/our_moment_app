import prisma from '../../config/database';

export const analyticsService = {
  async getOverview(eventId: string) {
    const [
      registeredCount,
      checkedInCount,
      photoCount,
      wishCount,
      guests,
    ] = await Promise.all([
      prisma.eventGuest.count({ where: { eventId } }),
      prisma.eventGuest.count({ where: { eventId, status: 'checked_in' } }),
      prisma.photo.count({ where: { eventId, deletedAt: null } }),
      prisma.wish.count({ where: { eventId } }),
      prisma.eventGuest.findMany({
        where: { eventId, checkedInAt: { not: null } },
        select: { checkedInAt: true },
      }),
    ]);

    // Calculate check-in trend (hourly)
    const hourlyCheckIns: Record<number, number> = {};
    guests.forEach((g) => {
      if (g.checkedInAt) {
        const hour = g.checkedInAt.getHours();
        hourlyCheckIns[hour] = (hourlyCheckIns[hour] || 0) + 1;
      }
    });

    // Peak check-in time
    let peakHour = 0;
    let peakCount = 0;
    for (const [hour, count] of Object.entries(hourlyCheckIns)) {
      if (count > peakCount) {
        peakHour = parseInt(hour);
        peakCount = count;
      }
    }

    return {
      registeredCount,
      checkedInCount,
      photoCount,
      wishCount,
      checkInTrend: hourlyCheckIns,
      peakCheckInTime: peakCount > 0 ? `${peakHour.toString().padStart(2, '0')}:00 - ${peakHour.toString().padStart(2, '0')}:30` : null,
    };
  },

  async getTopContributors(eventId: string) {
    const contributors = await prisma.photo.groupBy({
      by: ['uploaderId'],
      where: { eventId, deletedAt: null },
      _count: { id: true },
      orderBy: { _count: { id: 'desc' } },
      take: 10,
    });

    const userIds = contributors.map((c) => c.uploaderId);
    const users = await prisma.user.findMany({
      where: { id: { in: userIds } },
      select: { id: true, fullName: true, avatarUrl: true },
    });

    const userMap = new Map(users.map((u) => [u.id, u]));

    return contributors.map((c) => ({
      user: userMap.get(c.uploaderId),
      photoCount: c._count.id,
    }));
  },
};
