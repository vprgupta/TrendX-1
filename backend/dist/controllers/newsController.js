"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getNewsByCategory = void 0;
const newsService_1 = require("../services/newsService");
const getNewsByCategory = async (req, res) => {
    const { category = 'world', country = 'US' } = req.query;
    try {
        const newsItems = await (0, newsService_1.getNews)(category, country);
        // Return plain array to match frontend expectations
        res.json(newsItems);
    }
    catch (error) {
        res.status(500).json({
            success: false,
            error: 'Failed to fetch news'
        });
    }
};
exports.getNewsByCategory = getNewsByCategory;
