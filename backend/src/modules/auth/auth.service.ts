import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import prisma from '../../config/database';
import { env } from '../../config/env';
import { AuthPayload } from '../../middleware/auth';

const SALT_ROUNDS = 12;

function generateAccessToken(userId: string): string {
  return jwt.sign({ userId } as AuthPayload, env.jwtAccessSecret, {
    expiresIn: env.jwtAccessExpiresIn as unknown as jwt.SignOptions['expiresIn'],
  });
}

function generateRefreshToken(): string {
  return uuidv4() + '-' + uuidv4();
}

async function saveRefreshToken(userId: string, token: string): Promise<void> {
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 7);

  await prisma.refreshToken.create({
    data: { token, userId, expiresAt },
  });
}

export const authService = {
  async register(fullName: string, email: string, password: string) {
    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      throw new Error('Email already registered');
    }

    const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

    const user = await prisma.user.create({
      data: { fullName, email, passwordHash },
      select: { id: true, fullName: true, email: true, avatarUrl: true, createdAt: true },
    });

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken();
    await saveRefreshToken(user.id, refreshToken);

    return { user, accessToken, refreshToken };
  },

  async login(email: string, password: string) {
    const user = await prisma.user.findFirst({
      where: { email, deletedAt: null },
    });

    if (!user) {
      throw new Error('Invalid email or password');
    }

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      throw new Error('Invalid email or password');
    }

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken();
    await saveRefreshToken(user.id, refreshToken);

    return {
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        avatarUrl: user.avatarUrl,
      },
      accessToken,
      refreshToken,
    };
  },

  async googleLogin(idToken: string) {
    // Verify Google ID token
    const res = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`);
    if (!res.ok) {
      throw new Error('Invalid Google token');
    }

    const payload = await res.json() as { sub: string; email: string; name: string; picture?: string };
    const { sub: googleId, email, name, picture } = payload;

    if (!email) {
      throw new Error('Google account has no email');
    }

    // Find or create user
    let user = await prisma.user.findFirst({
      where: { OR: [{ googleId }, { email }] },
    });

    if (!user) {
      user = await prisma.user.create({
        data: {
          fullName: name || 'User',
          email,
          googleId,
          avatarUrl: picture || null,
          passwordHash: await bcrypt.hash(uuidv4(), SALT_ROUNDS),
        },
      });
    } else if (!user.googleId) {
      // Link google account to existing email user
      user = await prisma.user.update({
        where: { id: user.id },
        data: { googleId, avatarUrl: user.avatarUrl || picture },
      });
    }

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken();
    await saveRefreshToken(user.id, refreshToken);

    return {
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        avatarUrl: user.avatarUrl,
      },
      accessToken,
      refreshToken,
    };
  },

  async refreshAccessToken(token: string) {
    const stored = await prisma.refreshToken.findUnique({
      where: { token },
      include: { user: { select: { id: true, deletedAt: true } } },
    });

    if (!stored || stored.expiresAt < new Date() || stored.user.deletedAt) {
      throw new Error('Invalid refresh token');
    }

    // Rotate refresh token
    await prisma.refreshToken.delete({ where: { id: stored.id } });

    const accessToken = generateAccessToken(stored.userId);
    const newRefreshToken = generateRefreshToken();
    await saveRefreshToken(stored.userId, newRefreshToken);

    return { accessToken, refreshToken: newRefreshToken };
  },

  async logout(token: string) {
    await prisma.refreshToken.deleteMany({ where: { token } });
  },

  async forgotPassword(email: string) {
    const user = await prisma.user.findFirst({ where: { email, deletedAt: null } });
    if (!user) {
      // Don't reveal if email exists
      return;
    }

    // Generate reset token (store as a refresh token with short expiry)
    const resetToken = uuidv4();
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 1);

    await prisma.refreshToken.create({
      data: { token: `reset:${resetToken}`, userId: user.id, expiresAt },
    });

    // In production, send email with reset link
    console.log(`[Reset] Token for ${email}: ${resetToken}`);
    // TODO: integrate email service
  },

  async resetPassword(token: string, newPassword: string) {
    const stored = await prisma.refreshToken.findUnique({
      where: { token: `reset:${token}` },
    });

    if (!stored || stored.expiresAt < new Date()) {
      throw new Error('Invalid or expired reset token');
    }

    const passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);

    await prisma.user.update({
      where: { id: stored.userId },
      data: { passwordHash },
    });

    // Invalidate all refresh tokens for this user
    await prisma.refreshToken.deleteMany({ where: { userId: stored.userId } });
  },
};
