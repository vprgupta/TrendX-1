"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PreferencesService = void 0;
const User_1 = __importDefault(require("../models/User"));
class PreferencesService {
    /**
     * Get user preferences from database
     */
    static async getUserPreferences(userId) {
        const user = await User_1.default.findById(userId).lean();
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
    static calculateRelevanceScore(trend, preferences) {
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
exports.PreferencesService = PreferencesService;
