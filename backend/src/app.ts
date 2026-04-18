import express from 'express';
import cors from 'cors';
import path from 'path';
import { env } from './config/env';
import { errorHandler } from './middleware/error-handler';

// Route imports
import authRoutes from './modules/auth/auth.routes';
import userRoutes from './modules/user/user.routes';
import eventRoutes from './modules/event/event.routes';
import guestRoutes from './modules/guest/guest.routes';
import agendaRoutes from './modules/agenda/agenda.routes';
import photoRoutes from './modules/photo/photo.routes';
import wishRoutes from './modules/wish/wish.routes';
import notificationRoutes from './modules/notification/notification.routes';
import analyticsRoutes from './modules/analytics/analytics.routes';
import locationRoutes from './modules/location/location.routes';

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files
app.use('/uploads', express.static(path.resolve(env.uploadDir)));

// Health check
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/events/:eventId/guests', guestRoutes);
app.use('/api/events/:eventId/agenda', agendaRoutes);
app.use('/api/events/:eventId/photos', photoRoutes);
app.use('/api/events/:eventId/wishes', wishRoutes);
app.use('/api/events/:eventId/analytics', analyticsRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/locations', locationRoutes);

// Error handler (must be last)
app.use(errorHandler);

export default app;
