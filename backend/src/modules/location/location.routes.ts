import { Router } from 'express';
import { locationController } from './location.controller';
import { authenticate } from '../../middleware/auth';

const router = Router();

router.use(authenticate);

router.get('/search', locationController.search);
router.get('/reverse', locationController.reverseGeocode);

export default router;
