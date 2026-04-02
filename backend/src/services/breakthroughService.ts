/**
 * breakthroughService.ts
 *
 * Pulls domain-specific RSS feeds covering real scientific discoveries and
 * technology breakthroughs. Each domain has dedicated authoritative sources.
 *
 * Cache TTL: 10 minutes — balanced between freshness and avoiding rate limits.
 * Age filter: 48 hours — gives enough content while keeping items recent.
 */

import Parser from 'rss-parser';
import NodeCache from 'node-cache';

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

// 10-minute cache — prevents hammering RSS servers on every request
const cache = new NodeCache({ stdTTL: 600 });

/** Max article age. 48 h gives solid variety while excluding truly stale content. */
const MAX_AGE_HOURS = 48;

export interface BreakthroughItem {
    domain: string;
    domainColor: string;  // hex, for the frontend
    title: string;
    link: string;
    pubDate: string;
    snippet: string;
    source: string;
    imageUrl?: string;
    author?: string;
}

// ─── Domain feed definitions ──────────────────────────────────────────────────

interface DomainDef {
    label: string;
    color: string;
    feeds: string[];
}

const DOMAINS: DomainDef[] = [
    {
        label: 'Science',
        color: '#00B4D8',
        feeds: [
            'https://www.sciencedaily.com/rss/top/science.xml',           // ScienceDaily - top science
            'https://www.sciencedaily.com/rss/top/technology.xml',         // ScienceDaily - top tech
            'https://www.nature.com/nature.rss',                           // Nature
            'https://feeds.arstechnica.com/arstechnica/science',           // Ars Technica Science
            'https://phys.org/rss-feed/breaking/',                         // Phys.org breaking
        ],
    },
    {
        label: 'AI & Technology',
        color: '#7C3AED',
        feeds: [
            'https://feeds.arstechnica.com/arstechnica/technology-lab',    // Ars Technica tech lab
            'https://www.technologyreview.com/feed/',                      // MIT Tech Review
            'https://www.wired.com/feed/rss',                              // Wired
            'https://www.theverge.com/rss/index.xml',                      // The Verge
            'https://techcrunch.com/feed/',                                // TechCrunch
        ],
    },
    {
        label: 'Health & Medicine',
        color: '#E91E8C',
        feeds: [
            'https://www.sciencedaily.com/rss/health_medicine.xml',        // ScienceDaily Health
            'https://www.medicalnewstoday.com/rss',                        // Medical News Today
            'https://rss.app/feeds/health.xml',                            // Health news
            'https://feeds.arstechnica.com/arstechnica/health',            // Ars Technica Health
            'http://feeds.bbci.co.uk/news/health/rss.xml',                 // BBC Health
        ],
    },
    {
        label: 'Space & Astronomy',
        color: '#1A237E',
        feeds: [
            'https://www.nasa.gov/rss/dyn/breaking_news.rss',              // NASA breaking news
            'https://www.space.com/feeds/all',                             // Space.com
            'https://www.sciencedaily.com/rss/space_time.xml',             // ScienceDaily Space
            'https://phys.org/rss-feed/space-news/',                       // Phys.org Space
            'https://feeds.arstechnica.com/arstechnica/space',             // Ars Technica Space
        ],
    },
    {
        label: 'Energy & Climate',
        color: '#2E7D32',
        feeds: [
            'https://www.sciencedaily.com/rss/earth_climate.xml',          // ScienceDaily Earth
            'https://www.carbonbrief.org/feed/',                           // Carbon Brief
            'https://electrek.co/feed/',                                   // Electrek (EV + green energy)
            'https://feeds.arstechnica.com/arstechnica/cars',              // Ars Technica Cars/EV
            'https://cleantechnica.com/feed/',                             // CleanTechnica
        ],
    },
    {
        label: 'Biology & Life',
        color: '#FF6F00',
        feeds: [
            'https://www.sciencedaily.com/rss/plants_animals.xml',         // ScienceDaily Biology
            'https://www.sciencedaily.com/rss/mind_brain.xml',             // ScienceDaily Brain
            'https://phys.org/rss-feed/biology/',                          // Phys.org Biology
            'https://www.livescience.com/feeds/all',                       // LiveScience
            'https://feeds.arstechnica.com/arstechnica/biology',           // Ars Technica Biology
        ],
    },
];

// ─── Helpers ──────────────────────────────────────────────────────────────────

function extractImage(item: any): string | undefined {
    // 1. media:content
    const mc = item.mediaContent;
    if (mc) {
        if (typeof mc === 'string' && mc.startsWith('http')) return mc;
        if (mc.$ && mc.$.url) return mc.$.url;
    }
    // 2. media:thumbnail
    const mt = item.mediaThumbnail;
    if (mt) {
        if (typeof mt === 'string' && mt.startsWith('http')) return mt;
        if (mt.$ && mt.$.url) return mt.$.url;
    }
    // 3. media:group > media:content
    const mg = item.mediaGroup;
    if (mg && mg['media:content']) {
        const c = mg['media:content'];
        if (c.$ && c.$.url) return c.$.url;
    }
    // 4. enclosure
    const enc = item.enclosure;
    if (enc && enc.url && (enc.type?.startsWith('image') || /\.(jpg|jpeg|png|webp|gif)/i.test(enc.url))) {
        return enc.url;
    }
    // 5. Parse img src from any text field that might carry HTML
    const htmlFields = [
        item.content,
        item.summary,
        item['content:encoded'],
        item.description,
    ];
    for (const html of htmlFields) {
        if (!html || typeof html !== 'string') continue;
        const m = html.match(/<img[^>]+src=["']([^"'\s>]+)["']/i);
        if (m && m[1] && m[1].startsWith('http')) return m[1];
    }
    return undefined;
}

function isWithinAge(pubDate: string): boolean {
    const ms = new Date(pubDate).getTime();
    if (isNaN(ms)) return false;
    return Date.now() - ms <= MAX_AGE_HOURS * 3_600_000;
}

async function fetchDomain(domain: DomainDef): Promise<BreakthroughItem[]> {
    const cacheKey = `bt_${domain.label}`;
    const hit = cache.get<BreakthroughItem[]>(cacheKey);
    if (hit) return hit;

    const results = await Promise.allSettled(
        domain.feeds.map(url => parser.parseURL(url))
    );

    const items: BreakthroughItem[] = [];

    for (const r of results) {
        if (r.status !== 'fulfilled') continue;
        const feed = r.value;

        for (const item of feed.items) {
            const pubDate = item.pubDate || item.isoDate || '';
            if (!isWithinAge(pubDate)) continue;

            items.push({
                domain: domain.label,
                domainColor: domain.color,
                title: item.title || 'Untitled',
                link: item.link || '#',
                pubDate,
                snippet: item.contentSnippet || item.summary || '',
                source: (item as any).creator || (item as any).source?.title || feed.title || domain.label,
                imageUrl: extractImage(item),
                author: (item as any).creator || (item as any).author,
            });
        }
    }

    // Sort newest first, cap per domain at 20
    items.sort((a, b) => new Date(b.pubDate).getTime() - new Date(a.pubDate).getTime());

    // Deduplicate by title
    const seen = new Set<string>();
    const deduped: BreakthroughItem[] = [];
    for (const item of items) {
        const key = item.title.toLowerCase().replace(/[^a-z0-9]/g, '').substring(0, 60);
        if (!seen.has(key)) {
            seen.add(key);
            deduped.push(item);
        }
        if (deduped.length >= 20) break;
    }

    console.log(`🔬 [Breakthrough/${domain.label}] ${deduped.length} items (≤${MAX_AGE_HOURS}h)`);
    if (deduped.length > 0) cache.set(cacheKey, deduped);
    return deduped;
}

// ─── Public API ───────────────────────────────────────────────────────────────

/**
 * Fetch all breakthrough domains in parallel.
 * Returns a flat array of BreakthroughItem[], each item has a `domain` field.
 * Results are sorted newest-first within each domain.
 */
export async function getBreakthroughs(): Promise<BreakthroughItem[]> {
    const allResults = await Promise.allSettled(
        DOMAINS.map(d => fetchDomain(d))
    );

    const all: BreakthroughItem[] = [];
    for (const r of allResults) {
        if (r.status === 'fulfilled') all.push(...r.value);
    }
    return all;
}

/**
 * Pre-warm cache on server start.  Refreshes every 10 minutes (matches TTL).
 */
export function startBreakthroughRefresher(): void {
    getBreakthroughs().catch(() => {});
    setInterval(() => {
        cache.flushAll();
        getBreakthroughs().catch(() => {});
        console.log('🔄 [Breakthrough] Cache refreshed');
    }, 10 * 60 * 1000);
}
