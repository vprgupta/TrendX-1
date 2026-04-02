"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getTrendingNews = void 0;
const node_cache_1 = __importDefault(require("node-cache"));
const newsService_1 = require("./newsService");
const googleTrendsService_1 = require("./googleTrendsService");
const redditService_1 = require("./redditService");
const breakingNewsService_1 = require("./breakingNewsService");
// Cache for 5 minutes — aligns with breaking news refresh rate
const trendingCache = new node_cache_1.default({ stdTTL: 300 });
/** Articles older than this are considered stale and excluded */
const MAX_AGE_HOURS = 2;
// ─── Sentiment ────────────────────────────────────────────────────────────────
const ALARMING = ['war', 'attack', 'crash', 'crisis', 'explosion', 'killed', 'dead',
    'disaster', 'breach', 'hack', 'ban', 'collapse', 'emergency', 'threat', 'bomb', 'terror'];
const POSITIVE = ['breakthrough', 'launch', 'record', 'growth', 'success', 'win', 'innovation',
    'discovers', 'cures', 'saves', 'milestone', 'award', 'profit', 'surge', 'advance'];
function detectSentiment(title, redditComments, redditScore) {
    const lower = title.toLowerCase();
    if (ALARMING.some(k => lower.includes(k)))
        return 'alarming';
    const debateRatio = redditScore > 0 ? redditComments / redditScore : 0;
    if (debateRatio > 0.4 && redditComments > 30)
        return 'controversial';
    if (POSITIVE.some(k => lower.includes(k)))
        return 'positive';
    return 'neutral';
}
// ─── Category detection ───────────────────────────────────────────────────────
const TECH_KW = ['ai', 'software', 'tech', 'openai', 'google', 'apple', 'api', 'chip', 'cyber', 'quantum', 'developer', 'startup'];
const POL_KW = ['war', 'nato', 'sanction', 'election', 'minister', 'military', 'president', 'embassy', 'conflict', 'senate', 'government', 'policy', 'laws'];
const HEALTH_KW = ['vaccine', 'cancer', 'drug', 'fda', 'pandemic', 'virus', 'treatment', 'hospital', 'health', 'medical', 'biotech'];
const FINANCE_KW = ['stocks', 'market', 'economy', 'finance', 'fed', 'inflation', 'bank', 'bitcoin', 'crypto', 'trading', 'investing', 'revenue', 'profit'];
const SCIENCE_KW = ['space', 'astronomy', 'physics', 'dna', 'science', 'nature', 'mars', 'nasa', 'astrophysics', 'evolution', 'archaeology'];
const BREAKTHROUGH_KW = ['breakthrough', 'discovery', 'innovation', 'revolutionary', 'pioneering', 'milestone', 'new evidence'];
function detectCategory(title, sources) {
    const lower = title.toLowerCase();
    // Check for high-impact breakthroughs first
    if (BREAKTHROUGH_KW.some(k => lower.includes(k)))
        return 'Breakthrough';
    if (sources.includes('Hacker News') || TECH_KW.some(k => lower.includes(k)))
        return 'Technology';
    if (POL_KW.some(k => lower.includes(k)))
        return 'Politics';
    if (HEALTH_KW.some(k => lower.includes(k)))
        return 'Health';
    if (FINANCE_KW.some(k => lower.includes(k)))
        return 'Finance';
    if (SCIENCE_KW.some(k => lower.includes(k)))
        return 'Science';
    return 'General';
}
// ─── Title similarity for deduplication ──────────────────────────────────────
function meaningfulWords(title) {
    return new Set(title.toLowerCase().replace(/[^a-z0-9\s]/g, '').split(/\s+/).filter(w => w.length > 3));
}
function isSimilar(a, b) {
    const wa = meaningfulWords(a), wb = meaningfulWords(b);
    let overlap = 0;
    wa.forEach(w => { if (wb.has(w))
        overlap++; });
    return overlap >= 3;
}
// ─── Match Reddit posts to news articles ─────────────────────────────────────
function matchRedditToArticles(articles, redditPosts) {
    // Returns: articleLink → reddit score
    const scoreMap = new Map();
    for (const article of articles) {
        let bestScore = 0;
        for (const post of redditPosts) {
            // Direct URL match
            if (post.url === article.link) {
                bestScore = Math.max(bestScore, post.score);
                continue;
            }
            // Title similarity match
            if (isSimilar(post.title, article.title)) {
                bestScore = Math.max(bestScore, Math.floor(post.score * 0.7));
            }
        }
        if (bestScore > 0)
            scoreMap.set(article.link, bestScore);
    }
    return scoreMap;
}
// ─── Core weighted scoring formula ───────────────────────────────────────────
function computeVelocityScore(params) {
    const { googleTrendsScore, redditScore, hnPoints, ageHours, sourceCount } = params;
    // Normalize reddit: 10k upvotes = 40 points on our scale
    const redditNorm = Math.min(40, (redditScore / 250));
    // Normalize HN: 500 HN points = 25 on our scale
    const hnNorm = Math.min(25, (hnPoints / 20));
    // Source count bonus: cross-platform = more trustworthy
    const sourceBonus = Math.min(15, sourceCount * 5);
    // Recency decay: 2-hour half-life
    const recency = Math.exp(-0.347 * ageHours) * 20;
    // Weighted sum — Google Trends is the strongest signal
    const raw = (googleTrendsScore * 1.2) + // max 60
        redditNorm + // max 40
        hnNorm + // max 25
        sourceBonus + // max 15
        recency; // max 20
    // Normalize to 0–100
    return Math.min(100, Math.round((raw / 160) * 100));
}
// ─── Main aggregation function ────────────────────────────────────────────────
const getTrendingNews = async (limit = 20, countryCode = 'US') => {
    const cacheKey = `trending_${countryCode}_${limit}`;
    const cached = trendingCache.get(cacheKey);
    if (cached)
        return cached;
    console.log(`🔍 [TrendEngine] Aggregating signals for ${countryCode}...`);
    // ── Fetch all signals in parallel ─────────────────────────────────────────
    const [googleTrends, redditPosts, hnStories, guardianStories, worldStories, breakingStories] = await Promise.allSettled([
        (0, googleTrendsService_1.getGoogleTrends)(countryCode),
        (0, redditService_1.getRedditHotPosts)((0, redditService_1.getSubredditsForCountry)(countryCode), 30),
        fetchHackerNewsTop(),
        fetchGuardianTop(),
        (0, newsService_1.getWorldNews)('general', countryCode.toLowerCase()),
        (0, breakingNewsService_1.getBreakingNews)(), // ← BBC / Reuters / AP / Al Jazeera — updates every 1-5 min
    ]);
    const trends = googleTrends.status === 'fulfilled' ? googleTrends.value : [];
    const reddit = redditPosts.status === 'fulfilled' ? redditPosts.value : [];
    const pool = [];
    // Reddit posts as articles (they link to real articles)
    for (const post of reddit) {
        pool.push({
            item: {
                title: post.title,
                link: post.url,
                pubDate: new Date(post.createdUtc * 1000).toISOString(),
                content: `${post.score} upvotes · ${post.numComments} comments on r/${post.subreddit}`,
                contentSnippet: `r/${post.subreddit} · ${post.score} upvotes`,
                source: `r/${post.subreddit}`,
                imageUrl: undefined,
                author: undefined,
            },
            source: 'Reddit',
            hnPoints: 0,
            hnComments: post.numComments,
        });
    }
    // Hacker News
    if (hnStories.status === 'fulfilled') {
        for (const s of hnStories.value) {
            pool.push({ item: s.item, source: 'Hacker News', hnPoints: s.points, hnComments: s.comments });
        }
    }
    // The Guardian
    if (guardianStories.status === 'fulfilled') {
        for (const item of guardianStories.value) {
            pool.push({ item, source: 'The Guardian', hnPoints: 0, hnComments: 0 });
        }
    }
    // NewsData (country-specific articles)
    if (worldStories.status === 'fulfilled') {
        for (const item of worldStories.value) {
            pool.push({ item, source: 'NewsData', hnPoints: 0, hnComments: 0 });
        }
    }
    // ⚡ Breaking News (BBC/Reuters/AP/Al Jazeera — freshest possible)
    if (breakingStories.status === 'fulfilled') {
        for (const item of breakingStories.value) {
            pool.push({ item, source: item.source, hnPoints: 0, hnComments: 0 });
        }
    }
    // Reddit upvote map for articles that Reddit linked to
    const redditScoreMap = matchRedditToArticles(pool.map(p => p.item), reddit);
    // ── Drop stale articles (older than MAX_AGE_HOURS) ────────────────────────
    const cutoffMs = Date.now() - MAX_AGE_HOURS * 3600000;
    const freshPool = pool.filter(raw => {
        const pubMs = new Date(raw.item.pubDate).getTime();
        if (isNaN(pubMs))
            return false; // no parseable date → exclude
        return pubMs >= cutoffMs; // keep only fresh articles
    });
    console.log(`🗓️  [TrendEngine] ${pool.length} articles → ${freshPool.length} fresh (≤${MAX_AGE_HOURS}h old)`);
    // ── Deduplicate by title, merge sources ───────────────────────────────────
    const merged = [];
    for (const raw of freshPool) {
        const existing = merged.find(m => isSimilar(m.item.title, raw.item.title));
        if (existing) {
            if (!existing.sources.includes(raw.source))
                existing.sources.push(raw.source);
            existing.hnPoints = Math.max(existing.hnPoints, raw.hnPoints);
        }
        else {
            const gScore = (0, googleTrendsService_1.scoreTitleAgainstTrends)(raw.item.title, trends);
            const rScore = redditScoreMap.get(raw.item.link) ?? 0;
            merged.push({ ...raw, sources: [raw.source], redditScore: rScore, googleTrendsScore: gScore });
        }
    }
    // ── Score every story ─────────────────────────────────────────────────────
    const now = Date.now();
    const scored = merged.map(m => {
        const pubMs = new Date(m.item.pubDate).getTime();
        const ageHours = isNaN(pubMs) ? 24 : (now - pubMs) / 3600000;
        const velocity = computeVelocityScore({
            googleTrendsScore: m.googleTrendsScore,
            redditScore: m.redditScore,
            hnPoints: m.hnPoints,
            ageHours,
            sourceCount: m.sources.length,
        });
        const id = Buffer.from(m.item.link || m.item.title).toString('base64').substring(0, 16);
        return {
            id,
            title: m.item.title,
            link: m.item.link,
            sources: m.sources,
            category: detectCategory(m.item.title, m.sources),
            sentiment: detectSentiment(m.item.title, m.hnComments, m.redditScore),
            velocityScore: velocity,
            points: m.hnPoints + m.redditScore,
            googleTrendsScore: m.googleTrendsScore,
            redditScore: m.redditScore,
            pubDate: m.item.pubDate,
            imageUrl: m.item.imageUrl,
            author: m.item.author,
        };
    });
    // Sort by velocity descending, then take top N
    const sorted = scored
        .sort((a, b) => b.velocityScore - a.velocityScore)
        .slice(0, limit);
    if (sorted.length > 0)
        trendingCache.set(cacheKey, sorted);
    const topKeyword = trends[0]?.keyword ?? 'none';
    console.log(`✅ [TrendEngine] ${sorted.length} stories | top Google Trend: "${topKeyword}" | top story velocity: ${sorted[0]?.velocityScore}`);
    return sorted;
};
exports.getTrendingNews = getTrendingNews;
// ─── Source fetchers ──────────────────────────────────────────────────────────
async function fetchHackerNewsTop() {
    const controller = new AbortController();
    setTimeout(() => controller.abort(), 5000);
    // Only fetch stories published in the last 48 hours
    const cutoffSec = Math.floor((Date.now() - MAX_AGE_HOURS * 3600000) / 1000);
    const response = await fetch(`https://hn.algolia.com/api/v1/search_by_date?tags=story&hitsPerPage=30&numericFilters=points>30,created_at_i>${cutoffSec}`, { signal: controller.signal });
    const data = await response.json();
    return (data.hits ?? [])
        .filter((h) => h.url && h.title)
        .map((h) => ({
        item: {
            title: h.title, link: h.url,
            pubDate: h.created_at, content: `${h.points} HN points`,
            contentSnippet: `${h.points} HN points`, source: 'Hacker News',
            imageUrl: undefined, author: h.author,
        },
        points: h.points ?? 0, comments: h.num_comments ?? 0,
    }));
}
async function fetchGuardianTop() {
    const controller = new AbortController();
    setTimeout(() => controller.abort(), 5000);
    // Only fetch articles from the last 48 hours
    const fromDate = new Date(Date.now() - MAX_AGE_HOURS * 3600000).toISOString().split('T')[0];
    const url = `https://content.guardianapis.com/search?api-key=test&section=world|technology|politics&show-fields=thumbnail,trailText,byline&order-by=newest&page-size=20&from-date=${fromDate}`;
    const response = await fetch(url, { signal: controller.signal });
    const data = await response.json();
    return (data.response?.results ?? []).map((a) => ({
        title: a.webTitle, link: a.webUrl, pubDate: a.webPublicationDate,
        content: a.fields?.trailText ?? '', contentSnippet: a.fields?.trailText ?? '',
        source: 'The Guardian', imageUrl: a.fields?.thumbnail, author: a.fields?.byline,
    }));
}
