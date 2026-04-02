"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTwitterPosts = exports.getTwitterTrends = void 0;
const scraperUtils_1 = require("./scraperUtils");
const axios_1 = __importDefault(require("axios"));
const TWITTER_BEARER_TOKEN = process.env.TWITTER_BEARER_TOKEN;
const getTwitterTrends = async (country) => {
    // Try Twitter API v2 if token is available
    if (TWITTER_BEARER_TOKEN) {
        try {
            const woeidMap = {
                'USA': '23424977',
                'India': '23424848',
                'UK': '23424975',
                'Japan': '23424856',
                'Canada': '23424775',
                'Germany': '23424829',
                'France': '23424819',
                'Brazil': '23424768'
            };
            const woeid = woeidMap[country || 'USA'] || '1'; // 1 = Worldwide
            const response = await axios_1.default.get(`https://api.twitter.com/1.1/trends/place.json?id=${woeid}`, {
                headers: {
                    'Authorization': `Bearer ${TWITTER_BEARER_TOKEN}`
                }
            });
            if (response.data && response.data[0] && response.data[0].trends) {
                return response.data[0].trends.slice(0, 20).map((trend) => ({
                    name: trend.name,
                    tweet_volume: trend.tweet_volume || 0,
                    url: trend.url || `https://twitter.com/search?q=${encodeURIComponent(trend.name)}`
                }));
            }
        }
        catch (error) {
            console.error('Twitter API error, falling back to scraping:', error);
        }
    }
    // Fallback to scraping
    return getTwitterTrendsByScraping();
};
exports.getTwitterTrends = getTwitterTrends;
const getTwitterTrendsByScraping = async () => {
    try {
        const $ = await (0, scraperUtils_1.fetchHtml)('https://trendogate.com/');
        if (!$)
            return [];
        const trends = [];
        const seen = new Set();
        $('.list-group-item').each((i, el) => {
            if (trends.length >= 10)
                return;
            const name = (0, scraperUtils_1.cleanText)($(el).find('a').text());
            const volumeText = (0, scraperUtils_1.cleanText)($(el).find('.badge').text());
            if (name && name.length > 1 && !seen.has(name)) {
                seen.add(name);
                trends.push({
                    name,
                    tweet_volume: parseInt(volumeText.replace(/,/g, '')) || 0,
                    url: $(el).find('a').attr('href') || `https://twitter.com/search?q=${encodeURIComponent(name)}`
                });
            }
        });
        return trends;
    }
    catch (error) {
        console.error('Error scraping Twitter trends:', error);
        return [];
    }
};
const getTwitterPosts = async (query) => {
    // Twitter scraping is hard without API, returning empty for now
    return [];
};
exports.getTwitterPosts = getTwitterPosts;
