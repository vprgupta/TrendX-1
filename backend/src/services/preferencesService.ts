import User from '../models/User';

export class PreferencesService {
    /**
     * Get user preferences from database
     */
    static async getUserPreferences(userId: string): Promise<any> {
        const user = await User.findById(userId).lean();

        if (!user || !user.preferences) {
            // Return default preferences if not set
            return {
                platforms: ['Instagram', 'Facebook', 'Twitter', 'TikTok', 'YouTube'],
                countries: ['USA', 'India'],
                worldCategories: ['Science', 'Space', 'Art'],
                techCategories: ['AI', 'Mobile']
            };
        }

        return user.preferences;
    }

    /**
     * Calculate relevance score based on user preferences
     */
    static calculateRelevanceScore(trend: any, preferences: any): number {
        let score = trend.trendingScore || 0;

        // Boost if platform matches preference
        if (preferences.platforms && preferences.platforms.includes(trend.platform)) {
            score += 20;
        }

        // Boost if category matches preference
        const allPreferredCategories = [
            ...(preferences.worldCategories || []),
            ...(preferences.techCategories || [])
        ];
        if (allPreferredCategories.includes(trend.category)) {
            score += 15;
        }

        // Boost if country matches preference
        if (preferences.countries && preferences.countries.includes(trend.country)) {
            score += 10;
        }

        return score;
    }
}
