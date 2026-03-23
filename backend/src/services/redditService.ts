export interface RedditPost {
    title: string;
    url: string;        // external news article URL (not reddit.com)
    permalink: string;  // reddit.com discussion link
    score: number;      // upvotes
    numComments: number;
    subreddit: string;
    createdUtc: number;
}

// Country → relevant news subreddits
const COUNTRY_SUBREDDITS: Record<string, string[]> = {
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
const TOPIC_SUBREDDITS: Record<string, string[]> = {
    'technology': ['technology', 'tech', 'programming'],
    'science': ['science', 'futurology'],
    'politics': ['politics', 'worldnews'],
    'geopolitics': ['geopolitics', 'worldnews'],
    'business': ['business', 'economy'],
    'health': ['health', 'medicine'],
};

/**
 * Fetches hot posts from Reddit using the free public JSON API.
 * No API key required for public subreddit read access.
 */
export const getRedditHotPosts = async (
    subreddits: string[],
    limit: number = 25
): Promise<RedditPost[]> => {
    const allPosts: RedditPost[] = [];

    for (const subreddit of subreddits.slice(0, 3)) {
        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000);

            const response = await fetch(
                `https://www.reddit.com/r/${subreddit}/hot.json?limit=${limit}`,
                {
                    signal: controller.signal,
                    headers: {
                        'User-Agent': 'TrendX/1.0 (news aggregator)',
                    }
                }
            );
            clearTimeout(timeoutId);

            if (!response.ok) continue;

            const data = await response.json();
            const posts: RedditPost[] = (data.data?.children ?? [])
                .filter((child: any) => {
                    const p = child.data;
                    return !p.is_self &&
                        p.url &&
                        !p.url.includes('reddit.com') &&
                        p.score > 100;
                })
                .map((child: any) => {
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
        } catch {
            console.log(`⚠️ Reddit r/${subreddit} fetch failed, skipping`);
        }
    }

    // Deduplicate by URL
    const seen = new Set<string>();
    const deduped = allPosts.filter(p => {
        if (seen.has(p.url)) return false;
        seen.add(p.url);
        return true;
    });

    deduped.sort((a, b) => b.score - a.score);

    console.log(`📊 Reddit: ${deduped.length} posts from [${subreddits.slice(0, 3).join(', ')}]`);
    return deduped;
};

// Legacy export for backward compatibility
export const getRedditTrends = () => getRedditHotPosts(['popular'], 10);

export const getSubredditsForCountry = (countryCode: string): string[] =>
    COUNTRY_SUBREDDITS[countryCode.toUpperCase()] ?? ['worldnews'];

export const getSubredditsForTopic = (topic: string): string[] => {
    const lower = topic.toLowerCase();
    for (const [key, subs] of Object.entries(TOPIC_SUBREDDITS)) {
        if (lower.includes(key)) return subs;
    }
    return ['worldnews'];
};
