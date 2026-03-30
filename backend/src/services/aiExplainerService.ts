import axios from 'axios';
import logger from '../utils/logger';

const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

export const explainTrendWithGemini = async (
  title: string,
  content: string,
  platform: string,
  language: string = 'English'
): Promise<string> => {
  try {
    const apiKey = process.env.GEMINI_API_KEY;
    
    if (!apiKey) {
      logger.warn('GEMINI_API_KEY is not defined in environment variables. Falling back to default explanation.');
      return getFallbackExplanation(title, content, platform);
    }

    const payload = {
      contents: [{
        parts: [{
          text: `You are an expert news analyst. Use your real-time search capabilities to find the latest context regarding the following ${platform} trend. Then, provide a single, complete explanation in ${language}.\n\nYour entire response must be approximately 50 words long. It should read like a highly optimized, complete news snippet containing the full story: "Who, what, when, where, and why it matters." Do not use any headings or bullet points.\n\nTitle: "${title}"\nContent: "${content}"`
        }]
      }],
      tools: [{
        googleSearch: {}
      }],
      generationConfig: {
        maxOutputTokens: 150,
        temperature: 0.5
      }
    };

    const response = await axios.post(`${GEMINI_API_URL}?key=${apiKey}`, payload, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 10000 // 10 seconds
    });

    if (response.data?.candidates?.[0]?.content?.parts?.[0]?.text) {
      return response.data.candidates[0].content.parts[0].text.trim();
    } else {
      logger.error('Invalid Gemini API response format', response.data);
      throw new Error('Invalid response from Gemini');
    }

  } catch (error: any) {
    logger.error('Gemini API Error in backend:', error.message);
    return getFallbackExplanation(title, content, platform);
  }
};

const getFallbackExplanation = (title: string, content: string, platform: string): string => {
  return `This trending ${platform} post "${title}" has gained significant attention due to its relevance and engagement with users. The content resonates with current interests, spreading through platform algorithms, user shares, and viral mechanisms. It reflects timely topics that the community finds valuable and entertaining.`;
};
