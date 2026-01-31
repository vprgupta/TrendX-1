import axios from 'axios';
import { load } from 'cheerio';

export const fetchHtml = async (url: string): Promise<any | null> => {
  try {
    const response = await axios.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5'
      },
      timeout: 10000
    });
    return load(response.data);
  } catch (error) {
    console.error(`Error fetching URL ${url}:`, error instanceof Error ? error.message : String(error));
    return null;
  }
};

export const cleanText = (text: string): string => {
  return text.replace(/\s+/g, ' ').trim();
};
