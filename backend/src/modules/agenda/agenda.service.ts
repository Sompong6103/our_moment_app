import prisma from '../../config/database';

export const agendaService = {
  async list(eventId: string) {
    return prisma.agendaItem.findMany({
      where: { eventId },
      orderBy: [{ sortOrder: 'asc' }, { dateTime: 'asc' }],
    });
  },

  async create(eventId: string, data: { title: string; description?: string; location?: string; dateTime: string; sortOrder?: number }) {
    return prisma.agendaItem.create({
      data: {
        eventId,
        title: data.title,
        description: data.description,
        location: data.location,
        dateTime: new Date(data.dateTime),
        sortOrder: data.sortOrder ?? 0,
      },
    });
  },

  async update(itemId: string, data: { title?: string; description?: string; location?: string; dateTime?: string; sortOrder?: number }) {
    return prisma.agendaItem.update({
      where: { id: itemId },
      data: {
        ...data,
        dateTime: data.dateTime ? new Date(data.dateTime) : undefined,
      },
    });
  },

  async remove(itemId: string) {
    await prisma.agendaItem.delete({ where: { id: itemId } });
  },
};
