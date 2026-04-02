"use strict";
/**
 * breakingNewsService.ts
 *
 * Pulls live RSS feeds from BBC, Reuters, AP, Al Jazeera, and NPR.
 * These update within 1–5 minutes of publication — the fastest free
 * sources available without a paid API key.
 *
 * Filters to MAX_AGE_HOURS to guarantee freshness, then adds them into
 * the trending pipeline so users see stories before other aggregators.
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.BREAKING_MAX_AGE_HOURS = void 0;
exports.getBreakingNews = getBreakingNews;
exports.startBreakingNewsRefresher = startBreakingNewsRefresher;
const rss_parser_1 = __importDefault(require("rss-parser"));
const node_cache_1 = __importDefault(require("node-cache"));
const parser = new rss_parser_1.default({
    timeout: 7000,
    customFields: {
        item: [
            ['media:content', 'mediaContent', { keepArray: false }],
            ['media:thumbnail', 'mediaThumbnail', { keepArray: false }],
            ['enclosure', 'enclosure', { keepArray: false }],
        ],
    },
});
/** Only news published within this many hours will be kept (increased for variety) */
exports.BREAKING_MAX_AGE_HOURS = 24;
/** Cache breaking news for 5 minutes — frequent refresh for near-real-time feed */
const breakingCache = new node_cache_1.default({ stdTTL: 300 });
const BREAKING_FEEDS = [
    // Global / World (update < 5 min)
    { name: 'BBC World News', url: 'http://feeds.bbci.co.uk/news/world/rss.xml', category: ['General', 'World'] },
    { name: 'Sky News World', url: 'https://feeds.skynews.com/feeds/rss/world.xml', category: ['General', 'World'] },
    { name: 'Yahoo News', url: 'https://news.yahoo.com/rss/', category: ['General'] },
    { name: 'Al Jazeera', url: 'https://www.aljazeera.com/xml/rss/all.xml', category: ['World'] },
    { name: 'NPR News', url: 'https://feeds.npr.org/1001/rss.xml', category: ['General'] },
    { name: 'Google News World', url: 'https://news.google.com/rss/headlines/section/topic/WORLD?hl=en-US&gl=US&ceid=US:en', category: ['General', 'World'] },
    { name: 'The Guardian World', url: 'https://www.theguardian.com/world/rss', category: ['General', 'World'] },
    { name: 'France 24 World', url: 'https://www.france24.com/en/rss', category: ['General', 'World'] },
    { name: 'DW World News', url: 'https://rss.dw.com/rdf/rss-en-world', category: ['General', 'World'] },
    { name: 'AP News World', url: 'https://news.google.com/rss/search?q=when:24h+source:Associated+Press&hl=en-US&gl=US&ceid=US:en', category: ['General', 'World'] },
    { name: 'Reuters World', url: 'https://news.google.com/rss/search?q=when:24h+source:Reuters&hl=en-US&gl=US&ceid=US:en', category: ['General', 'World'] },
    // Technology (update < 10 min)
    { name: 'BBC Technology', url: 'http://feeds.bbci.co.uk/news/technology/rss.xml', category: ['Technology'] },
    { name: 'The Verge', url: 'https://www.theverge.com/rss/index.xml', category: ['Technology'] },
    { name: 'Ars Technica', url: 'https://feeds.arstechnica.com/arstechnica/index', category: ['Technology', 'Science'] },
    { name: 'Wired', url: 'https://www.wired.com/feed/rss', category: ['Technology'] },
    { name: 'Sky News Tech', url: 'https://feeds.skynews.com/feeds/rss/technology.xml', category: ['Technology'] },
    // Business & Markets
    { name: 'BBC Business', url: 'http://feeds.bbci.co.uk/news/business/rss.xml', category: ['Business'] },
    { name: 'Yahoo Finance', url: 'https://finance.yahoo.com/news/rssindex', category: ['Business'] },
    { name: 'Sky News Business', url: 'https://feeds.skynews.com/feeds/rss/business.xml', category: ['Business'] },
    // Science & Health
    { name: 'BBC Science', url: 'http://feeds.bbci.co.uk/news/science_and_environment/rss.xml', category: ['Science', 'Health'] },
    { name: 'Yahoo Health', url: 'https://news.yahoo.com/rss/health', category: ['Health'] },
    // Sports
    { name: 'BBC Sport', url: 'http://feeds.bbci.co.uk/sport/rss.xml', category: ['Sports'] },
    { name: 'Sky Sports News', url: 'https://feeds.skynews.com/feeds/rss/sports.xml', category: ['Sports'] },
];
// ─── Helpers ─────────────────────────────────────────────────────────────────
function extractImage(item) {
    // 1. media:content
    const mc = item.mediaContent;
    if (mc) {
        if (typeof mc === 'string' && mc.startsWith('http'))
            return mc;
        if (mc.$ && mc.$.url)
            return mc.$.url;
    }
    // 2. media:thumbnail
    const mt = item.mediaThumbnail;
    if (mt) {
        if (typeof mt === 'string' && mt.startsWith('http'))
            return mt;
        if (mt.$ && mt.$.url)
            return mt.$.url;
    }
    // 3. enclosure
    const enc = item.enclosure;
    if (enc && enc.url && (enc.type?.startsWith('image') || /\.(jpg|jpeg|png|webp|gif)/i.test(enc.url))) {
        return enc.url;
    }
    // 4. Parse img src from every HTML-bearing field
    const htmlFields = [
        item.content,
        item['content:encoded'],
        item.summary,
        item.description,
    ];
    for (const html of htmlFields) {
        if (!html || typeof html !== 'string')
            continue;
        const m = html.match(/<img[^>]+src=["']([^"'\s>]+)["']/i);
        if (m && m[1] && m[1].startsWith('http'))
            return m[1];
    }
    return undefined;
}
function isFresh(pubDate) {
    const ms = new Date(pubDate).getTime();
    if (isNaN(ms))
        return false;
    return Date.now() - ms <= exports.BREAKING_MAX_AGE_HOURS * 3600000;
}
// ─── Main export ─────────────────────────────────────────────────────────────
/**
 * Fetch fresh breaking news articles (≤ 6 h old) from all RSS sources.
 * Optionally filter by category (e.g. 'Technology', 'Health').
 */
async function getBreakingNews(categoryFilter) {
    const cacheKey = `breaking_${categoryFilter ?? 'all'}`;
    const cached = breakingCache.get(cacheKey);
    if (cached)
        return cached;
    const feedsToFetch = categoryFilter
        ? BREAKING_FEEDS.filter(f => f.category.includes(categoryFilter))
        : BREAKING_FEEDS;
    const results = await Promise.allSettled(feedsToFetch.map(feed => fetchFeed(feed)));
    const all = [];
    for (const r of results) {
        if (r.status === 'fulfilled')
            all.push(...r.value);
    }
    // Sort by pubDate descending (newest first)
    all.sort((a, b) => new Date(b.pubDate).getTime() - new Date(a.pubDate).getTime());
    // Deduplicate by title
    const seen = new Set();
    const deduped = [];
    for (const item of all) {
        const key = item.title.toLowerCase().replace(/[^a-z0-9]/g, '').substring(0, 60);
        if (!seen.has(key)) {
            seen.add(key);
            deduped.push(item);
        }
    }
    if (deduped.length > 0)
        breakingCache.set(cacheKey, deduped);
    console.log(`⚡ [BreakingNews] ${deduped.length} fresh articles (≤${exports.BREAKING_MAX_AGE_HOURS}h)`);
    return deduped;
}
async function fetchFeed(feed) {
    try {
        const parsed = await parser.parseURL(feed.url);
        const items = [];
        for (const item of parsed.items) {
            const pubDate = item.pubDate || item.isoDate || '';
            if (!isFresh(pubDate))
                continue; // skip stale
            items.push({
                title: item.title || 'No title',
                link: item.link || '#',
                pubDate,
                content: item.content || item.contentSnippet || item.summary || '',
                contentSnippet: item.contentSnippet || item.summary || '',
                source: feed.name,
                imageUrl: extractImage(item),
                author: item.creator || item.author || feed.name,
            });
        }
        return items;
    }
    catch (err) {
        // Don't crash if one feed is down
        console.warn(`⚠️  [BreakingNews] ${feed.name} failed: ${err.message}`);
        return [];
    }
}
/**
 * Pre-warm the cache in the background (call once on server start).
 * Refreshes every 5 minutes automatically via the TTL.
 */
function startBreakingNewsRefresher() {
    // Initial warm-up
    getBreakingNews().catch(() => { });
    // Refresh every 5 minutes (aligns with cache TTL)
    setInterval(() => {
        breakingCache.flushAll();
        getBreakingNews().catch(() => { });
        console.log('🔄 [BreakingNews] Cache refreshed');
    }, 5 * 60 * 1000);
}
