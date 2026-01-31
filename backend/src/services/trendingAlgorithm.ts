interface TrendMetrics {
    views: number;
    likes: number;
    comments: number;
    shares: number;
    publishedAt: Date;
    platform: string;
}

export class TrendingScoreCalculator {
    /**
     * Master Trending Score Formula:
     * Score = (Engagement × 40%) + (Velocity × 30%) + (Recency × 20%) + (Virality × 10%)
     */
    static calculateTrendingScore(
        current: TrendMetrics,
        previous?: TrendMetrics
    ): number {
        const engagement = this.calculateEngagementScore(current);
        const velocity = this.calculateVelocityScore(current, previous);
        const recency = this.calculateRecencyScore(current.publishedAt);
        const virality = this.calculateViralityScore(current);

        const trendingScore =
            engagement * 0.4 +
            velocity * 0.3 +
            recency * 0.2 +
            virality * 0.1;

        return Math.round(trendingScore * 100) / 100;
    }

    /**
     * Engagement Score (0-100)
     * Measures total interaction relative to reach
     */
    private static calculateEngagementScore(metrics: TrendMetrics): number {
        const { views, likes, comments, shares } = metrics;

        if (views === 0) return 0;

        // Weighted engagement: comments > shares > likes
        const totalEngagement = likes + (comments * 2) + (shares * 3);
        const engagementRate = (totalEngagement / views) * 100;

        // Normalize to 0-100 scale (typical viral content has 5-15% engagement)
        return Math.min(100, engagementRate * 6.67);
    }

    /**
     * Velocity Score (0-100)
     * Measures how fast content is growing (acceleration)
     */
    private static calculateVelocityScore(
        current: TrendMetrics,
        previous?: TrendMetrics
    ): number {
        if (!previous) return 50; // Default to middle if no history

        const currentTotal = current.views + current.likes + current.comments;
        const previousTotal = previous.views + previous.likes + previous.comments;

        if (previousTotal === 0) return 100; // New viral content

        const growthRate = ((currentTotal - previousTotal) / previousTotal) * 100;

        // Normalize: 50% growth/hour = 100 score
        return Math.min(100, Math.max(0, growthRate * 2));
    }

    /**
     * Recency Score (0-100)
     * Newer content gets higher scores (exponential decay)
     */
    private static calculateRecencyScore(publishedAt: Date): number {
        const now = new Date();
        const ageInHours = (now.getTime() - publishedAt.getTime()) / (1000 * 60 * 60);

        // Exponential decay: half-life of 12 hours
        const score = 100 * Math.exp(-0.0578 * ageInHours);

        return Math.max(0, Math.min(100, score));
    }

    /**
     * Virality Score (0-100)
     * Detects unusually high engagement for the platform
     */
    private static calculateViralityScore(metrics: TrendMetrics): number {
        const { views, platform } = metrics;

        // Platform-specific viral thresholds
        const viralThresholds: Record<string, number> = {
            'twitter': 100000,      // 100K views
            'instagram': 500000,    // 500K views
            'tiktok': 1000000,      // 1M views
            'youtube': 1000000,     // 1M views
            'reddit': 50000,        // 50K upvotes
            'news': 10000,          // 10K views
            'facebook': 200000,
            'linkedin': 50000,
            'snapchat': 300000
        };

        const threshold = viralThresholds[platform.toLowerCase()] || 100000;
        const viralityRatio = views / threshold;

        // Logarithmic scale for virality
        return Math.min(100, Math.log10(viralityRatio + 1) * 50);
    }

    /**
     * Platform Weight Adjustment
     * Different platforms have different signals strength
     */
    static applyPlatformWeight(score: number, platform: string): number {
        const platformWeights: Record<string, number> = {
            'twitter': 1.2,      // Twitter trends are fast-moving
            'tiktok': 1.15,      // TikTok has strong viral signals
            'youtube': 1.1,      // YouTube has quality content
            'instagram': 1.0,    // Instagram baseline
            'reddit': 1.05,      // Reddit has engaged communities
            'news': 0.9,         // News is slower but important
            'facebook': 0.95,
            'linkedin': 0.85,
            'snapchat': 0.9
        };

        const weight = platformWeights[platform.toLowerCase()] || 1.0;
        return score * weight;
    }
}
