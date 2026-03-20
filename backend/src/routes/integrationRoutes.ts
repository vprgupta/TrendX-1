import express from 'express';
import { getIntegrationStatus } from '../controllers/integrationController';
import { getYouTubeTrends } from '../services/youtubeService';

const router = express.Router();

router.get('/status', getIntegrationStatus);

router.get('/youtube/trending', async (req, res) => {
    try {
        const country = (req.query.country as string) || 'US';
        const category = (req.query.category as string) || '28';
        const trends = await getYouTubeTrends(country, category);
        res.json({ success: true, count: trends.length, trends });
    } catch (error) {
        res.status(500).json({ success: false, error: 'Failed' });
    }
});

export default router;
