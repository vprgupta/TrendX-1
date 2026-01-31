import express from 'express';
import * as trendController from '../controllers/trendController';
import { authenticate } from '../middleware/auth';
import { validateTrend } from '../middleware/validation';
import { TrendAggregator } from '../services/trendAggregationService';
import { PreferencesService } from '../services/preferencesService';
import Trend from '../models/Trend';

const router = express.Router();

// Existing routes
router.get('/', trendController.getTrends);
router.get('/search', trendController.searchTrends);
router.get('/platform/:platform', trendController.getTrendsByPlatform);
router.get('/country/:country', trendController.getTrendsByCountry);
router.get('/category/:category', trendController.getTrendsByCategory);
router.get('/:id', trendController.getTrendById);
router.post('/', authenticate, validateTrend, trendController.createTrend);
router.put('/:id', authenticate, validateTrend, trendController.updateTrend);
router.delete('/:id', authenticate, trendController.deleteTrend);

/**
 * GET /api/trends/global
 * Get global trending topics (across all platforms)
 */
router.get('/trending/global', async (req, res) => {
    try {
        const globalTrends = await TrendAggregator.getGlobalTrending();

        res.json({
            success: true,
            count: globalTrends.length,
            trends: globalTrends,
            lastUpdated: new Date()
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch global trends'
        });
    }
});

/**
 * GET /api/trends/trending/platform/:platform
 * Get trending content for a specific platform
 */
router.get('/trending/platform/:platform', async (req, res) => {
    try {
        const { platform } = req.params;
        const trends = await Trend.find({
            platform: platform,
            createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) }
        })
            .sort({ trendingScore: -1 })
            .limit(50)
            .lean();

        res.json({
            success: true,
            platform,
            count: trends.length,
            trends
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch platform trends'
        });
    }
});

/**
 * GET /api/trends/trending/category/:category
 * Get trending content for a specific category
 */
router.get('/trending/category/:category', async (req, res) => {
    try {
        const { category } = req.params;
        const trends = await TrendAggregator.getTrendingByCategory(category);

        res.json({
            success: true,
            category,
            count: trends.length,
            trends
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch category trends'
        });
    }
});

/**
 * GET /api/trends/trending/country/:country
 * Get trending content for a specific country
 */
router.get('/trending/country/:country', async (req, res) => {
    try {
        const { country } = req.params;
        const trends = await Trend.find({
            country: country,
            createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) }
        })
            .sort({ trendingScore: -1 })
            .limit(50)
            .lean();

        res.json({
            success: true,
            country,
            count: trends.length,
            trends
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch country trends'
        });
    }
});

/**
 * GET /api/trends/personalized
 * Get personalized trends based on user preferences
 */
router.get('/personalized', authenticate, async (req, res) => {
    try {
        const userId = (req as any).user.id;
        const preferences = await PreferencesService.getUserPreferences(userId);

        // Build query based on preferences
        const query: any = {
            createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
            $or: [
                { platform: { $in: preferences.platforms || [] } },
                { category: { $in: [...(preferences.worldCategories || []), ...(preferences.techCategories || [])] } },
                { country: { $in: preferences.countries || [] } }
            ]
        };

        const trends = await Trend.find(query)
            .sort({ trendingScore: -1 })
            .limit(100)
            .lean();

        // Re-rank based on user preference match
        const rankedTrends = trends.map(trend => ({
            ...trend,
            relevanceScore: PreferencesService.calculateRelevanceScore(trend, preferences)
        }))
            .sort((a, b) => b.relevanceScore - a.relevanceScore)
            .slice(0, 50);

        res.json({
            success: true,
            count: rankedTrends.length,
            trends: rankedTrends,
            preferences
        });
    } catch (error) {
        console.error('Personalized trends error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch personalized trends'
        });
    }
});

export default router;