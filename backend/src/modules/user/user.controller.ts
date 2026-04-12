import { Request, Response } from 'express';
import { userService } from './user.service';

export const userController = {
  async getProfile(req: Request, res: Response) {
    try {
      const user = await userService.getProfile(req.userId!);
      res.json(user);
    } catch (err: any) {
      res.status(404).json({ error: err.message });
    }
  },

  async updateProfile(req: Request, res: Response) {
    try {
      const { fullName, phoneNumber, gender } = req.body;
      const user = await userService.updateProfile(req.userId!, { fullName, phoneNumber, gender });
      res.json(user);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async uploadAvatar(req: Request, res: Response) {
    try {
      if (!req.file) {
        res.status(400).json({ error: 'No file uploaded' });
        return;
      }
      const result = await userService.uploadAvatar(req.userId!, req.file.path, req.file.filename);
      res.json(result);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  },

  async changePassword(req: Request, res: Response) {
    try {
      const { oldPassword, newPassword } = req.body;
      await userService.changePassword(req.userId!, oldPassword, newPassword);
      res.json({ message: 'Password changed successfully' });
    } catch (err: any) {
      if (err.message === 'Current password is incorrect') {
        res.status(400).json({ error: err.message });
        return;
      }
      res.status(500).json({ error: 'Failed to change password' });
    }
  },
};
