import cron from 'node-cron';
import type { Server } from 'socket.io';
import Trend from '../models/Trend';
import { getTwitterTrends } from '../services/twitterService';
import { getInstagramTrends } from '../services/instagramService';
import { getTikTokTrends } from '../services/tiktokService';
import { getRedditTrends } from '../services/redditService';
import { getYouTubeTrends } from '../services/youtubeService';
import { getWorldNews, getTechNews } from '../services/newsService';
import { TrendingScoreCalculator } from '../services/trendingAlgorithm';

let ioInstance: Server;

export const initializeScheduler = (io?: Server) => {
    if (io) {
        ioInstance = io;
    }
    console.log('📅 Initializing Real-Time Trend Scheduler...');

    // Quick updates for real-time feeling (every 15 minutes)
    cron.schedule('*/15 * * * *', async () => {
        console.log('⚡ Quick trend refresh...');
        await refreshTrendingTopics();
    });

    // Full deep scan (every 2 hours)
    cron.schedule('0 */2 * * *', async () => {
        console.log('🔄 Full trend ingestion...');
        await ingestAllTrends();
    });

    // Initial run after 10 seconds
    setTimeout(() => ingestAllTrends(), 10000);
};

const refreshTrendingTopics = async () => {
    // Only fetch the fastest APIs for real-time updates
    const [twitter, reddit] = await Promise.all([
        getTwitterTrends().catch(() => []),
        getRedditTrends().catch(() => [])
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

export const ingestAllTrends = async () => {
    try {
        console.log('📥 Ingesting trends from all sources...');

        // Platforms
        const [twitter, instagram, tiktok, reddit, youtube] = await Promise.all([
            getTwitterTrends().catch(() => []),
            getInstagramTrends().catch(() => []),
            getTikTokTrends().catch(() => []),
            getRedditTrends().catch(() => []),
            getYouTubeTrends().catch(() => [])
        ]);

        // World categories
        const worldCategories = ['Science', 'Agriculture', 'Space', 'Health', 'Sports', 'Environment', 'Politics', 'Entertainment'];
        const worldNews = await Promise.all(
            worldCategories.map(cat => getWorldNews(cat, 'us').catch(() => []))
        );

        // Tech categories
        const techCategories = ['AI', 'Mobile', 'Web', 'Blockchain', 'IoT', 'Robotics', 'Cloud', 'Cybersecurity'];
        const techNews = await Promise.all(
            techCategories.map(cat => getTechNews(cat).catch(() => []))
        );

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
    } catch (error) {
        console.error('❌ Error during trend ingestion:', error);
    }
};

const saveTrends = async (trends: any[], platform: string, category: string = 'general') => {
    if (!trends.length) return;
    console.log(`💾 Saving ${trends.length} trends for ${platform}...`);

    for (const item of trends) {
        try {
            // Find previous version to calculate velocity
            const previous = await Trend.findOne({
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

            const trendingScore = TrendingScoreCalculator.calculateTrendingScore(
                metrics,
                previousMetrics
            );

            const finalScore = TrendingScoreCalculator.applyPlatformWeight(
                trendingScore,
                platform
            );

            // Calculate individual scores
            const engagementScore = TrendingScoreCalculator['calculateEngagementScore'](metrics);
            const recencyScore = TrendingScoreCalculator['calculateRecencyScore'](metrics.publishedAt);
            const viralityScore = TrendingScoreCalculator['calculateViralityScore'](metrics);
            const velocityScore = TrendingScoreCalculator['calculateVelocityScore'](metrics, previousMetrics);

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
            await Trend.findOneAndUpdate(
                { title: trendData.title, platform },
                trendData,
                { upsert: true, new: true }
            );
        } catch (err) {
            console.error(`Failed to save trend ${item.name || item.title}:`, err);
        }
    }
};
