"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.explainTrendWithGemini = void 0;
const axios_1 = __importDefault(require("axios"));
const logger_1 = __importDefault(require("../utils/logger"));
const GEMINI_API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
const explainTrendWithGemini = async (title, content, platform, language = 'English') => {
    try {
        const apiKey = process.env.GEMINI_API_KEY;
        if (!apiKey) {
            logger_1.default.warn('GEMINI_API_KEY is not defined in environment variables. Falling back to default explanation.');
            return getFallbackExplanation(title, content, platform);
        }
        const payload = {
            contents: [{
                    parts: [{
                            text: `You are an expert news analyst. Based on the following ${platform} trend, provide a single, complete explanation in ${language}.\n\nYour entire response must be approximately 50 words long. It should read like a highly optimized, complete news snippet containing the full story: "Who, what, when, where, and why it matters." Do not use any headings or bullet points.\n\nTitle: "${title}"\nContent: "${content}"`
                        }]
                }],
            generationConfig: {
                maxOutputTokens: 800,
                temperature: 0.5
            }
        };
        const response = await axios_1.default.post(`${GEMINI_API_URL}?key=${apiKey}`, payload, {
            headers: { 'Content-Type': 'application/json' },
            timeout: 30000 // Increased to 30 seconds for LLM generation
        });
        if (response.data?.candidates?.[0]?.content?.parts?.[0]?.text) {
            return response.data.candidates[0].content.parts[0].text.trim();
        }
        else {
            logger_1.default.error('Invalid Gemini API response format', response.data);
            throw new Error('Invalid response from Gemini');
        }
    }
    catch (error) {
        const errorMessage = error.response?.data?.error?.message || error.message;
        logger_1.default.error('Gemini API Error in backend:', errorMessage);
        return getFallbackExplanation(title, content, platform, errorMessage);
    }
};
exports.explainTrendWithGemini = explainTrendWithGemini;
const getFallbackExplanation = (title, content, platform, error) => {
    const base = `This trending ${platform} post "${title}" has gained significant attention due to its relevance and engagement with users. The content resonates with current interests, spreading through platform algorithms, user shares, and viral mechanisms. It reflects timely topics that the community finds valuable and entertaining.`;
    if (error) {
        return `${base}\n\n[DEBUG ERROR: ${error}]`;
    }
    return base;
};
