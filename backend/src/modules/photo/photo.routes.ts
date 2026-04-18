import { Router } from 'express';
import { photoController } from './photo.controller';
import { authenticate } from '../../middleware/auth';
import { requireHost, requireEventAccess } from '../../middleware/role';
import { upload } from '../../middleware/upload';

const router = Router({ mergeParams: true });

router.use(authenticate);

router.get('/', requireEventAccess, photoController.list);
router.post('/', requireEventAccess, upload.single('photo'), photoController.upload);
router.delete('/:photoId', requireHost, photoController.remove);
router.post('/bulk-delete', requireHost, photoController.bulkRemove);
router.post('/face-search', requireEventAccess, upload.single('selfie'), photoController.searchByFace);

export default router;
