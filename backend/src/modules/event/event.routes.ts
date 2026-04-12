import { Router } from 'express';
import { eventController } from './event.controller';
import { authenticate } from '../../middleware/auth';
import { requireHost } from '../../middleware/role';
import { validate } from '../../middleware/validate';
import { upload } from '../../middleware/upload';
import { createEventSchema, updateEventSchema } from './event.schema';

const router = Router();

router.use(authenticate);

router.post('/', validate(createEventSchema), eventController.create);
router.get('/', eventController.list);
router.get('/code/:joinCode', eventController.getByJoinCode);
router.get('/:eventId', eventController.getById);
router.patch('/:eventId', requireHost, validate(updateEventSchema), eventController.update);
router.post('/:eventId/cover', requireHost, upload.single('cover'), eventController.uploadCover);
router.put('/:eventId/publish', requireHost, eventController.publish);
router.delete('/:eventId', requireHost, eventController.remove);

export default router;
