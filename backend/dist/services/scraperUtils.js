"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.cleanText = exports.fetchHtml = void 0;
const axios_1 = __importDefault(require("axios"));
const cheerio_1 = require("cheerio");
const fetchHtml = async (url) => {
    try {
        const response = await axios_1.default.get(url, {
            headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5'
            },
            timeout: 10000
        });
        return (0, cheerio_1.load)(response.data);
    }
    catch (error) {
        console.error(`Error fetching URL ${url}:`, error instanceof Error ? error.message : String(error));
        return null;
    }
};
exports.fetchHtml = fetchHtml;
const cleanText = (text) => {
    return text.replace(/\s+/g, ' ').trim();
};
exports.cleanText = cleanText;
