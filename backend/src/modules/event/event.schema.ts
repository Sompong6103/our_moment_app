import { z } from 'zod';

export const createEventSchema = z.object({
  title: z.string().min(1).max(200),
  type: z.string().min(1).max(50),
  description: z.string().optional(),
  dateStart: z.string().datetime({ offset: true }),
  dateEnd: z.string().datetime({ offset: true }),
  coverColor: z.string().max(9).optional(),
  themeColor: z.string().max(9).optional(),
  themeName: z.string().max(50).optional(),
  expectedAttendeeCount: z.number().int().min(0).optional(),
  acceptPhotos: z.boolean().optional(),
  location: z.object({
    latitude: z.number(),
    longitude: z.number(),
    address: z.string().optional(),
    placeId: z.string().optional(),
  }).optional(),
  agendaItems: z.array(z.object({
    title: z.string().min(1).max(200),
    description: z.string().optional(),
    location: z.string().max(200).optional(),
    dateTime: z.string().datetime({ offset: true }),
    sortOrder: z.number().int().optional(),
  })).optional(),
});

export const updateEventSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  type: z.string().min(1).max(50).optional(),
  description: z.string().optional(),
  dateStart: z.string().datetime({ offset: true }).optional(),
  dateEnd: z.string().datetime({ offset: true }).optional(),
  coverColor: z.string().max(9).optional(),
  themeColor: z.string().max(9).optional(),
  themeName: z.string().max(50).optional(),
  expectedAttendeeCount: z.number().int().min(0).optional(),
  acceptPhotos: z.boolean().optional(),
  location: z.object({
    latitude: z.number(),
    longitude: z.number(),
    address: z.string().optional(),
    placeId: z.string().optional(),
  }).optional(),
  agendaItems: z.array(z.object({
    title: z.string().min(1).max(200),
    description: z.string().optional(),
    location: z.string().max(200).optional(),
    dateTime: z.string().datetime({ offset: true }),
    sortOrder: z.number().int().optional(),
  })).optional(),
});
