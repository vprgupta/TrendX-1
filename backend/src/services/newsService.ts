import Parser from 'rss-parser';
import axios from 'axios';
import NodeCache from 'node-cache';

// Initialize cache with 15 minutes TTL (900 seconds)
const newsCache = new NodeCache({ stdTTL: 900 });
const parser = new Parser();

export interface NewsItem {
    title: string;
    link: string;
    pubDate: string;
    content: string;
    contentSnippet: string;
    source: string;
    imageUrl?: string;
    author?: string;
}

/**
 * Get world news using NewsAPI.org with RSS fallback
 */
export const getWorldNews = async (category: string, country: string = 'us'): Promise<NewsItem[]> => {
    const cacheKey = `world_${category}_${country}`;
    const cachedData = newsCache.get<NewsItem[]>(cacheKey);

    if (cachedData) {
        return cachedData;
    }

    const NEWSDATA_API_KEY = process.env.NEWSDATA_API_KEY;
    let newsItems: NewsItem[] = [];

    // Try NewsData.io API first if key is available
    if (NEWSDATA_API_KEY) {
        try {
            const apiCategory = mapCategoryToNewsData(category);
            const newsdataUrl = new URL('https://newsdata.io/api/1/news');
            newsdataUrl.searchParams.append('apikey', NEWSDATA_API_KEY);
            newsdataUrl.searchParams.append('country', country.toLowerCase());
            newsdataUrl.searchParams.append('language', 'en');
            newsdataUrl.searchParams.append('category', apiCategory);

            // Set a swift 3.5s timeout.
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 3500);

            const response = await fetch(newsdataUrl.toString(), { signal: controller.signal });
            clearTimeout(timeoutId);

            const data = await response.json();

            if (data.status === 'success' && data.results) {
                newsItems = data.results.map((article: any) => ({
                    title: article.title || 'No title',
                    link: article.link || '#',
                    pubDate: article.pubDate || new Date().toISOString(),
                    content: article.content || article.description || '',
                    contentSnippet: article.description || '',
                    source: article.source_id || 'NewsData',
                    imageUrl: article.image_url,
                    author: (article.creator && article.creator.length > 0) ? article.creator[0] : (article.source_id || 'NewsData')
                }));
            }
        } catch (error: any) {
            console.log(`⚠️ NewsData API unreachable (${error.name === 'AbortError' ? 'timeout' : 'blocked'}), swiftly falling back to Google RSS.`);
        }
    }

    // Fallback to Google News RSS if NewsAPI failed or returned nothing
    if (newsItems.length === 0) {
        newsItems = await getGoogleNewsRSS(category, country);
    }

    // ─── Velocity-style sort ─────────────────────────────────────────
    // Score = recency_weight × source_weight
    // Recency: exponential decay with 2-hour half-life → freshest stories rocket to the top
    // Source: NewsData > Google RSS (NewsData queries are country-specific so they're more relevant)
    const now = Date.now();
    const scored = newsItems.map(item => {
        const pubMs = new Date(item.pubDate).getTime();
        const ageHours = (now - pubMs) / (1000 * 60 * 60);
        // Half-life of 2 hours — a story published 2h ago scores 50% of a brand-new one
        const recencyScore = Math.exp(-0.347 * ageHours); // ln(2)/2 ≈ 0.347
        const sourceWeight = item.source === 'NewsData' ? 1.2 : 1.0;
        return { item, score: recencyScore * sourceWeight };
    });
    scored.sort((a, b) => b.score - a.score);

    // Deduplicate by title (skip items whose title overlaps >60% with already-seen ones)
    const seen: string[] = [];
    const deduped: NewsItem[] = [];
    for (const { item } of scored) {
        const titleWords = new Set(item.title.toLowerCase().split(/\s+/).filter(w => w.length > 3));
        const isDupe = seen.some(seenTitle => {
            const seenWords = new Set(seenTitle.toLowerCase().split(/\s+/).filter(w => w.length > 3));
            let overlap = 0;
            titleWords.forEach(w => { if (seenWords.has(w)) overlap++; });
            return overlap >= 3;
        });
        if (!isDupe) {
            deduped.push(item);
            seen.push(item.title);
        }
    }

    if (deduped.length > 0) {
        newsCache.set(cacheKey, deduped);
    }

    return deduped;
};

/**
 * Get technology news from various RSS feeds
 */
export const getTechNews = async (category: string): Promise<NewsItem[]> => {
    const cacheKey = `tech_${category}`;
    const cachedData = newsCache.get<NewsItem[]>(cacheKey);

    if (cachedData) {
        return cachedData;
    }

    const techFeeds: Record<string, string> = {
        'AI': 'https://www.artificialintelligence-news.com/feed/',
        'Mobile': 'https://www.theverge.com/rss/mobile/index.xml',
        'Web': 'https://css-tricks.com/feed/',
        'Blockchain': 'https://cointelegraph.com/rss',
        'IoT': 'https://iot.electronicsforu.com/feed/',
        'Robotics': 'https://www.roboticsbusinessreview.com/feed/',
        'Cloud': 'https://www.cloudcomputing-news.net/feed/',
        'Cybersecurity': 'https://www.darkreading.com/rss.xml'
    };

    try {
        const feedUrl = techFeeds[category] || 'https://techcrunch.com/feed/';
        const feed = await parser.parseURL(feedUrl);

        const newsItems = feed.items.slice(0, 50).map(item => ({
            title: item.title || 'No title',
            link: item.link || '#',
            pubDate: item.pubDate || new Date().toISOString(),
            content: item.content || item.contentSnippet || '',
            contentSnippet: item.contentSnippet || '',
            source: category,
            imageUrl: extractImageFromContent(item.content),
            author: item.creator || item.author
        }));

        if (newsItems.length > 0) {
            newsCache.set(cacheKey, newsItems);
        }

        return newsItems;
    } catch (error) {
        console.error(`Error fetching ${category} news:`, error);
        return [];
    }
};

/**
 * Smart router — each category gets the best specialized source
 */
export const getNews = async (category: string = 'world', country: string = 'US'): Promise<NewsItem[]> => {
    // Strip emojis and normalize the category string
    const raw = category.replace(/[^\w\s]/gi, '').trim().toLowerCase();

    // 🔧 TECH — Hacker News: truly community-voted trending tech stories, no API key, no rate limit
    if (['technology', 'tech', 'ai', 'mobile', 'web', 'cybersecurity', 'blockchain', 'cloud', 'robotics', 'iot'].includes(raw)) {
        return getHackerNewsTrending(raw);
    }

    // 🌐 GEOPOLITICS / WORLD POLITICS — The Guardian: premium world journalism, free, no key
    if (['geopolitics', 'politics', 'world politics', 'international'].includes(raw)) {
        return getGuardianNews('world', country);
    }

    // Everything else (local, top, sports, health etc.) — NewsData.io + Google RSS fallback
    const targetCategory = raw === 'country' ? 'nation' : raw;
    return getWorldNews(targetCategory, country);
};

/**
 * Google News RSS fallback
 */
const getGoogleNewsRSS = async (category: string, country: string): Promise<NewsItem[]> => {
    const cacheKey = `rss_${category}_${country}`;
    const cachedData = newsCache.get<NewsItem[]>(cacheKey);
    if (cachedData) {
        return cachedData;
    }

    let feedUrl = '';

    const countryFeeds: Record<string, string> = {
        'US': 'https://news.google.com/rss?hl=en-US&gl=US&ceid=US:en',
        'IN': 'https://news.google.com/rss?hl=en-IN&gl=IN&ceid=IN:en',
        'UK': 'https://news.google.com/rss?hl=en-GB&gl=GB&ceid=GB:en',
        'GB': 'https://news.google.com/rss?hl=en-GB&gl=GB&ceid=GB:en',
        'CA': 'https://news.google.com/rss?hl=en-CA&gl=CA&ceid=CA:en',
        'AU': 'https://news.google.com/rss?hl=en-AU&gl=AU&ceid=AU:en',
        'JP': 'https://news.google.com/rss?hl=en-JP&gl=JP&ceid=JP:en',
        'DE': 'https://news.google.com/rss?hl=en-DE&gl=DE&ceid=DE:en',
        'FR': 'https://news.google.com/rss?hl=en-FR&gl=FR&ceid=FR:en',
        'BR': 'https://news.google.com/rss?hl=en-BR&gl=BR&ceid=BR:en',
        'NP': 'https://news.google.com/rss?hl=en-NP&gl=NP&ceid=NP:ne',
        'PK': 'https://news.google.com/rss?hl=en-PK&gl=PK&ceid=PK:en',
        'BD': 'https://news.google.com/rss?hl=en-BD&gl=BD&ceid=BD:en',
        'LK': 'https://news.google.com/rss?hl=en-LK&gl=LK&ceid=LK:en',
        'KR': 'https://news.google.com/rss?hl=en-KR&gl=KR&ceid=KR:en',
        'AF': 'https://news.google.com/rss?hl=en-AF&gl=AF&ceid=AF:en',
        'BT': 'https://news.google.com/rss?hl=en-BT&gl=BT&ceid=BT:en',
        'MV': 'https://news.google.com/rss?hl=en-MV&gl=MV&ceid=MV:en',
    };

    const topicFeeds: Record<string, string> = {
        'science': 'SCIENCE',
        'health': 'HEALTH',
        'sports': 'SPORTS',
        'entertainment': 'ENTERTAINMENT',
        'technology': 'TECHNOLOGY',
        'tech': 'TECHNOLOGY',
        'politics': 'NATION',
        'business': 'BUSINESS',
        'world': 'WORLD',
        'global': 'WORLD',
        'local': 'NATION'
    };

    const normalizedCategory = category.toLowerCase();

    if (normalizedCategory === 'general' || normalizedCategory === 'country'
        || normalizedCategory === 'top' || normalizedCategory === 'nation'
        || normalizedCategory === 'local') {
        // Use country-specific feed if available, else fall back to US
        feedUrl = countryFeeds[country.toUpperCase()] || countryFeeds['US'];
    } else if (topicFeeds[normalizedCategory]) {
        feedUrl = `https://news.google.com/rss/headlines/section/topic/${topicFeeds[normalizedCategory]}?hl=en-${country}&gl=${country}&ceid=${country}:en`;
    } else {
        feedUrl = `https://news.google.com/rss/headlines/section/topic/WORLD?hl=en-${country}&gl=${country}&ceid=${country}:en`;
    }

    try {
        const feed = await parser.parseURL(feedUrl);

        const newsItems = feed.items.map(item => {
            let imageUrl: string | undefined;
            if (item.content) {
                const imgMatch = item.content.match(/<img[^>]+src="([^">]+)"/);
                if (imgMatch && imgMatch[1]) {
                    imageUrl = imgMatch[1];
                }
            }

            if (!imageUrl && (item as any).enclosure && (item as any).enclosure.url) {
                imageUrl = (item as any).enclosure.url;
            }

            return {
                title: item.title || 'No title',
                link: item.link || '#',
                pubDate: item.pubDate || new Date().toISOString(),
                content: item.content || '',
                contentSnippet: item.contentSnippet || '',
                source: item.creator || item.author || 'Google News',
                imageUrl: imageUrl,
                author: item.creator || item.author
            };
        });

        if (newsItems.length > 0) {
            newsCache.set(cacheKey, newsItems);
        }

        return newsItems;
    } catch (error) {
        console.error('Error fetching Google News RSS:', error);
        return [];
    }
};

/**
 * 🔧 Hacker News — Real-time trending tech stories ranked by community votes
 * Completely free, no API key, no rate limit
 */
const getHackerNewsTrending = async (subCategory: string = 'tech'): Promise<NewsItem[]> => {
    const cacheKey = `hn_${subCategory}`;
    const cached = newsCache.get<NewsItem[]>(cacheKey);
    if (cached) return cached;

    try {
        // Algolia HN search API — get stories from the last 24 hours ranked by points
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 5000);

        const query = subCategory === 'tech' || subCategory === 'technology' ? '' : encodeURIComponent(subCategory);
        const url = query
            ? `https://hn.algolia.com/api/v1/search?tags=story&query=${query}&hitsPerPage=50&numericFilters=points>50`
            : `https://hn.algolia.com/api/v1/search_by_date?tags=story&hitsPerPage=50&numericFilters=points>100`;

        const response = await fetch(url, { signal: controller.signal });
        clearTimeout(timeoutId);

        const data = await response.json();

        if (data.hits && data.hits.length > 0) {
            const newsItems: NewsItem[] = data.hits
                .filter((hit: any) => hit.url) // Only include stories with external links
                .map((hit: any) => ({
                    title: hit.title || 'No title',
                    link: hit.url || `https://news.ycombinator.com/item?id=${hit.objectID}`,
                    pubDate: hit.created_at || new Date().toISOString(),
                    content: `${hit.points} points · ${hit.num_comments} comments on Hacker News`,
                    contentSnippet: `${hit.points} points · ${hit.num_comments} comments`,
                    source: 'Hacker News',
                    imageUrl: undefined,
                    author: hit.author
                }));

            if (newsItems.length > 0) newsCache.set(cacheKey, newsItems);
            return newsItems;
        }
    } catch (error: any) {
        console.log(`⚠️ Hacker News API unreachable, falling back to TechCrunch RSS.`);
    }

    // Fallback: TechCrunch RSS
    return getTechRSSFallback(subCategory);
};

/**
 * TechCrunch/Verge RSS fallback for when HN times out
 */
const getTechRSSFallback = async (subCategory: string): Promise<NewsItem[]> => {
    const feeds: Record<string, string> = {
        'ai': 'https://www.artificialintelligence-news.com/feed/',
        'mobile': 'https://www.theverge.com/rss/mobile/index.xml',
        'cybersecurity': 'https://www.darkreading.com/rss.xml',
        'blockchain': 'https://cointelegraph.com/rss',
    };
    try {
        const feedUrl = feeds[subCategory] || 'https://techcrunch.com/feed/';
        const feed = await parser.parseURL(feedUrl);
        return feed.items.slice(0, 50).map(item => ({
            title: item.title || 'No title',
            link: item.link || '#',
            pubDate: item.pubDate || new Date().toISOString(),
            content: item.content || item.contentSnippet || '',
            contentSnippet: item.contentSnippet || '',
            source: 'TechCrunch',
            imageUrl: extractImageFromContent(item.content),
            author: item.creator || item.author
        }));
    } catch {
        return [];
    }
};

/**
 * 🌐 The Guardian — World-class free geopolitics and world affairs journalism
 * Free API, no usage limits for development
 */
const getGuardianNews = async (section: string = 'world', country: string = 'US'): Promise<NewsItem[]> => {
    const cacheKey = `guardian_${section}_${country}`;
    const cached = newsCache.get<NewsItem[]>(cacheKey);
    if (cached) return cached;

    try {
        // The Guardian has a free open API with no key required (just &show-fields=all)
        const guardianUrl = new URL('https://content.guardianapis.com/search');
        guardianUrl.searchParams.append('api-key', 'test'); // 'test' key gives 12 req/s free
        guardianUrl.searchParams.append('section', 'world|politics|international');
        guardianUrl.searchParams.append('show-fields', 'thumbnail,trailText,byline');
        guardianUrl.searchParams.append('order-by', 'newest');
        guardianUrl.searchParams.append('page-size', '50');

        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 5000);

        const response = await fetch(guardianUrl.toString(), { signal: controller.signal });
        clearTimeout(timeoutId);

        const data = await response.json();

        if (data.response && data.response.results) {
            const newsItems: NewsItem[] = data.response.results.map((article: any) => ({
                title: article.webTitle || 'No title',
                link: article.webUrl || '#',
                pubDate: article.webPublicationDate || new Date().toISOString(),
                content: article.fields?.trailText || '',
                contentSnippet: article.fields?.trailText || '',
                source: 'The Guardian',
                imageUrl: article.fields?.thumbnail,
                author: article.fields?.byline
            }));

            if (newsItems.length > 0) newsCache.set(cacheKey, newsItems);
            return newsItems;
        }
    } catch (error: any) {
        console.log(`⚠️ Guardian API unreachable, falling back to Google News RSS.`);
    }

    // Fallback to Google News WORLD section
    return getGoogleNewsRSS('world', country);
};

/**
 * Map category names to NewsData.io topics
 */
const mapCategoryToNewsData = (category: string): string => {
    // Strip out any emojis, symbols, and extra whitespace sent from frontend (e.g. '📱 mobile' -> 'mobile')
    const cleanCategory = category.replace(/[^\w\s]/gi, '').trim().toLowerCase();

    const mapping: Record<string, string> = {
        'science': 'science',
        'health': 'health',
        'sports': 'sports',
        'entertainment': 'entertainment',
        'technology': 'technology',
        'tech': 'technology',
        'mobile': 'technology',
        'ai': 'technology',
        'web': 'technology',
        'cybersecurity': 'technology',
        'politics': 'politics',
        'geopolitics': 'politics',
        'local': 'top',
        'nation': 'top',
        'business': 'business',
        'world': 'world',
        'global': 'world',
        'general': 'top'
    };
    return mapping[cleanCategory] || 'top';
};

/**
 * Extract image URL from HTML content
 */
const extractImageFromContent = (content?: string): string | undefined => {
    if (!content) return undefined;
    const imgMatch = content.match(/<img[^>]+src="([^">]+)"/);
    return imgMatch ? imgMatch[1] : undefined;
};
