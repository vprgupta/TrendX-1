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

    const NEWS_API_KEY = process.env.NEWS_API_KEY;
    let newsItems: NewsItem[] = [];

    // Try NewsAPI first if key is available
    if (NEWS_API_KEY) {
        try {
            const apiCategory = mapCategoryToNewsAPI(category);
            const response = await axios.get('https://newsapi.org/v2/top-headlines', {
                params: {
                    apiKey: NEWS_API_KEY,
                    country: country.toLowerCase(),
                    category: apiCategory,
                    pageSize: 20
                }
            });

            if (response.data.articles) {
                newsItems = response.data.articles.map((article: any) => ({
                    title: article.title || 'No title',
                    link: article.url || '#',
                    pubDate: article.publishedAt || new Date().toISOString(),
                    content: article.content || article.description || '',
                    contentSnippet: article.description || '',
                    source: article.source.name || 'News',
                    imageUrl: article.urlToImage,
                    author: article.author
                }));
            }
        } catch (error) {
            console.error('NewsAPI error, falling back to RSS:', error);
        }
    }

    // Fallback to Google News RSS if NewsAPI failed or returned nothing
    if (newsItems.length === 0) {
        newsItems = await getGoogleNewsRSS(category, country);
    }

    if (newsItems.length > 0) {
        newsCache.set(cacheKey, newsItems);
    }

    return newsItems;
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

        const newsItems = feed.items.slice(0, 20).map(item => ({
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
 * Legacy getNews function for backwards compatibility
 */
export const getNews = async (category: string = 'world', country: string = 'US'): Promise<NewsItem[]> => {
    if (category.toLowerCase() === 'country') {
        return getGoogleNewsRSS('general', country);
    } else if (category.toLowerCase() === 'technology') {
        return getTechNews('AI'); // Default tech category
    } else {
        return getWorldNews(category, country);
    }
};

/**
 * Google News RSS fallback
 */
const getGoogleNewsRSS = async (category: string, country: string): Promise<NewsItem[]> => {
    const cacheKey = `rss_${category}_${country}`;
    const cachedData = newsCache.get<NewsItem[]>(cacheKey);
    // Note: getWorldNews calls this, so it might check cache twice if not careful, 
    // but getGoogleNewsRSS is also called directly for 'country' news.
    if (cachedData) {
        return cachedData;
    }

    let feedUrl = '';

    const countryFeeds: Record<string, string> = {
        'US': 'https://news.google.com/rss?hl=en-US&gl=US&ceid=US:en',
        'IN': 'https://news.google.com/rss?hl=en-IN&gl=IN&ceid=IN:en',
        'UK': 'https://news.google.com/rss?hl=en-GB&gl=GB&ceid=GB:en',
        'CA': 'https://news.google.com/rss?hl=en-CA&gl=CA&ceid=CA:en',
        'AU': 'https://news.google.com/rss?hl=en-AU&gl=AU&ceid=AU:en',
        'JP': 'https://news.google.com/rss?hl=en-JP&gl=JP&ceid=JP:en',
        'DE': 'https://news.google.com/rss?hl=en-DE&gl=DE&ceid=DE:en',
        'FR': 'https://news.google.com/rss?hl=en-FR&gl=FR&ceid=FR:en',
        'BR': 'https://news.google.com/rss?hl=en-BR&gl=BR&ceid=BR:en'
    };

    const topicFeeds: Record<string, string> = {
        'Science': 'SCIENCE',
        'Health': 'HEALTH',
        'Sports': 'SPORTS',
        'Entertainment': 'ENTERTAINMENT',
        'Technology': 'TECHNOLOGY'
    };

    if (category === 'general') {
        feedUrl = countryFeeds[country.toUpperCase()] || countryFeeds['US'];
    } else if (topicFeeds[category]) {
        feedUrl = `https://news.google.com/rss/headlines/section/topic/${topicFeeds[category]}?hl=en-${country}&gl=${country}&ceid=${country}:en`;
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
 * Map category names to NewsAPI categories
 */
const mapCategoryToNewsAPI = (category: string): string => {
    const mapping: Record<string, string> = {
        'Science': 'science',
        'Health': 'health',
        'Sports': 'sports',
        'Entertainment': 'entertainment',
        'Politics': 'general',
        'Environment': 'science',
        'Agriculture': 'general',
        'Space': 'science',
        'Art': 'entertainment'
    };
    return mapping[category] || 'general';
};

/**
 * Extract image URL from HTML content
 */
const extractImageFromContent = (content?: string): string | undefined => {
    if (!content) return undefined;
    const imgMatch = content.match(/<img[^>]+src="([^">]+)"/);
    return imgMatch ? imgMatch[1] : undefined;
};
