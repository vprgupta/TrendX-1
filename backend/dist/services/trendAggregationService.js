"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TrendAggregator = void 0;
const Trend_1 = __importDefault(require("../models/Trend"));
const trendingAlgorithm_1 = require("./trendingAlgorithm");
class TrendAggregator {
    /**
     * Detect and merge trends that are about the same topic
     * across different platforms
     */
    static async aggregateCrossPlatformTrends() {
        const allTrends = await Trend_1.default.find({
            createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } // Last 24 hours
        }).lean();
        const clusteredTrends = this.clusterSimilarTrends(allTrends);
        const aggregated = clusteredTrends.map(cluster => this.mergeTrendCluster(cluster));
        return aggregated
            .sort((a, b) => b.globalScore - a.globalScore)
            .slice(0, 50); // Top 50 global trends
    }
    /**
     * Cluster similar trends using text similarity
     */
    static clusterSimilarTrends(trends) {
        const clusters = [];
        const processed = new Set();
        for (const trend of trends) {
            if (processed.has(trend._id.toString()))
                continue;
            const cluster = [trend];
            processed.add(trend._id.toString());
            // Find similar trends
            for (const other of trends) {
                if (processed.has(other._id.toString()))
                    continue;
                if (this.areSimilarTopics(trend.title, other.title)) {
                    cluster.push(other);
                    processed.add(other._id.toString());
                }
            }
            if (cluster.length > 0) {
                clusters.push(cluster);
            }
        }
        return clusters;
    }
    /**
     * Check if two titles are about the same topic
     */
    static areSimilarTopics(title1, title2) {
        // Remove common words and normalize
        const normalize = (text) => text.toLowerCase()
            .replace(/[^a-z0-9\s]/g, '')
            .split(/\s+/)
            .filter(word => word.length > 3);
        const words1 = new Set(normalize(title1));
        const words2 = new Set(normalize(title2));
        // Calculate Jaccard similarity
        const intersection = new Set([...words1].filter(x => words2.has(x)));
        const union = new Set([...words1, ...words2]);
        const similarity = intersection.size / union.size;
        // If 40% similarity, consider them the same topic
        return similarity >= 0.4;
    }
    /**
     * Merge a cluster of similar trends into one global trend
     */
    static mergeTrendCluster(cluster) {
        // Use the trend with the highest score as the primary
        const primary = cluster.reduce((max, trend) => (trend.trendingScore || 0) > (max.trendingScore || 0) ? trend : max);
        // Aggregate metrics from all platforms
        const totalMetrics = cluster.reduce((acc, trend) => ({
            views: acc.views + (trend.metrics?.views || 0),
            likes: acc.likes + (trend.metrics?.likes || 0),
            comments: acc.comments + (trend.metrics?.comments || 0),
            shares: acc.shares + (trend.metrics?.shares || 0)
        }), { views: 0, likes: 0, comments: 0, shares: 0 });
        // Calculate global trending score
        const platformCount = new Set(cluster.map(t => t.platform)).size;
        const avgTrendingScore = cluster.reduce((sum, t) => sum + (t.trendingScore || 0), 0) / cluster.length;
        // Boost score based on cross-platform presence
        const crossPlatformBonus = Math.log10(platformCount + 1) * 15;
        const globalScore = avgTrendingScore + crossPlatformBonus;
        return {
            ...primary,
            platforms: cluster.map(t => t.platform),
            platformCount,
            globalScore,
            aggregatedMetrics: totalMetrics,
            sources: cluster.map(t => ({
                platform: t.platform,
                url: t.url,
                score: t.trendingScore
            })),
            trendingType: this.classifyTrendType({ globalScore, platformCount, aggregatedMetrics: totalMetrics }),
            momentum: this.calculateMomentum({
                publishedAt: primary.publishedAt || primary.createdAt,
                globalScore
            })
        };
    }
    /**
     * Get trending topics by category
     */
    static async getTrendingByCategory(category) {
        const trends = await Trend_1.default.find({
            category: category,
            createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) }
        })
            .sort({ trendingScore: -1 })
            .limit(20)
            .lean();
        return trends;
    }
    /**
     * Get global trending topics (all categories)
     */
    static async getGlobalTrending() {
        const aggregated = await this.aggregateCrossPlatformTrends();
        return aggregated;
    }
    /**
     * Classify what type of trend this is
     */
    static classifyTrendType(trend) {
        const { globalScore, platformCount, aggregatedMetrics } = trend;
        if (platformCount >= 4 && globalScore >= 80)
            return 'viral';
        if (aggregatedMetrics.views >= 5000000)
            return 'massive';
        if (globalScore >= 70)
            return 'hot';
        if (platformCount >= 3)
            return 'rising';
        return 'trending';
    }
    /**
     * Calculate momentum (how fast it's growing)
     */
    static calculateMomentum(trend) {
        const recency = trendingAlgorithm_1.TrendingScoreCalculator['calculateRecencyScore'](new Date(trend.publishedAt || trend.createdAt));
        if (recency >= 90 && trend.globalScore >= 75)
            return 'exploding';
        if (recency >= 70 && trend.globalScore >= 60)
            return 'surging';
        if (recency >= 50)
            return 'growing';
        return 'stable';
    }
}
exports.TrendAggregator = TrendAggregator;
