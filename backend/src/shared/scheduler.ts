import cron from 'node-cron';
import { reminderService } from '../modules/agenda/reminder.service';

export function startReminderScheduler() {
  // Run every minute to check for upcoming agenda items
  cron.schedule('* * * * *', async () => {
    try {
      await reminderService.processReminders();
    } catch (err) {
      console.error('Reminder scheduler error:', err);
    }
  });

  console.log('⏰ Agenda reminder scheduler started');
}
