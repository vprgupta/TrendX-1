"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ingestAllTrends = exports.initializeScheduler = void 0;
const node_cron_1 = __importDefault(require("node-cron"));
const Trend_1 = __importDefault(require("../models/Trend"));
const twitterService_1 = require("../services/twitterService");
const instagramService_1 = require("../services/instagramService");
const tiktokService_1 = require("../services/tiktokService");
const redditService_1 = require("../services/redditService");
const youtubeService_1 = require("../services/youtubeService");
const newsService_1 = require("../services/newsService");
const trendingAlgorithm_1 = require("../services/trendingAlgorithm");
let ioInstance;
const initializeScheduler = (io) => {
    if (io) {
        ioInstance = io;
    }
    console.log('📅 Initializing Real-Time Trend Scheduler...');
    // Quick updates for real-time feeling (every 15 minutes)
    node_cron_1.default.schedule('*/15 * * * *', async () => {
        console.log('⚡ Quick trend refresh...');
        await refreshTrendingTopics();
    });
    // Full deep scan (every 2 hours)
    node_cron_1.default.schedule('0 */2 * * *', async () => {
        console.log('🔄 Full trend ingestion...');
        await (0, exports.ingestAllTrends)();
    });
    // Initial run after 10 seconds
    setTimeout(() => (0, exports.ingestAllTrends)(), 10000);
};
exports.initializeScheduler = initializeScheduler;
const refreshTrendingTopics = async () => {
    // Only fetch the fastest APIs for real-time updates
    const [twitter, reddit] = await Promise.all([
        (0, twitterService_1.getTwitterTrends)().catch(() => []),
        (0, redditService_1.getRedditTrends)().catch(() => [])
    ]);
    await saveTrends(twitter, 'twitter');
    await saveTrends(reddit, 'reddit');
    // Emit to all connected clients
    if (ioInstance) {
        ioInstance.emit('trends:updated', {
            timestamp: new Date(),
            platforms: ['twitter', 'reddit']
        });
    }
};
const ingestAllTrends = async () => {
    try {
        console.log('📥 Ingesting trends from all sources...');
        // Platforms
        const [twitter, instagram, tiktok, reddit, youtube] = await Promise.all([
            (0, twitterService_1.getTwitterTrends)().catch(() => []),
            (0, instagramService_1.getInstagramTrends)().catch(() => []),
            (0, tiktokService_1.getTikTokTrends)().catch(() => []),
            (0, redditService_1.getRedditTrends)().catch(() => []),
            (0, youtubeService_1.getYouTubeTrends)().catch(() => [])
        ]);
        // World categories — must match NewsData.io supported categories
        const worldCategories = ['Science', 'Health', 'Sports', 'Business', 'Politics', 'Technology'];
        const worldNews = [];
        for (const cat of worldCategories) {
            try {
                const news = await (0, newsService_1.getWorldNews)(cat, 'us');
                worldNews.push(news);
                // Wait 1 second between requests to respect free tier rate limit
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
            catch (err) {
                worldNews.push([]);
            }
        }
        // Tech categories
        const techCategories = ['AI', 'Mobile', 'Web', 'Cybersecurity'];
        const techNews = [];
        for (const cat of techCategories) {
            try {
                // Assuming getTechNews also hits an API now, stagger it.
                const tNews = await (0, newsService_1.getTechNews)(cat);
                techNews.push(tNews);
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
            catch (err) {
                techNews.push([]);
            }
        }
        // Save everything
        await saveTrends(twitter, 'twitter');
        await saveTrends(instagram, 'instagram');
        await saveTrends(tiktok, 'tiktok');
        await saveTrends(reddit, 'reddit');
        await saveTrends(youtube, 'youtube');
        worldCategories.forEach((cat, idx) => {
            saveTrends(worldNews[idx], 'news', cat);
        });
        techCategories.forEach((cat, idx) => {
            saveTrends(techNews[idx], 'tech', cat);
        });
        // Notify all clients
        if (ioInstance) {
            ioInstance.emit('trends:fullUpdate', {
                timestamp: new Date(),
                message: 'All trends updated!'
            });
        }
        console.log('✅ Complete trend ingestion finished!');
    }
    catch (error) {
        console.error('❌ Error during trend ingestion:', error);
    }
};
exports.ingestAllTrends = ingestAllTrends;
const saveTrends = async (trends, platform, category = 'general') => {
    if (!trends.length)
        return;
    console.log(`💾 Saving ${trends.length} trends for ${platform}...`);
    for (const item of trends) {
        try {
            // Find previous version to calculate velocity
            const previous = await Trend_1.default.findOne({
                title: item.title || item.name || 'Untitled Trend',
                platform
            }).lean();
            const publishedAt = item.publishedAt || item.createdAt || new Date();
            const metrics = {
                views: item.views || item.tweet_volume || 0,
                likes: item.likes || item.score || 0,
                comments: item.comments || item.num_comments || 0,
                shares: item.shares || 0,
                publishedAt: new Date(publishedAt),
                platform
            };
            // Calculate all scores
            const previousMetrics = previous?.metrics ? {
                views: previous.metrics.views || 0,
                likes: previous.metrics.likes || 0,
                comments: previous.metrics.comments || 0,
                shares: previous.metrics.shares || 0,
                publishedAt: new Date(previous.publishedAt || previous.createdAt),
                platform
            } : undefined;
            const trendingScore = trendingAlgorithm_1.TrendingScoreCalculator.calculateTrendingScore(metrics, previousMetrics);
            const finalScore = trendingAlgorithm_1.TrendingScoreCalculator.applyPlatformWeight(trendingScore, platform);
            // Calculate individual scores
            const engagementScore = trendingAlgorithm_1.TrendingScoreCalculator['calculateEngagementScore'](metrics);
            const recencyScore = trendingAlgorithm_1.TrendingScoreCalculator['calculateRecencyScore'](metrics.publishedAt);
            const viralityScore = trendingAlgorithm_1.TrendingScoreCalculator['calculateViralityScore'](metrics);
            const velocityScore = trendingAlgorithm_1.TrendingScoreCalculator['calculateVelocityScore'](metrics, previousMetrics);
            const trendData = {
                title: item.title || item.name || 'Untitled Trend',
                content: item.content || item.description || item.selftext || '',
                platform,
                category,
                country: item.country || 'global',
                imageUrl: item.imageUrl || item.thumbnail || item.coverUrl,
                url: item.url || item.link,
                videoId: item.id || item.videoId,
                metrics: {
                    views: metrics.views,
                    likes: metrics.likes,
                    shares: metrics.shares,
                    comments: metrics.comments,
                    engagement: metrics.likes / (metrics.views || 1) * 100
                },
                author: item.author || item.source || item.channelTitle,
                publishedAt: metrics.publishedAt,
                trendingScore: finalScore,
                engagementScore,
                recencyScore,
                viralityScore,
                velocityScore
            };
            // Upsert (update if exists, insert if new) based on title and platform
            await Trend_1.default.findOneAndUpdate({ title: trendData.title, platform }, trendData, { upsert: true, new: true });
        }
        catch (err) {
            console.error(`Failed to save trend ${item.name || item.title}:`, err);
        }
    }
};
