"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTrending = void 0;
const trendingNewsService_1 = require("../services/trendingNewsService");
const getTrending = async (req, res) => {
    const limit = parseInt(req.query.limit) || 20;
    // Accept country code from query param, default to US
    const country = (req.query.country || 'US').toUpperCase();
    try {
        const stories = await (0, trendingNewsService_1.getTrendingNews)(limit, country);
        res.json(stories);
    }
    catch (error) {
        console.error('Error fetching trending news:', error);
        res.status(500).json({ success: false, error: 'Failed to fetch trending news' });
    }
};
exports.getTrending = getTrending;
