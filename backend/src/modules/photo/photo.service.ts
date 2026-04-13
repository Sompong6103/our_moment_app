import prisma from '../../config/database';
import { moveFile, deleteFile } from '../../shared/storage';
import { processImage } from '../../shared/image';
import { emitToEvent } from '../../shared/socket';
import { detectFaces, searchFaceInEvent } from '../../shared/facepp';
import path from 'path';
import { env } from '../../config/env';

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

    // Detect faces asynchronously (don't block upload response)
    const fullImagePath = path.resolve(env.uploadDir, dest);
    detectFaces(fullImagePath).then(async (faceTokens) => {
      if (faceTokens.length > 0) {
        await prisma.photoFace.createMany({
          data: faceTokens.map((token) => ({
            photoId: photo.id,
            faceToken: token,
          })),
        });
      }
    }).catch((err) => {
      console.error('[Face++] Failed to detect faces for photo:', photo.id, err);
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
    const photo = await prisma.photo.findUnique({
      where: { id: photoId },
      select: { imageUrl: true },
    });

    await prisma.photo.update({
      where: { id: photoId },
      data: { deletedAt: new Date() },
    });

    // Delete actual file from uploads
    if (photo?.imageUrl) {
      deleteFile(photo.imageUrl);
    }

    emitToEvent(eventId, 'photo:deleted', { photoId });
  },

  async bulkRemove(eventId: string, photoIds: string[]) {
    // Get file paths before deleting
    const photos = await prisma.photo.findMany({
      where: { id: { in: photoIds }, eventId },
      select: { imageUrl: true },
    });

    await prisma.photo.updateMany({
      where: { id: { in: photoIds }, eventId },
      data: { deletedAt: new Date() },
    });

    // Delete actual files from uploads
    for (const photo of photos) {
      if (photo.imageUrl) {
        deleteFile(photo.imageUrl);
      }
    }

    emitToEvent(eventId, 'photo:bulk-deleted', { photoIds });
  },

  async searchByFace(eventId: string, selfiePath: string) {
    // Get all face tokens for this event
    const eventFaces = await prisma.photoFace.findMany({
      where: {
        photo: {
          eventId,
          deletedAt: null,
        },
      },
      select: {
        photoId: true,
        faceToken: true,
      },
    });

    if (eventFaces.length === 0) {
      // Process selfie to clean up temp file
      try { deleteFile(selfiePath); } catch (_) {}
      return [];
    }

    // Search using Face++ compare
    const matches = await searchFaceInEvent(selfiePath, eventFaces);

    // Clean up selfie temp file
    try {
      const fs = await import('fs');
      if (fs.existsSync(selfiePath)) fs.unlinkSync(selfiePath);
    } catch (_) {}

    if (matches.length === 0) return [];

    // Deduplicate by photoId (keep highest confidence)
    const bestByPhoto = new Map<string, number>();
    for (const m of matches) {
      const existing = bestByPhoto.get(m.photoId) || 0;
      if (m.confidence > existing) bestByPhoto.set(m.photoId, m.confidence);
    }

    const photoIds = Array.from(bestByPhoto.keys());

    // Fetch matching photos
    const photos = await prisma.photo.findMany({
      where: { id: { in: photoIds }, deletedAt: null },
      include: { uploader: { select: { id: true, fullName: true, avatarUrl: true } } },
      orderBy: { uploadedAt: 'desc' },
    });

    // Attach confidence and sort by it
    return photos.map((p) => ({
      ...p,
      confidence: bestByPhoto.get(p.id) || 0,
    })).sort((a, b) => b.confidence - a.confidence);
  },
};
