import { Router } from 'express';
import { analyticsController } from './analytics.controller';
import { authenticate } from '../../middleware/auth';
import { requireHost } from '../../middleware/role';

const router = Router({ mergeParams: true });

router.use(authenticate);

router.get('/', requireHost, analyticsController.getOverview);
router.get('/top-contributors', requireHost, analyticsController.getTopContributors);

export default router;
