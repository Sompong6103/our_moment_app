import prisma from '../../config/database';
import { moveFile, deleteFile } from '../../shared/storage';

function generateJoinCode(): string {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let code = '';
    for (let i = 0; i < 6; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
}

async function uniqueJoinCode(): Promise<string> {
    for (let i = 0; i < 10; i++) {
        const code = generateJoinCode();
        const exists = await prisma.event.findUnique({ where: { joinCode: code } });
        if (!exists) return code;
    }
    throw new Error('Failed to generate unique join code');
}

export const eventService = {
    async create(organizerId: string, data: {
        title: string;
        type: string;
        description?: string;
        dateStart: string;
        dateEnd: string;
        coverColor?: string;
        themeColor?: string;
        themeName?: string;
        expectedAttendeeCount?: number;
        acceptPhotos?: boolean;
        location?: { latitude: number; longitude: number; address?: string; placeId?: string };
        agendaItems?: { title: string; description?: string; location?: string; dateTime: string; sortOrder?: number }[];
    }) {
        const joinCode = await uniqueJoinCode();

        return prisma.event.create({
            data: {
                organizerId,
                title: data.title,
                type: data.type,
                description: data.description,
                dateStart: new Date(data.dateStart),
                dateEnd: new Date(data.dateEnd),
                coverColor: data.coverColor,
                themeColor: data.themeColor,
                themeName: data.themeName,
                expectedAttendeeCount: data.expectedAttendeeCount || 0,
                acceptPhotos: data.acceptPhotos ?? true,
                joinCode,
                status: 'published',
                location: data.location ? {
                    create: {
                        latitude: data.location.latitude,
                        longitude: data.location.longitude,
                        address: data.location.address,
                        placeId: data.location.placeId,
                    },
                } : undefined,
                agendaItems: data.agendaItems ? {
                    create: data.agendaItems.map((item, index) => ({
                        title: item.title,
                        description: item.description,
                        location: item.location,
                        dateTime: new Date(item.dateTime),
                        sortOrder: item.sortOrder ?? index,
                    })),
                } : undefined,
            },
            include: { location: true, agendaItems: true },
        });
    },

    async getById(eventId: string) {
        const event = await prisma.event.findFirst({
            where: { id: eventId, deletedAt: null },
            include: {
                organizer: { select: { id: true, fullName: true, avatarUrl: true } },
                location: true,
                _count: { select: { guests: true, photos: true, wishes: true } },
            },
        });
        if (!event) throw new Error('Event not found');
        return event;
    },

    async getByJoinCode(joinCode: string) {
        const event = await prisma.event.findFirst({
            where: { joinCode: joinCode.toUpperCase(), deletedAt: null },
            include: {
                organizer: { select: { id: true, fullName: true, avatarUrl: true } },
                location: true,
                _count: { select: { guests: true } },
            },
        });
        if (!event) throw new Error('Event not found');
        return event;
    },

    async listByUser(userId: string) {
        // Events where user is organizer or guest
        const [organized, joined] = await Promise.all([
            prisma.event.findMany({
                where: { organizerId: userId, deletedAt: null },
                include: {
                    organizer: { select: { id: true, fullName: true, avatarUrl: true } },
                    _count: { select: { guests: true } },
                    location: true,
                },
                orderBy: { dateStart: 'desc' },
            }),
            prisma.event.findMany({
                where: {
                    deletedAt: null,
                    guests: { some: { userId } },
                },
                include: {
                    organizer: { select: { id: true, fullName: true, avatarUrl: true } },
                    _count: { select: { guests: true } },
                    location: true,
                },
                orderBy: { dateStart: 'desc' },
            }),
        ]);

        return { organized, joined };
    },

    async update(eventId: string, data: {
        title?: string;
        type?: string;
        description?: string;
        dateStart?: string;
        dateEnd?: string;
        coverColor?: string;
        themeColor?: string;
        themeName?: string;
        expectedAttendeeCount?: number;
        acceptPhotos?: boolean;
        location?: { latitude: number; longitude: number; address?: string; placeId?: string };
    }) {
        const { location, ...eventData } = data;

        const event = await prisma.event.update({
            where: { id: eventId },
            data: {
                ...eventData,
                dateStart: eventData.dateStart ? new Date(eventData.dateStart) : undefined,
                dateEnd: eventData.dateEnd ? new Date(eventData.dateEnd) : undefined,
            },
            include: { location: true },
        });

        if (location) {
            await prisma.location.upsert({
                where: { eventId },
                create: {
                    eventId,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    address: location.address,
                    placeId: location.placeId,
                },
                update: {
                    latitude: location.latitude,
                    longitude: location.longitude,
                    address: location.address,
                    placeId: location.placeId,
                },
            });
        }

        return prisma.event.findUnique({
            where: { id: eventId },
            include: { location: true },
        });
    },

    async uploadCover(eventId: string, tempFilePath: string, filename: string) {
        // Delete old cover file if exists
        const existing = await prisma.event.findUnique({
            where: { id: eventId },
            select: { coverImageUrl: true },
        });
        if (existing?.coverImageUrl) {
            deleteFile(existing.coverImageUrl);
        }

        const dest = await moveFile(tempFilePath, `events/${eventId}`, filename);

        return prisma.event.update({
            where: { id: eventId },
            data: { coverImageUrl: dest },
            select: { id: true, coverImageUrl: true },
        });
    },

    async publish(eventId: string) {
        return prisma.event.update({
            where: { id: eventId },
            data: { status: 'published' },
        });
    },

    async softDelete(eventId: string) {
        return prisma.event.update({
            where: { id: eventId },
            data: { deletedAt: new Date() },
        });
    },
};
