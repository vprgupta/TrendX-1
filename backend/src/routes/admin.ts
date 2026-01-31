import express from 'express';
import * as adminController from '../controllers/adminController';

const router = express.Router();

// Admin dashboard routes (no auth for demo - add auth middleware in production)
router.get('/stats', adminController.getDashboardStats);
router.get('/users', adminController.getUsersWithActivity);
router.get('/users/:userId/activity', adminController.getUserActivityDetails);
router.get('/active-users', adminController.getActiveUsers);
router.get('/analytics', adminController.getAnalytics);

// NEW: Advanced analytics using aggregation pipelines
const analyticsAgg = require('../utils/aggregations');

router.get('/analytics/dashboard', async (req, res) => {
    try {
        const stats = await analyticsAgg.getDashboardStats();
        res.json(stats);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch dashboard stats' });
    }
});

router.get('/analytics/trending/category', async (req, res) => {
    try {
        const data = await analyticsAgg.getTrendingByCategory();
        res.json({ data });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch data' });
    }
});

router.get('/analytics/trending/country', async (req, res) => {
    try {
        const data = await analyticsAgg.getTrendingByCountry();
        res.json({ data });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch data' });
    }
});

router.get('/analytics/platforms', async (req, res) => {
    try {
        const data = await analyticsAgg.getPlatformMetrics();
        res.json({ data });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch data' });
    }
});

export default router;