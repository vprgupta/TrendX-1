import Parser from 'rss-parser';
import axios from 'axios';
import NodeCache from 'node-cache';
import { getBreakingNews } from './breakingNewsService';

// 5-minute cache — politics news must be fresh
const newsCache = new NodeCache({ stdTTL: 300 });
const parser = new Parser({
    timeout: 8000,
    customFields: {
        item: [
            ['media:content', 'mediaContent', { keepArray: false }],
            ['media:thumbnail', 'mediaThumbnail', { keepArray: false }],
            ['media:group', 'mediaGroup', { keepArray: false }],
            ['enclosure', 'enclosure', { keepArray: false }],
            ['content:encoded', 'content:encoded', { keepArray: false }],
            ['description', 'description', { keepArray: false }],
        ],
    },
});

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
            imageUrl: extractItemImage(item as any),
            author: (item as any).creator || (item as any).author
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
 * ─── India regional feeds ────────────────────────────────────────────────────
 * Reliable, always-free RSS sources organised by category.
 * Each bucket is fetched in parallel and merged with the NewsData / Google RSS
 * pipeline so that local stories are always represented alongside global ones.
 */
const REGIONAL_FEEDS: Record<string, Record<string, string[]>> = {
    IN: {
        politics:      [
            'https://timesofindia.indiatimes.com/rssfeeds/4719148.cms',        // TOI Politics
            'https://feeds.feedburner.com/ndtvnews-india-news',                 // NDTV India
            'https://www.thehindu.com/news/national/?service=rss',             // The Hindu National
            'https://indianexpress.com/section/india/feed/',                   // Indian Express India
        ],
        business:      [
            'https://economictimes.indiatimes.com/markets/rssfeeds/1977021501.cms', // ET Markets
            'https://www.livemint.com/rss/markets',                            // Livemint Markets
            'https://feeds.feedburner.com/businessworld',                      // BusinessWorld
            'https://www.business-standard.com/rss/latest.rss',               // Business Standard
        ],
        health:        [
            'https://timesofindia.indiatimes.com/rssfeeds/3908999.cms',        // TOI Health
            'https://www.thehindu.com/sci-tech/health/?service=rss',           // The Hindu Health
            'https://www.healthline.com/rss/news',                             // Healthline (global)
        ],
        entertainment: [
            'https://timesofindia.indiatimes.com/rssfeeds/contentid-1081479906831.cms', // TOI Bollywood
            'https://feeds.feedburner.com/ndtvmoviesreviews',                  // NDTV Movies
            'https://www.pinkvilla.com/feed',                                  // PinkVilla
        ],
        sports:        [
            'https://timesofindia.indiatimes.com/rssfeeds/4719155.cms',        // TOI Sports
            'https://feeds.feedburner.com/ndtvsports',                         // NDTV Sports
            'https://www.espncricinfo.com/rss/content/story/feeds/0.xml',      // ESPNcricinfo
        ],
        science:       [
            'https://www.thehindu.com/sci-tech/science/?service=rss',          // The Hindu Science
            'https://timesofindia.indiatimes.com/rssfeeds/2647163.cms',        // TOI Science
            'https://www.sciencedaily.com/rss/top/science.xml',               // ScienceDaily (global)
        ],
    },
};

/**
 * Fetch all India regional RSS feeds for a given category in parallel,
 * merge with NewsData/Google RSS, deduplicate and return top 25 items.
 */
const getRegionalNews = async (category: string, countryCode: string): Promise<NewsItem[]> => {
    const cc = countryCode.toUpperCase();
    const cat = category.toLowerCase();

    // Map loose category names to our keys
    const catKey = (() => {
        if (['politics','nation','top','local'].includes(cat)) return 'politics';
        if (['business','finance','economy'].includes(cat)) return 'business';
        if (['health','medicine'].includes(cat)) return 'health';
        if (['entertainment','bollywood','movies'].includes(cat)) return 'entertainment';
        if (['sports','cricket','football'].includes(cat)) return 'sports';
        if (['science','tech','technology'].includes(cat)) return 'science';
        return null;
    })();

    const cacheKey = `regional_${cc}_${catKey ?? cat}`;
    const cached = newsCache.get<NewsItem[]>(cacheKey);
    if (cached) return cached;

    const regionalItems: NewsItem[] = [];

    // ─── India regional RSS feeds ────────────────────────────────────────────
    const feeds = (catKey && REGIONAL_FEEDS[cc]?.[catKey]) ?? [];
    if (feeds.length > 0) {
        const results = await Promise.allSettled(feeds.map(url => parser.parseURL(url)));
        for (const r of results) {
            if (r.status !== 'fulfilled') continue;
            for (const item of r.value.items.slice(0, 20)) {
                regionalItems.push({
                    title:           item.title ?? 'Untitled',
                    link:            item.link ?? '#',
                    pubDate:         item.pubDate ?? item.isoDate ?? new Date().toISOString(),
                    content:         item.content ?? item.contentSnippet ?? '',
                    contentSnippet:  item.contentSnippet ?? '',
                    source:          (item as any).creator ?? (item as any).source?.title ?? r.value.title ?? 'Local',
                    imageUrl:        extractItemImage(item as any),
                    author:          (item as any).creator ?? (item as any).author,
                });
            }
        }
    }

    // Merge with NewsData / Google RSS pipeline for broader coverage
    const [genericResult] = await Promise.allSettled([getWorldNews(catKey ?? cat, cc)]);
    const generic = genericResult.status === 'fulfilled' ? genericResult.value : [];

    const all = [...regionalItems, ...generic];

    // Sort by recency
    all.sort((a, b) => new Date(b.pubDate).getTime() - new Date(a.pubDate).getTime());

    // Deduplicate
    const seen = new Set<string>();
    const deduped: NewsItem[] = [];
    for (const item of all) {
        const key = item.title.toLowerCase().replace(/[^a-z0-9]/g, '').substring(0, 70);
        if (!seen.has(key)) {
            seen.add(key);
            deduped.push(item);
        }
        if (deduped.length >= 25) break;
    }

    console.log(`🗺️  [Regional ${cc}/${catKey ?? cat}] ${regionalItems.length} local + ${generic.length} generic → ${deduped.length} final`);
    if (deduped.length > 0) newsCache.set(cacheKey, deduped, 300); // 5-min cache
    return deduped;
};


/**
 * Smart router — each category gets the best specialized source
 */
export const getNews = async (category: string = 'world', country: string = 'US'): Promise<NewsItem[]> => {
    // Strip emojis and normalize the category string
    const raw = category.replace(/[^\w\s]/gi, '').trim().toLowerCase();
    const cc = country.toUpperCase();

    // 🇮🇳 REGIONAL — highest priority: India always gets country-specific feeds.
    // This MUST come before the geopolitics check so India+Politics → Indian politics
    // (not global Guardian/BBC politics)
    if (cc === 'IN') {
        return getRegionalNews(raw, cc);
    }

    // 🌐 GEOPOLITICS / WORLD POLITICS — multi-source, up to 50 fresh global stories
    // Only reached for non-IN/NP countries
    if (['geopolitics', 'politics', 'world politics', 'international', 'world', 'world news'].includes(raw)) {
        return getGlobalPoliticsNews(country);
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
            return {
                title: item.title || 'No title',
                link: item.link || '#',
                pubDate: item.pubDate || new Date().toISOString(),
                content: item.content || '',
                contentSnippet: item.contentSnippet || '',
                source: (item as any).creator || (item as any).author || 'Google News',
                imageUrl: extractItemImage(item as any),
                author: (item as any).creator || (item as any).author
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
        const oneWeekAgo = Math.floor((Date.now() - 7 * 24 * 3600 * 1000) / 1000);
        const url = query
            ? `https://hn.algolia.com/api/v1/search_by_date?tags=story&query=${query}&hitsPerPage=50&numericFilters=points>20,created_at_i>${oneWeekAgo}`
            : `https://hn.algolia.com/api/v1/search_by_date?tags=story&hitsPerPage=50&numericFilters=points>50,created_at_i>${oneWeekAgo}`;

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
            imageUrl: extractItemImage(item as any),
            author: (item as any).creator || (item as any).author
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
 * 🌍 Global Politics Aggregator
 * Pulls from 6 sources in parallel, filters to 6h, deduplicates, returns top 50
 * freshest globally-trending political stories.
 */
const getGlobalPoliticsNews = async (country: string = 'US'): Promise<NewsItem[]> => {
    const cacheKey = `politics_global_v2_${country}`; // Bump cache version
    const cached = newsCache.get<NewsItem[]>(cacheKey);
    if (cached) return cached;

    // Use a wider window (24h) but sort strictly by recency
    const MAX_AGE_H = 24;
    const cutoffMs = Date.now() - MAX_AGE_H * 3_600_000;

    const isFresh = (pubDate: string) => {
        const ms = new Date(pubDate).getTime();
        return !isNaN(ms) && ms >= cutoffMs;
    };

    // ── Fetch high-volume and high-quality sources in parallel ────────────────
    const [guardianResult, breakingResult, newsDataResult, googlePoliticsResult] =
        await Promise.allSettled([
            // 1. The Guardian API (World/Politics)
            getGuardianNews('world|politics|international', country),

            // 2. Breaking News Service (BBC, Sky, Al Jazeera, Reuters, AP, etc.)
            getBreakingNews('World'),

            // 3. NewsData.io (via our existing getWorldNews for high volume)
            getWorldNews('world', country),

            // 4. Google News RSS fallback (World topic)
            getGoogleNewsRSS('world', country),
        ]);

    // ── Merge all results ─────────────────────────────────────────────────────
    const all: NewsItem[] = [];
    for (const r of [guardianResult, breakingResult, newsDataResult, googlePoliticsResult]) {
        if (r.status === 'fulfilled') all.push(...r.value);
    }

    // ── Soft Freshness filter (24h) ───────────────────────────────────────────
    const fresh = all.filter(item => isFresh(item.pubDate));

    // ── Sort newest first ─────────────────────────────────────────────────────
    // This naturally puts < 2h items at the top
    fresh.sort((a, b) => new Date(b.pubDate).getTime() - new Date(a.pubDate).getTime());

    // ── Deduplicate by title (keep first/newest occurrence) ───────────────────
    const seen = new Set<string>();
    const deduped: NewsItem[] = [];
    for (const item of fresh) {
        const key = item.title.toLowerCase().replace(/[^a-z0-9]/g, '').substring(0, 80);
        if (!seen.has(key)) {
            seen.add(key);
            deduped.push(item);
        }
        if (deduped.length >= 50) break;  // cap at 50
    }

    console.log(`🌍 [GlobalNews] ${all.length} raw → ${fresh.length} fresh → ${deduped.length} after dedup`);

    if (deduped.length > 0) newsCache.set(cacheKey, deduped);
    return deduped;
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
 * Extract the first valid image URL from any HTML string.
 */
const extractImageFromHtml = (html?: string): string | undefined => {
    if (!html || typeof html !== 'string') return undefined;
    // Match src with both single and double quotes, require http
    const m = html.match(/<img[^>]+src=["']([^"'\s>]+)["']/i);
    return m && m[1] && m[1].startsWith('http') ? m[1] : undefined;
};

/**
 * Extract image from an RSS item - checks all possible image fields in priority order.
 * Handles media:content, media:thumbnail, media:group, enclosure, and HTML img tags
 * across content, summary, content:encoded, and description fields.
 */
const extractItemImage = (item: any): string | undefined => {
    // 1. media:content (most common for TOI, NDTV, BBC)
    const mc = item.mediaContent;
    if (mc) {
        if (typeof mc === 'string' && mc.startsWith('http')) return mc;
        if (mc.$ && mc.$.url) return mc.$.url;
    }
    // 2. media:thumbnail (WordPress, many Indian sources)
    const mt = item.mediaThumbnail;
    if (mt) {
        if (typeof mt === 'string' && mt.startsWith('http')) return mt;
        if (mt.$ && mt.$.url) return mt.$.url;
    }
    // 3. media:group > media:content
    const mg = item.mediaGroup;
    if (mg && mg['media:content']) {
        const mgContent = mg['media:content'];
        if (mgContent.$ && mgContent.$.url) return mgContent.$.url;
    }
    // 4. enclosure (BBC, NPR, etc.)
    const enc = item.enclosure;
    if (enc && enc.url && (enc.type?.startsWith('image') || /\.(jpg|jpeg|png|webp|gif)/i.test(enc.url))) {
        return enc.url;
    }
    // 5. Parse img src from every HTML-bearing field (in priority order)
    const htmlFields = [
        item.content,
        item['content:encoded'],
        item.summary,
        item.description,
    ];
    for (const html of htmlFields) {
        const url = extractImageFromHtml(html);
        if (url) return url;
    }
    return undefined;
};

