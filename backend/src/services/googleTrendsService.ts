import Parser from 'rss-parser';

const parser = new Parser();

// Maps country codes to Google Trends geo codes
const GEO_MAP: Record<string, string> = {
    'IN': 'IN', 'US': 'US', 'GB': 'GB', 'JP': 'JP',
    'DE': 'DE', 'FR': 'FR', 'BR': 'BR', 'CA': 'CA',
    'AU': 'AU', 'CN': 'CN', 'RU': 'RU',
};

export interface TrendingKeyword {
    keyword: string;
    traffic: number; // approximate search volume spike from Google Trends
    relatedArticleUrl?: string;
}

/**
 * Fetches daily trending searches for a country from Google Trends RSS.
 * No API key required — this is Google's public RSS endpoint.
 */
export const getGoogleTrends = async (countryCode: string = 'US'): Promise<TrendingKeyword[]> => {
    const geo = GEO_MAP[countryCode.toUpperCase()] ?? 'US';
    const url = `https://trends.google.com/trends/trendingsearches/daily/rss?geo=${geo}`;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 6000);

    const response = await fetch(url, { signal: controller.signal });
    clearTimeout(timeoutId);

    const xml = await response.text();

    // Parse RSS manually — Google Trends uses a custom namespace (ht:)
    const keywords: TrendingKeyword[] = [];
    const itemMatches = xml.matchAll(/<item>([\s\S]*?)<\/item>/g);

    for (const match of itemMatches) {
        const item = match[1];

        const titleMatch = item.match(/<title><!\[CDATA\[(.*?)\]\]><\/title>|<title>(.*?)<\/title>/);
        const trafficMatch = item.match(/<ht:approx_traffic>(.*?)<\/ht:approx_traffic>/);
        const linkMatch = item.match(/<ht:news_item_url><!\[CDATA\[(.*?)\]\]><\/ht:news_item_url>|<ht:news_item_url>(.*?)<\/ht:news_item_url>/);

        const keyword = titleMatch?.[1] ?? titleMatch?.[2] ?? '';
        const trafficStr = trafficMatch?.[1]?.replace(/[^0-9]/g, '') ?? '0';
        const traffic = parseInt(trafficStr, 10) || 0;
        const relatedArticleUrl = linkMatch?.[1] ?? linkMatch?.[2];

        if (keyword) {
            keywords.push({ keyword, traffic, relatedArticleUrl });
        }
    }

    console.log(`📈 Google Trends [${geo}]: ${keywords.length} trending keywords (top: ${keywords[0]?.keyword})`);
    return keywords.slice(0, 20); // Top 20 trending topics
};

/**
 * Scores a news article title against the trending keywords list.
 * Returns 0 if no match, or a weighted score if one or more keywords are found in the title.
 */
export const scoreTitleAgainstTrends = (title: string, trends: TrendingKeyword[]): number => {
    if (!title || trends.length === 0) return 0;
    const lowerTitle = title.toLowerCase();

    let maxScore = 0;
    for (const trend of trends) {
        const keywordWords = trend.keyword.toLowerCase().split(/\s+/);
        // Check how many words of the keyword appear in the title
        const matches = keywordWords.filter(w => w.length > 2 && lowerTitle.includes(w)).length;
        if (matches >= Math.ceil(keywordWords.length * 0.6)) {
            // Normalize traffic to a 0–50 score (max traffic seen ~ 1M+)
            const trendsScore = Math.min(50, (trend.traffic / 20000));
            maxScore = Math.max(maxScore, trendsScore);
        }
    }
    return maxScore;
};
