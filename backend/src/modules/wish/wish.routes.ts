import { Router } from 'express';
import { wishController } from './wish.controller';
import { authenticate } from '../../middleware/auth';
import { requireHost, requireEventAccess } from '../../middleware/role';

const router = Router({ mergeParams: true });

router.use(authenticate);

router.get('/', requireEventAccess, wishController.list);
router.post('/', requireEventAccess, wishController.create);
router.delete('/:wishId', requireHost, wishController.remove);

export default router;
