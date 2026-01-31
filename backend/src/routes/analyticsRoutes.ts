import express from 'express';
import {
    getAnalyticsOverview,
    getSentimentAnalysis,
    getTopTrends,
    getTrendChartData
} from '../controllers/analyticsController';

const router = express.Router();

router.get('/overview', getAnalyticsOverview);
router.get('/sentiment', getSentimentAnalysis);
router.get('/top-trends', getTopTrends);
router.get('/chart', getTrendChartData);

export default router;
