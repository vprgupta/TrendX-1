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
          text: `You are an expert news analyst. Analyze the following ${platform} story and provide a comprehensive, detailed explanation in ${language}.\n\nFormat your response EXACTLY like this (do NOT use markdown asterisks):\nTHE CORE STORY:\n(A detailed paragraph explaining exactly what happened, giving specific details and context.)\n\nWHY IT MATTERS:\n(A deep analysis in 1-2 paragraphs explaining the broader impact, why the internet is reacting to this, and potential consequences.)\n\nKEY CONTEXT & BACKGROUND:\n(A rich historical or factual background section so anyone completely unfamiliar with the topic can fully understand the nuances.)\n\nKeep the tone objective, highly insightful, and free of jargon.\n\nTitle: "${title}"\nContent: "${content}"`
        }]
      }],
      generationConfig: {
        maxOutputTokens: 900,
        temperature: 0.7
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
