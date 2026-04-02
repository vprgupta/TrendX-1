"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTrendChartData = exports.getTopTrends = exports.getSentimentAnalysis = exports.getAnalyticsOverview = void 0;
const Trend_1 = __importDefault(require("../models/Trend"));
const getAnalyticsOverview = async (req, res) => {
    try {
        const totalTrends = await Trend_1.default.countDocuments();
        const activeTrends = await Trend_1.default.countDocuments({ status: 'active' });
        // Calculate total engagement (sum of views, likes, comments, shares)
        const engagementAgg = await Trend_1.default.aggregate([
            {
                $group: {
                    _id: null,
                    totalViews: { $sum: '$metrics.views' },
                    totalLikes: { $sum: '$metrics.likes' },
                    totalComments: { $sum: '$metrics.comments' },
                    totalShares: { $sum: '$metrics.shares' }
                }
            }
        ]);
        const metrics = engagementAgg[0] || { totalViews: 0, totalLikes: 0, totalComments: 0, totalShares: 0 };
        res.json({
            totalTrends,
            activeTrends,
            metrics
        });
    }
    catch (error) {
        console.error('Error fetching analytics overview:', error);
        res.status(500).json({ error: 'Failed to fetch analytics overview' });
    }
};
exports.getAnalyticsOverview = getAnalyticsOverview;
const getSentimentAnalysis = async (req, res) => {
    try {
        const sentimentAgg = await Trend_1.default.aggregate([
            {
                $group: {
                    _id: '$sentiment',
                    count: { $sum: 1 }
                }
            }
        ]);
        const sentiment = {
            positive: 0,
            negative: 0,
            neutral: 0
        };
        sentimentAgg.forEach((item) => {
            if (item._id === 'positive')
                sentiment.positive = item.count;
            if (item._id === 'negative')
                sentiment.negative = item.count;
            if (item._id === 'neutral')
                sentiment.neutral = item.count;
        });
        res.json(sentiment);
    }
    catch (error) {
        console.error('Error fetching sentiment analysis:', error);
        res.status(500).json({ error: 'Failed to fetch sentiment analysis' });
    }
};
exports.getSentimentAnalysis = getSentimentAnalysis;
const getTopTrends = async (req, res) => {
    try {
        const limit = parseInt(req.query.limit) || 5;
        const sortBy = req.query.sortBy === 'growth' ? 'metrics.engagement' : 'metrics.views'; // Simplified for now
        const trends = await Trend_1.default.find()
            .sort({ [sortBy]: -1 })
            .limit(limit);
        res.json(trends);
    }
    catch (error) {
        console.error('Error fetching top trends:', error);
        res.status(500).json({ error: 'Failed to fetch top trends' });
    }
};
exports.getTopTrends = getTopTrends;
const getTrendChartData = async (req, res) => {
    try {
        // Group trends by creation date (last 30 days)
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const chartData = await Trend_1.default.aggregate([
            {
                $match: {
                    createdAt: { $gte: thirtyDaysAgo }
                }
            },
            {
                $group: {
                    _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
                    count: { $sum: 1 },
                    views: { $sum: "$metrics.views" }
                }
            },
            { $sort: { _id: 1 } }
        ]);
        res.json(chartData);
    }
    catch (error) {
        console.error('Error fetching chart data:', error);
        res.status(500).json({ error: 'Failed to fetch chart data' });
    }
};
exports.getTrendChartData = getTrendChartData;
