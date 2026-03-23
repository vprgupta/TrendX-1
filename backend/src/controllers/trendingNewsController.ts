import { Request, Response } from 'express';
import { getTrendingNews } from '../services/trendingNewsService';

export const getTrending = async (req: Request, res: Response) => {
    const limit = parseInt(req.query.limit as string) || 20;
    // Accept country code from query param, default to US
    const country = (req.query.country as string || 'US').toUpperCase();

    try {
        const stories = await getTrendingNews(limit, country);
        res.json(stories);
    } catch (error) {
        console.error('Error fetching trending news:', error);
        res.status(500).json({ success: false, error: 'Failed to fetch trending news' });
    }
};
