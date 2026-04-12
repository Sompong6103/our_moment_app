import { Request, Response } from 'express';
import { authService } from './auth.service';

export const authController = {
  async register(req: Request, res: Response) {
    try {
      const { fullName, email, password } = req.body;
      const result = await authService.register(fullName, email, password);
      res.status(201).json(result);
    } catch (err: any) {
      if (err.message === 'Email already registered') {
        res.status(409).json({ error: err.message });
        return;
      }
      res.status(500).json({ error: 'Registration failed' });
    }
  },

  async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;
      const result = await authService.login(email, password);
      res.json(result);
    } catch (err: any) {
      if (err.message === 'Invalid email or password') {
        res.status(401).json({ error: err.message });
        return;
      }
      res.status(500).json({ error: 'Login failed' });
    }
  },

  async googleLogin(req: Request, res: Response) {
    try {
      const { idToken } = req.body;
      const result = await authService.googleLogin(idToken);
      res.json(result);
    } catch (err: any) {
      if (err.message.includes('Invalid Google') || err.message.includes('no email')) {
        res.status(401).json({ error: err.message });
        return;
      }
      res.status(500).json({ error: 'Google login failed' });
    }
  },

  async refreshToken(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;
      const result = await authService.refreshAccessToken(refreshToken);
      res.json(result);
    } catch (err: any) {
      res.status(401).json({ error: 'Invalid refresh token' });
    }
  },

  async logout(req: Request, res: Response) {
    try {
      const { refreshToken } = req.body;
      await authService.logout(refreshToken);
      res.json({ message: 'Logged out' });
    } catch {
      res.json({ message: 'Logged out' });
    }
  },

  async forgotPassword(req: Request, res: Response) {
    try {
      const { email } = req.body;
      await authService.forgotPassword(email);
      res.json({ message: 'If the email exists, a reset link has been sent' });
    } catch {
      res.json({ message: 'If the email exists, a reset link has been sent' });
    }
  },

  async resetPassword(req: Request, res: Response) {
    try {
      const { token, password } = req.body;
      await authService.resetPassword(token, password);
      res.json({ message: 'Password reset successful' });
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },
};
