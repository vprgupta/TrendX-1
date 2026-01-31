import { Request, Response } from 'express';
import Trend from '../models/Trend';

export const getIntegrationStatus = async (req: Request, res: Response) => {
    try {
        const platforms = ['twitter', 'youtube', 'reddit', 'tiktok', 'instagram'];
        const status: any = {};

        for (const platform of platforms) {
            const count = await Trend.countDocuments({ platform });
            const lastTrend = await Trend.findOne({ platform }).sort({ createdAt: -1 });

            status[platform] = {
                connected: true, // Assuming connected if we have the service
                trendsCollected: count,
                lastUpdated: lastTrend ? lastTrend.createdAt : null,
                status: count > 0 ? 'active' : 'inactive'
            };
        }

        // News API is a placeholder for now
        status['news'] = {
            connected: false,
            trendsCollected: 0,
            lastUpdated: null,
            status: 'inactive'
        };

        res.json(status);
    } catch (error) {
        console.error('Error fetching integration status:', error);
        res.status(500).json({ error: 'Failed to fetch integration status' });
    }
};
