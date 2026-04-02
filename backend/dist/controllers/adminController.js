"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAnalytics = exports.getActiveUsers = exports.getUserActivityDetails = exports.getUsersWithActivity = exports.getDashboardStats = void 0;
const User_1 = __importDefault(require("../models/User"));
const UserInteraction_1 = __importDefault(require("../models/UserInteraction"));
const UserSession_1 = __importDefault(require("../models/UserSession"));
const Trend_1 = __importDefault(require("../models/Trend"));
const getDashboardStats = async (req, res) => {
    try {
        const [totalUsers, totalTrends, totalSessions, activeUsers, todayRegistrations, totalInteractions] = await Promise.all([
            User_1.default.countDocuments(),
            Trend_1.default.countDocuments(),
            UserSession_1.default.countDocuments(),
            UserSession_1.default.countDocuments({ isActive: true }),
            User_1.default.countDocuments({
                createdAt: { $gte: new Date(new Date().setHours(0, 0, 0, 0)) }
            }),
            UserInteraction_1.default.countDocuments()
        ]);
        // Calculate average session duration
        const avgSessionData = await UserSession_1.default.aggregate([
            { $match: { duration: { $exists: true, $gt: 0 } } },
            { $group: { _id: null, avgDuration: { $avg: '$duration' } } }
        ]);
        const avgSessionDuration = avgSessionData[0]?.avgDuration || 0;
        res.json({
            totalUsers,
            totalTrends,
            totalSessions,
            activeUsers,
            todayRegistrations,
            totalInteractions,
            avgSessionDuration: Math.round(avgSessionDuration)
        });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch dashboard stats' });
    }
};
exports.getDashboardStats = getDashboardStats;
const getUsersWithActivity = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 20;
        const skip = (page - 1) * limit;
        const users = await User_1.default.aggregate([
            {
                $lookup: {
                    from: 'usersessions',
                    localField: '_id',
                    foreignField: 'userId',
                    as: 'sessions'
                }
            },
            {
                $lookup: {
                    from: 'userinteractions',
                    localField: '_id',
                    foreignField: 'userId',
                    as: 'interactions'
                }
            },
            {
                $addFields: {
                    totalSessions: { $size: '$sessions' },
                    totalInteractions: { $size: '$interactions' },
                    totalTimeSpent: {
                        $sum: {
                            $map: {
                                input: '$sessions',
                                as: 'session',
                                in: { $ifNull: ['$$session.duration', 0] }
                            }
                        }
                    },
                    lastActive: {
                        $max: {
                            $map: {
                                input: '$sessions',
                                as: 'session',
                                in: '$$session.updatedAt'
                            }
                        }
                    },
                    isCurrentlyActive: {
                        $gt: [
                            {
                                $size: {
                                    $filter: {
                                        input: '$sessions',
                                        as: 'session',
                                        cond: { $eq: ['$$session.isActive', true] }
                                    }
                                }
                            },
                            0
                        ]
                    }
                }
            },
            {
                $project: {
                    password: 0,
                    sessions: 0,
                    interactions: 0
                }
            },
            { $sort: { createdAt: -1 } },
            { $skip: skip },
            { $limit: limit }
        ]);
        const total = await User_1.default.countDocuments();
        res.json({
            users,
            pagination: {
                page,
                limit,
                total,
                pages: Math.ceil(total / limit)
            }
        });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch users with activity' });
    }
};
exports.getUsersWithActivity = getUsersWithActivity;
const getUserActivityDetails = async (req, res) => {
    try {
        const { userId } = req.params;
        const days = parseInt(req.query.days) || 7;
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);
        const [user, sessions, interactions] = await Promise.all([
            User_1.default.findById(userId).select('-password'),
            UserSession_1.default.find({
                userId,
                createdAt: { $gte: startDate }
            }).sort({ createdAt: -1 }),
            UserInteraction_1.default.find({
                userId,
                createdAt: { $gte: startDate }
            }).populate('trendId', 'title platform').sort({ createdAt: -1 })
        ]);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        // Calculate daily activity
        const dailyActivity = await UserSession_1.default.aggregate([
            {
                $match: {
                    userId: user._id,
                    createdAt: { $gte: startDate }
                }
            },
            {
                $group: {
                    _id: {
                        $dateToString: { format: '%Y-%m-%d', date: '$createdAt' }
                    },
                    sessions: { $sum: 1 },
                    totalDuration: { $sum: { $ifNull: ['$duration', 0] } },
                    totalActivities: {
                        $sum: {
                            $add: [
                                '$activities.screenViews',
                                '$activities.trendsViewed',
                                '$activities.searchQueries',
                                '$activities.bookmarks',
                                '$activities.shares'
                            ]
                        }
                    }
                }
            },
            { $sort: { _id: 1 } }
        ]);
        res.json({
            user,
            sessions,
            interactions,
            dailyActivity,
            summary: {
                totalSessions: sessions.length,
                totalTimeSpent: sessions.reduce((sum, s) => sum + (s.duration || 0), 0),
                totalInteractions: interactions.length,
                avgSessionDuration: sessions.length > 0
                    ? Math.round(sessions.reduce((sum, s) => sum + (s.duration || 0), 0) / sessions.length)
                    : 0
            }
        });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch user activity details' });
    }
};
exports.getUserActivityDetails = getUserActivityDetails;
const getActiveUsers = async (req, res) => {
    try {
        const activeUsers = await UserSession_1.default.aggregate([
            { $match: { isActive: true } },
            {
                $lookup: {
                    from: 'users',
                    localField: 'userId',
                    foreignField: '_id',
                    as: 'user'
                }
            },
            { $unwind: '$user' },
            {
                $project: {
                    sessionId: 1,
                    startTime: 1,
                    platform: 1,
                    deviceInfo: 1,
                    activities: 1,
                    'user.name': 1,
                    'user.email': 1,
                    duration: {
                        $divide: [
                            { $subtract: [new Date(), '$startTime'] },
                            1000
                        ]
                    }
                }
            },
            { $sort: { startTime: -1 } }
        ]);
        res.json({ activeUsers, count: activeUsers.length });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch active users' });
    }
};
exports.getActiveUsers = getActiveUsers;
const getAnalytics = async (req, res) => {
    try {
        const days = parseInt(req.query.days) || 30;
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);
        // User registration trends
        const registrationTrends = await User_1.default.aggregate([
            {
                $match: { createdAt: { $gte: startDate } }
            },
            {
                $group: {
                    _id: {
                        $dateToString: { format: '%Y-%m-%d', date: '$createdAt' }
                    },
                    count: { $sum: 1 }
                }
            },
            { $sort: { _id: 1 } }
        ]);
        // Platform usage
        const platformUsage = await UserSession_1.default.aggregate([
            {
                $match: { createdAt: { $gte: startDate } }
            },
            {
                $group: {
                    _id: '$platform',
                    sessions: { $sum: 1 },
                    totalDuration: { $sum: { $ifNull: ['$duration', 0] } }
                }
            }
        ]);
        // Most active users
        const mostActiveUsers = await UserSession_1.default.aggregate([
            {
                $match: { createdAt: { $gte: startDate } }
            },
            {
                $group: {
                    _id: '$userId',
                    sessions: { $sum: 1 },
                    totalDuration: { $sum: { $ifNull: ['$duration', 0] } }
                }
            },
            {
                $lookup: {
                    from: 'users',
                    localField: '_id',
                    foreignField: '_id',
                    as: 'user'
                }
            },
            { $unwind: '$user' },
            {
                $project: {
                    sessions: 1,
                    totalDuration: 1,
                    'user.name': 1,
                    'user.email': 1
                }
            },
            { $sort: { totalDuration: -1 } },
            { $limit: 10 }
        ]);
        // Interaction types
        const interactionTypes = await UserInteraction_1.default.aggregate([
            {
                $match: { createdAt: { $gte: startDate } }
            },
            {
                $group: {
                    _id: '$type',
                    count: { $sum: 1 }
                }
            }
        ]);
        res.json({
            registrationTrends,
            platformUsage,
            mostActiveUsers,
            interactionTypes
        });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch analytics' });
    }
};
exports.getAnalytics = getAnalytics;
