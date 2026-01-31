import { FilterQuery, Model } from 'mongoose';
import Trend, { ITrend } from '../models/Trend';
import News, { INews } from '../models/News';
import User from '../models/User';
import SavedItem from '../models/SavedItem';

/**
 * Analytics aggregation pipelines for dashboard and reporting
 */

/**
 * Get trending topics aggregated by category
 */
export const getTrendingByCategory = async () => {
    return await Trend.aggregate([
        {
            $match: {
                isActive: true,
                trendingScore: { $gt: 0 }
            }
        },
        {
            $group: {
                _id: '$category',
                count: { $sum: 1 },
                avgScore: { $avg: '$trendingScore' },
                maxScore: { $max: '$trendingScore' },
                topTrends: {
                    $push: {
                        title: '$title',
                        score: '$trendingScore',
                        platform: '$platform'
                    }
                }
            }
        },
        {
            $project: {
                category: '$_id',
                count: 1,
                avgScore: { $round: ['$avgScore', 2] },
                maxScore: 1,
                topTrends: { $slice: ['$topTrends', 5] }
            }
        },
        { $sort: { count: -1 } }
    ]);
};

/**
 * Get trending topics aggregated by country
 */
export const getTrendingByCountry = async () => {
    return await Trend.aggregate([
        {
            $match: {
                isActive: true,
                trendingScore: { $gt: 0 }
            }
        },
        {
            $group: {
                _id: '$country',
                count: { $sum: 1 },
                avgScore: { $avg: '$trendingScore' },
                platforms: { $addToSet: '$platform' }
            }
        },
        {
            $project: {
                country: '$_id',
                count: 1,
                avgScore: { $round: ['$avgScore', 2] },
                platforms: 1,
                platformCount: { $size: '$platforms' }
            }
        },
        { $sort: { count: -1 } }
    ]);
};

/**
 * Get platform performance metrics
 */
export const getPlatformMetrics = async () => {
    return await Trend.aggregate([
        {
            $match: {
                createdAt: {
                    $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // Last 7 days
                }
            }
        },
        {
            $group: {
                _id: '$platform',
                totalTrends: { $sum: 1 },
                avgEngagement: {
                    $avg: {
                        $add: [
                            '$metrics.likes',
                            '$metrics.comments',
                            '$metrics.shares'
                        ]
                    }
                },
                avgViews: { $avg: '$metrics.views' },
                avgTrendingScore: { $avg: '$trendingScore' }
            }
        },
        {
            $project: {
                platform: '$_id',
                totalTrends: 1,
                avgEngagement: { $round: ['$avgEngagement', 0] },
                avgViews: { $round: ['$avgViews', 0] },
                avgTrendingScore: { $round: ['$avgTrendingScore', 2] }
            }
        },
        { $sort: { totalTrends: -1 } }
    ]);
};

/**
 * Get user engagement statistics
 */
export const getUserEngagementStats = async () => {
    const [totalUsers, activeUsers, newUsersLast7Days, newUsersLast30Days] = await Promise.all([
        User.countDocuments(),
        User.countDocuments({ emailVerified: true }),
        User.countDocuments({
            createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) }
        }),
        User.countDocuments({
            createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
        })
    ]);

    return {
        totalUsers,
        activeUsers,
        verificationRate: totalUsers > 0 ? ((activeUsers / totalUsers) * 100).toFixed(2) + '%' : '0%',
        newUsersLast7Days,
        newUsersLast30Days,
        growthRate7d: totalUsers > 0 ? ((newUsersLast7Days / totalUsers) * 100).toFixed(2) + '%' : '0%',
        growthRate30d: totalUsers > 0 ? ((newUsersLast30Days / totalUsers) * 100).toFixed(2) + '%' : '0%'
    };
};

/**
 * Get saved items statistics
 */
export const getSavedItemsStats = async () => {
    return await SavedItem.aggregate([
        {
            $group: {
                _id: '$itemType',
                count: { $sum: 1 },
                categories: { $addToSet: '$category' }
            }
        },
        {
            $project: {
                itemType: '$_id',
                count: 1,
                uniqueCategories: { $size: '$categories' }
            }
        }
    ]);
};

/**
 * Get top trending content (cross-platform)
 */
export const getTopTrendingContent = async (limit: number = 10) => {
    return await Trend.aggregate([
        {
            $match: {
                isActive: true,
                createdAt: {
                    $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // Last 24 hours
                }
            }
        },
        {
            $addFields: {
                engagementScore: {
                    $add: [
                        { $multiply: ['$metrics.likes', 1] },
                        { $multiply: ['$metrics.comments', 2] },
                        { $multiply: ['$metrics.shares', 3] }
                    ]
                }
            }
        },
        { $sort: { trendingScore: -1, engagementScore: -1 } },
        { $limit: limit },
        {
            $project: {
                title: 1,
                platform: 1,
                category: 1,
                country: 1,
                trendingScore: 1,
                metrics: 1,
                publishedAt: 1
            }
        }
    ]);
};

/**
 * Get news performance by source
 */
export const getNewsBySource = async () => {
    return await News.aggregate([
        {
            $match: {
                isActive: true,
                createdAt: {
                    $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
                }
            }
        },
        {
            $group: {
                _id: '$source',
                count: { $sum: 1 },
                avgTrendingScore: { $avg: '$trendingScore' },
                categories: { $addToSet: '$category' }
            }
        },
        {
            $project: {
                source: '$_id',
                count: 1,
                avgTrendingScore: { $round: ['$avgTrendingScore', 2] },
                categoryCoverage: { $size: '$categories' }
            }
        },
        { $sort: { count: -1 } },
        { $limit: 20 }
    ]);
};

/**
 * Get comprehensive dashboard stats
 */
export const getDashboardStats = async () => {
    const [
        trendsByCategory,
        trendsByCountry,
        platformMetrics,
        userEngagement,
        savedItemsStats,
        topTrending
    ] = await Promise.all([
        getTrendingByCategory(),
        getTrendingByCountry(),
        getPlatformMetrics(),
        getUserEngagementStats(),
        getSavedItemsStats(),
        getTopTrendingContent(10)
    ]);

    return {
        trendsByCategory,
        trendsByCountry,
        platformMetrics,
        userEngagement,
        savedItemsStats,
        topTrending,
        generatedAt: new Date()
    };
};
