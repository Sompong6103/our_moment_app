import prisma from '../../config/database';
import { moveFile, deleteFile } from '../../shared/storage';
import { processImage } from '../../shared/image';
import { emitToEvent } from '../../shared/socket';
import { detectFaces, ensureFaceSet, addFacesToSet, searchFaceInFaceSet, removeFacesFromSet } from '../../shared/facepp';
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
        // Add to event's FaceSet for Search API
        await ensureFaceSet(eventId);
        await addFacesToSet(eventId, faceTokens);
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

    // Remove face_tokens from FaceSet
    const faces = await prisma.photoFace.findMany({
      where: { photoId },
      select: { faceToken: true },
    });
    if (faces.length > 0) {
      removeFacesFromSet(eventId, faces.map((f) => f.faceToken)).catch(() => {});
    }

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
    // Get file paths and face tokens before deleting
    const photos = await prisma.photo.findMany({
      where: { id: { in: photoIds }, eventId },
      select: { imageUrl: true },
    });
    const faces = await prisma.photoFace.findMany({
      where: { photoId: { in: photoIds } },
      select: { faceToken: true },
    });

    await prisma.photo.updateMany({
      where: { id: { in: photoIds }, eventId },
      data: { deletedAt: new Date() },
    });

    // Remove face_tokens from FaceSet
    if (faces.length > 0) {
      removeFacesFromSet(eventId, faces.map((f) => f.faceToken)).catch(() => {});
    }

    // Delete actual files from uploads
    for (const photo of photos) {
      if (photo.imageUrl) {
        deleteFile(photo.imageUrl);
      }
    }

    emitToEvent(eventId, 'photo:bulk-deleted', { photoIds });
  },

  async searchByFace(eventId: string, selfiePath: string) {
    // Use Face++ Search API against event's FaceSet (single API call)
    const matches = await searchFaceInFaceSet(selfiePath, eventId);

    // Clean up selfie temp file
    try {
      const fs = await import('fs');
      if (fs.existsSync(selfiePath)) fs.unlinkSync(selfiePath);
    } catch (_) {}

    if (matches.length === 0) return [];

    // Map face_tokens back to photoIds
    const matchedTokens = matches.map((m) => m.faceToken);
    const faceRecords = await prisma.photoFace.findMany({
      where: {
        faceToken: { in: matchedTokens },
        photo: { eventId, deletedAt: null },
      },
      select: { photoId: true, faceToken: true },
    });

    // Build confidence map: photoId -> highest confidence
    const bestByPhoto = new Map<string, number>();
    for (const record of faceRecords) {
      const match = matches.find((m) => m.faceToken === record.faceToken);
      if (!match) continue;
      const existing = bestByPhoto.get(record.photoId) || 0;
      if (match.confidence > existing) bestByPhoto.set(record.photoId, match.confidence);
    }

    const photoIds = Array.from(bestByPhoto.keys());
    if (photoIds.length === 0) return [];

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
