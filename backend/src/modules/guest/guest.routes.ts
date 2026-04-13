import { Router } from 'express';
import { guestController } from './guest.controller';
import { authenticate } from '../../middleware/auth';
import { requireHost, requireEventAccess } from '../../middleware/role';

const router = Router({ mergeParams: true });

router.use(authenticate);

router.post('/join', guestController.join);
router.post('/check-in', guestController.checkIn);
router.delete('/leave', guestController.leave);
router.get('/my-status', requireEventAccess, guestController.myStatus);
router.get('/', requireEventAccess, guestController.list);
router.get('/:guestId', requireEventAccess, guestController.getDetail);
router.patch('/:guestId', requireHost, guestController.update);

export default router;
