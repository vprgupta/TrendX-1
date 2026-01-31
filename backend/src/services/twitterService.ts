import { fetchHtml, cleanText } from './scraperUtils';
import axios from 'axios';

const TWITTER_BEARER_TOKEN = process.env.TWITTER_BEARER_TOKEN;

export const getTwitterTrends = async (country?: string) => {
  // Try Twitter API v2 if token is available
  if (TWITTER_BEARER_TOKEN) {
    try {
      const woeidMap: Record<string, string> = {
        'USA': '23424977',
        'India': '23424848',
        'UK': '23424975',
        'Japan': '23424856',
        'Canada': '23424775',
        'Germany': '23424829',
        'France': '23424819',
        'Brazil': '23424768'
      };

      const woeid = woeidMap[country || 'USA'] || '1'; // 1 = Worldwide

      const response = await axios.get(
        `https://api.twitter.com/1.1/trends/place.json?id=${woeid}`,
        {
          headers: {
            'Authorization': `Bearer ${TWITTER_BEARER_TOKEN}`
          }
        }
      );

      if (response.data && response.data[0] && response.data[0].trends) {
        return response.data[0].trends.slice(0, 20).map((trend: any) => ({
          name: trend.name,
          tweet_volume: trend.tweet_volume || 0,
          url: trend.url || `https://twitter.com/search?q=${encodeURIComponent(trend.name)}`
        }));
      }
    } catch (error) {
      console.error('Twitter API error, falling back to scraping:', error);
    }
  }

  // Fallback to scraping
  return getTwitterTrendsByScraping();
};

const getTwitterTrendsByScraping = async () => {
  try {
    const $ = await fetchHtml('https://trendogate.com/');
    if (!$) return [];

    const trends: any[] = [];
    const seen = new Set();

    $('.list-group-item').each((i: number, el: any) => {
      if (trends.length >= 10) return;

      const name = cleanText($(el).find('a').text());
      const volumeText = cleanText($(el).find('.badge').text());

      if (name && name.length > 1 && !seen.has(name)) {
        seen.add(name);
        trends.push({
          name,
          tweet_volume: parseInt(volumeText.replace(/,/g, '')) || 0,
          url: $(el).find('a').attr('href') || `https://twitter.com/search?q=${encodeURIComponent(name)}`
        });
      }
    });

    return trends;
  } catch (error) {
    console.error('Error scraping Twitter trends:', error);
    return [];
  }
};

export const getTwitterPosts = async (query: string) => {
  // Twitter scraping is hard without API, returning empty for now
  return [];
};