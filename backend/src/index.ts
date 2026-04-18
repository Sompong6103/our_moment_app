import http from 'http';
import app from './app';
import { env } from './config/env';
import { initSocket } from './shared/socket';
import { startReminderScheduler } from './shared/scheduler';

const server = http.createServer(app);

// Initialize Socket.IO
initSocket(server);

// Start agenda reminder scheduler
startReminderScheduler();

server.listen(env.port, () => {
  console.log(`🚀 Server running on port ${env.port}`);
  console.log(`📁 Environment: ${env.nodeEnv}`);
  console.log(`🔗 API: http://localhost:${env.port}/api`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received. Shutting down...');
  server.close(() => {
    process.exit(0);
  });
});
