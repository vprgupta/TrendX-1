"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSubredditsForTopic = exports.getSubredditsForCountry = exports.getRedditTrends = exports.getRedditHotPosts = void 0;
// Country → relevant news subreddits
const COUNTRY_SUBREDDITS = {
    'IN': ['india', 'indianews', 'worldnews'],
    'US': ['news', 'worldnews', 'politics'],
    'GB': ['unitedkingdom', 'worldnews'],
    'JP': ['japan', 'worldnews'],
    'DE': ['de', 'worldnews'],
    'FR': ['france', 'worldnews'],
    'BR': ['brasil', 'worldnews'],
    'CA': ['canada', 'worldnews'],
    'AU': ['australia', 'worldnews'],
};
// Topic → subreddits
const TOPIC_SUBREDDITS = {
    'technology': ['technology', 'tech', 'programming'],
    'science': ['science', 'futurology'],
    'politics': ['politics', 'worldnews'],
    'world': ['worldnews', 'geopolitics', 'internationalnews'],
    'business': ['business', 'economy'],
    'health': ['health', 'medicine'],
};
/**
 * Fetches hot posts from Reddit using the free public JSON API.
 * No API key required for public subreddit read access.
 */
const getRedditHotPosts = async (subreddits, limit = 25) => {
    const allPosts = [];
    for (const subreddit of subreddits.slice(0, 3)) {
        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000);
            const response = await fetch(`https://www.reddit.com/r/${subreddit}/hot.json?limit=${limit}`, {
                signal: controller.signal,
                headers: {
                    'User-Agent': 'TrendX/1.0 (news aggregator)',
                }
            });
            clearTimeout(timeoutId);
            if (!response.ok)
                continue;
            const data = await response.json();
            const posts = (data.data?.children ?? [])
                .filter((child) => {
                const p = child.data;
                return !p.is_self &&
                    p.url &&
                    !p.url.includes('reddit.com') &&
                    p.score > 100;
            })
                .map((child) => {
                const p = child.data;
                return {
                    title: p.title,
                    url: p.url,
                    permalink: `https://reddit.com${p.permalink}`,
                    score: p.score,
                    numComments: p.num_comments,
                    subreddit: p.subreddit,
                    createdUtc: p.created_utc,
                };
            });
            allPosts.push(...posts);
        }
        catch {
            console.log(`⚠️ Reddit r/${subreddit} fetch failed, skipping`);
        }
    }
    // Deduplicate by URL
    const seen = new Set();
    const deduped = allPosts.filter(p => {
        if (seen.has(p.url))
            return false;
        seen.add(p.url);
        return true;
    });
    deduped.sort((a, b) => b.score - a.score);
    console.log(`📊 Reddit: ${deduped.length} posts from [${subreddits.slice(0, 3).join(', ')}]`);
    return deduped;
};
exports.getRedditHotPosts = getRedditHotPosts;
// Legacy export for backward compatibility
const getRedditTrends = () => (0, exports.getRedditHotPosts)(['popular'], 10);
exports.getRedditTrends = getRedditTrends;
const getSubredditsForCountry = (countryCode) => COUNTRY_SUBREDDITS[countryCode.toUpperCase()] ?? ['worldnews'];
exports.getSubredditsForCountry = getSubredditsForCountry;
const getSubredditsForTopic = (topic) => {
    const lower = topic.toLowerCase();
    for (const [key, subs] of Object.entries(TOPIC_SUBREDDITS)) {
        if (lower.includes(key))
            return subs;
    }
    return ['worldnews'];
};
exports.getSubredditsForTopic = getSubredditsForTopic;
