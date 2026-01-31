import { Request, Response } from 'express';
import User from '../models/User';
import UserInteraction from '../models/UserInteraction';
import UserSession from '../models/UserSession';
import Trend from '../models/Trend';

export const getDashboardStats = async (req: Request, res: Response) => {
  try {
    const [
      totalUsers,
      totalTrends,
      totalSessions,
      activeUsers,
      todayRegistrations,
      totalInteractions
    ] = await Promise.all([
      User.countDocuments(),
      Trend.countDocuments(),
      UserSession.countDocuments(),
      UserSession.countDocuments({ isActive: true }),
      User.countDocuments({ 
        createdAt: { $gte: new Date(new Date().setHours(0, 0, 0, 0)) }
      }),
      UserInteraction.countDocuments()
    ]);

    // Calculate average session duration
    const avgSessionData = await UserSession.aggregate([
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
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch dashboard stats' });
  }
};

export const getUsersWithActivity = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = (page - 1) * limit;

    const users = await User.aggregate([
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

    const total = await User.countDocuments();

    res.json({
      users,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch users with activity' });
  }
};

export const getUserActivityDetails = async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const days = parseInt(req.query.days as string) || 7;
    
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const [user, sessions, interactions] = await Promise.all([
      User.findById(userId).select('-password'),
      UserSession.find({ 
        userId, 
        createdAt: { $gte: startDate } 
      }).sort({ createdAt: -1 }),
      UserInteraction.find({ 
        userId, 
        createdAt: { $gte: startDate } 
      }).populate('trendId', 'title platform').sort({ createdAt: -1 })
    ]);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Calculate daily activity
    const dailyActivity = await UserSession.aggregate([
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
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch user activity details' });
  }
};

export const getActiveUsers = async (req: Request, res: Response) => {
  try {
    const activeUsers = await UserSession.aggregate([
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
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch active users' });
  }
};

export const getAnalytics = async (req: Request, res: Response) => {
  try {
    const days = parseInt(req.query.days as string) || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // User registration trends
    const registrationTrends = await User.aggregate([
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
    const platformUsage = await UserSession.aggregate([
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
    const mostActiveUsers = await UserSession.aggregate([
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
    const interactionTypes = await UserInteraction.aggregate([
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
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch analytics' });
  }
};