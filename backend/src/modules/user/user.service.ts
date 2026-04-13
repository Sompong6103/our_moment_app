import bcrypt from 'bcryptjs';
import prisma from '../../config/database';
import { moveFile, deleteFile } from '../../shared/storage';

export const userService = {
  async getProfile(userId: string) {
    const user = await prisma.user.findFirst({
      where: { id: userId, deletedAt: null },
      select: {
        id: true,
        fullName: true,
        email: true,
        phoneNumber: true,
        gender: true,
        avatarUrl: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) throw new Error('User not found');
    return user;
  },

  async updateProfile(userId: string, data: { fullName?: string; phoneNumber?: string; gender?: 'male' | 'female' | 'other' }) {
    const updateData: any = { ...data };
    if (updateData.gender) {
      updateData.gender = updateData.gender.toLowerCase();
    }
    return prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: {
        id: true,
        fullName: true,
        email: true,
        phoneNumber: true,
        gender: true,
        avatarUrl: true,
        updatedAt: true,
      },
    });
  },

  async uploadAvatar(userId: string, tempFilePath: string, filename: string) {
    // Delete old avatar file if exists
    const existing = await prisma.user.findUnique({
      where: { id: userId },
      select: { avatarUrl: true },
    });
    if (existing?.avatarUrl) {
      deleteFile(existing.avatarUrl);
    }

    const dest = await moveFile(tempFilePath, 'avatars', filename);

    return prisma.user.update({
      where: { id: userId },
      data: { avatarUrl: dest },
      select: { id: true, avatarUrl: true },
    });
  },

  async changePassword(userId: string, oldPassword: string, newPassword: string) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new Error('User not found');

    const valid = await bcrypt.compare(oldPassword, user.passwordHash);
    if (!valid) throw new Error('Current password is incorrect');

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await prisma.user.update({ where: { id: userId }, data: { passwordHash } });

    // Invalidate all refresh tokens
    await prisma.refreshToken.deleteMany({ where: { userId } });
  },
};
