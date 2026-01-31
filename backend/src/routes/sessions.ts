import express from 'express';
import * as sessionController from '../controllers/sessionController';
import { authenticate } from '../middleware/auth';

const router = express.Router();

// All session routes require authentication
router.use(authenticate);

router.post('/start', sessionController.startSession);
router.put('/activity', sessionController.updateSessionActivity);
router.post('/end', sessionController.endSession);
router.get('/active', sessionController.getActiveSession);
router.post('/sync', sessionController.syncSession);
router.put('/switch', sessionController.switchPlatform);

export default router;