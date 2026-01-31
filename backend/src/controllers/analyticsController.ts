import { Request, Response } from 'express';
import Trend from '../models/Trend';

export const getAnalyticsOverview = async (req: Request, res: Response) => {
    try {
        const totalTrends = await Trend.countDocuments();
        const activeTrends = await Trend.countDocuments({ status: 'active' });

        // Calculate total engagement (sum of views, likes, comments, shares)
        const engagementAgg = await Trend.aggregate([
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
    } catch (error) {
        console.error('Error fetching analytics overview:', error);
        res.status(500).json({ error: 'Failed to fetch analytics overview' });
    }
};

export const getSentimentAnalysis = async (req: Request, res: Response) => {
    try {
        const sentimentAgg = await Trend.aggregate([
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

        sentimentAgg.forEach((item: any) => {
            if (item._id === 'positive') sentiment.positive = item.count;
            if (item._id === 'negative') sentiment.negative = item.count;
            if (item._id === 'neutral') sentiment.neutral = item.count;
        });

        res.json(sentiment);
    } catch (error) {
        console.error('Error fetching sentiment analysis:', error);
        res.status(500).json({ error: 'Failed to fetch sentiment analysis' });
    }
};

export const getTopTrends = async (req: Request, res: Response) => {
    try {
        const limit = parseInt(req.query.limit as string) || 5;
        const sortBy = req.query.sortBy === 'growth' ? 'metrics.engagement' : 'metrics.views'; // Simplified for now

        const trends = await Trend.find()
            .sort({ [sortBy]: -1 })
            .limit(limit);

        res.json(trends);
    } catch (error) {
        console.error('Error fetching top trends:', error);
        res.status(500).json({ error: 'Failed to fetch top trends' });
    }
};

export const getTrendChartData = async (req: Request, res: Response) => {
    try {
        // Group trends by creation date (last 30 days)
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const chartData = await Trend.aggregate([
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
    } catch (error) {
        console.error('Error fetching chart data:', error);
        res.status(500).json({ error: 'Failed to fetch chart data' });
    }
};
