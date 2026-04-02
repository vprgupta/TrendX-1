"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const trendController = __importStar(require("../controllers/trendController"));
const auth_1 = require("../middleware/auth");
const validation_1 = require("../middleware/validation");
const trendAggregationService_1 = require("../services/trendAggregationService");
const preferencesService_1 = require("../services/preferencesService");
const Trend_1 = __importDefault(require("../models/Trend"));
const router = express_1.default.Router();
// Existing routes
router.get('/', trendController.getTrends);
router.get('/search', trendController.searchTrends);
router.get('/platform/:platform', trendController.getTrendsByPlatform);
router.get('/country/:country', trendController.getTrendsByCountry);
router.get('/category/:category', trendController.getTrendsByCategory);
router.get('/:id', trendController.getTrendById);
router.post('/', auth_1.authenticate, validation_1.validateTrend, trendController.createTrend);
router.put('/:id', auth_1.authenticate, validation_1.validateTrend, trendController.updateTrend);
router.delete('/:id', auth_1.authenticate, trendController.deleteTrend);
/**
 * GET /api/trends/global
 * Get global trending topics (across all platforms)
 */
router.get('/trending/global', async (req, res) => {
    try {
        const globalTrends = await trendAggregationService_1.TrendAggregator.getGlobalTrending();
        res.json({
            success: true,
            count: globalTrends.length,
            trends: globalTrends,
            lastUpdated: new Date()
        });
    }
    catch (error) {
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
        const trends = await Trend_1.default.find({
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
    }
    catch (error) {
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
        const trends = await trendAggregationService_1.TrendAggregator.getTrendingByCategory(category);
        res.json({
            success: true,
            category,
            count: trends.length,
            trends
        });
    }
    catch (error) {
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
        const trends = await Trend_1.default.find({
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
    }
    catch (error) {
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
router.get('/personalized', auth_1.authenticate, async (req, res) => {
    try {
        const userId = req.user.id;
        const preferences = await preferencesService_1.PreferencesService.getUserPreferences(userId);
        // Build query based on preferences
        const query = {
            createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
            $or: [
                { platform: { $in: preferences.platforms || [] } },
                { category: { $in: [...(preferences.worldCategories || []), ...(preferences.techCategories || [])] } },
                { country: { $in: preferences.countries || [] } }
            ]
        };
        const trends = await Trend_1.default.find(query)
            .sort({ trendingScore: -1 })
            .limit(100)
            .lean();
        // Re-rank based on user preference match
        const rankedTrends = trends.map(trend => ({
            ...trend,
            relevanceScore: preferencesService_1.PreferencesService.calculateRelevanceScore(trend, preferences)
        }))
            .sort((a, b) => b.relevanceScore - a.relevanceScore)
            .slice(0, 50);
        res.json({
            success: true,
            count: rankedTrends.length,
            trends: rankedTrends,
            preferences
        });
    }
    catch (error) {
        console.error('Personalized trends error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch personalized trends'
        });
    }
});
exports.default = router;
