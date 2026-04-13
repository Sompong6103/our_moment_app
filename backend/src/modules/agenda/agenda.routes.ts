import { Router } from 'express';
import { agendaController } from './agenda.controller';
import { authenticate } from '../../middleware/auth';
import { requireHost, requireEventAccess } from '../../middleware/role';

const router = Router({ mergeParams: true });

router.use(authenticate);

router.get('/', requireEventAccess, agendaController.list);
router.post('/', requireHost, agendaController.create);
router.patch('/:itemId', requireHost, agendaController.update);
router.delete('/:itemId', requireHost, agendaController.remove);

// Reminder subscription endpoints
router.get('/reminders', requireEventAccess, agendaController.getUserReminders);
router.post('/:itemId/remind', requireEventAccess, agendaController.subscribeReminder);
router.delete('/:itemId/remind', requireEventAccess, agendaController.unsubscribeReminder);

export default router;
