"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getDashboardStats = exports.getNewsBySource = exports.getTopTrendingContent = exports.getSavedItemsStats = exports.getUserEngagementStats = exports.getPlatformMetrics = exports.getTrendingByCountry = exports.getTrendingByCategory = void 0;
const Trend_1 = __importDefault(require("../models/Trend"));
const News_1 = __importDefault(require("../models/News"));
const User_1 = __importDefault(require("../models/User"));
const SavedItem_1 = __importDefault(require("../models/SavedItem"));
/**
 * Analytics aggregation pipelines for dashboard and reporting
 */
/**
 * Get trending topics aggregated by category
 */
const getTrendingByCategory = async () => {
    return await Trend_1.default.aggregate([
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
exports.getTrendingByCategory = getTrendingByCategory;
/**
 * Get trending topics aggregated by country
 */
const getTrendingByCountry = async () => {
    return await Trend_1.default.aggregate([
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
exports.getTrendingByCountry = getTrendingByCountry;
/**
 * Get platform performance metrics
 */
const getPlatformMetrics = async () => {
    return await Trend_1.default.aggregate([
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
exports.getPlatformMetrics = getPlatformMetrics;
/**
 * Get user engagement statistics
 */
const getUserEngagementStats = async () => {
    const [totalUsers, activeUsers, newUsersLast7Days, newUsersLast30Days] = await Promise.all([
        User_1.default.countDocuments(),
        User_1.default.countDocuments({ emailVerified: true }),
        User_1.default.countDocuments({
            createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) }
        }),
        User_1.default.countDocuments({
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
exports.getUserEngagementStats = getUserEngagementStats;
/**
 * Get saved items statistics
 */
const getSavedItemsStats = async () => {
    return await SavedItem_1.default.aggregate([
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
exports.getSavedItemsStats = getSavedItemsStats;
/**
 * Get top trending content (cross-platform)
 */
const getTopTrendingContent = async (limit = 10) => {
    return await Trend_1.default.aggregate([
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
exports.getTopTrendingContent = getTopTrendingContent;
/**
 * Get news performance by source
 */
const getNewsBySource = async () => {
    return await News_1.default.aggregate([
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
exports.getNewsBySource = getNewsBySource;
/**
 * Get comprehensive dashboard stats
 */
const getDashboardStats = async () => {
    const [trendsByCategory, trendsByCountry, platformMetrics, userEngagement, savedItemsStats, topTrending] = await Promise.all([
        (0, exports.getTrendingByCategory)(),
        (0, exports.getTrendingByCountry)(),
        (0, exports.getPlatformMetrics)(),
        (0, exports.getUserEngagementStats)(),
        (0, exports.getSavedItemsStats)(),
        (0, exports.getTopTrendingContent)(10)
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
exports.getDashboardStats = getDashboardStats;
