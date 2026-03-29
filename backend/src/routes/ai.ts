import express from 'express';
import { explainContent } from '../controllers/aiController';

const router = express.Router();

// Used for AI Explanations across the app. Add ratelimiting or auth later if needed.
router.post('/explain', explainContent);

export default router;
