import express from 'express';
import { getIntegrationStatus } from '../controllers/integrationController';

const router = express.Router();

router.get('/status', getIntegrationStatus);

export default router;
