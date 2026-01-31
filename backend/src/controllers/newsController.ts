import { Request, Response } from 'express';
import { getNews } from '../services/newsService';

export const getNewsByCategory = async (req: Request, res: Response) => {
    const { category = 'world', country = 'US' } = req.query;

    try {
        const newsItems = await getNews(category as string, country as string);
        // Return plain array to match frontend expectations
        res.json(newsItems);
    } catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch news'
        });
    }
};
