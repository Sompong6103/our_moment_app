import prisma from '../../config/database';
import { moveFile } from '../../shared/storage';
import { processImage } from '../../shared/image';
import { emitToEvent } from '../../shared/socket';

export const photoService = {
  async upload(eventId: string, uploaderId: string, tempFilePath: string, filename: string) {
    // Check if event accepts photos
    const event = await prisma.event.findFirst({
      where: { id: eventId, deletedAt: null },
      select: { acceptPhotos: true, organizerId: true },
    });
    if (!event) throw new Error('Event not found');

    const isHost = event.organizerId === uploaderId;
    if (!event.acceptPhotos && !isHost) {
      throw new Error('This event is not accepting photos');
    }

    // Process image (resize/compress)
    const processed = await processImage(tempFilePath);
    const dest = await moveFile(processed, `events/${eventId}/photos`, filename);

    const photo = await prisma.photo.create({
      data: {
        eventId,
        uploaderId,
        imageUrl: dest,
      },
      include: { uploader: { select: { id: true, fullName: true, avatarUrl: true } } },
    });

    emitToEvent(eventId, 'photo:uploaded', photo);
    return photo;
  },

  async list(eventId: string) {
    return prisma.photo.findMany({
      where: { eventId, deletedAt: null },
      include: { uploader: { select: { id: true, fullName: true, avatarUrl: true } } },
      orderBy: { uploadedAt: 'desc' },
    });
  },

  async remove(eventId: string, photoId: string) {
    await prisma.photo.update({
      where: { id: photoId },
      data: { deletedAt: new Date() },
    });

    emitToEvent(eventId, 'photo:deleted', { photoId });
  },

  async bulkRemove(eventId: string, photoIds: string[]) {
    await prisma.photo.updateMany({
      where: { id: { in: photoIds }, eventId },
      data: { deletedAt: new Date() },
    });

    emitToEvent(eventId, 'photo:bulk-deleted', { photoIds });
  },
};
