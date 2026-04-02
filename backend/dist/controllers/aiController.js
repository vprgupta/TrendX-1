"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.explainContent = void 0;
const aiExplainerService_1 = require("../services/aiExplainerService");
const logger_1 = __importDefault(require("../utils/logger"));
const explainContent = async (req, res) => {
    try {
        const { title, content, platform, language } = req.body;
        if (!title || !content || !platform) {
            return res.status(400).json({
                success: false,
                error: 'title, content, and platform are required fields'
            });
        }
        const explanation = await (0, aiExplainerService_1.explainTrendWithGemini)(title, content, platform, language || 'English');
        res.json({
            success: true,
            explanation
        });
    }
    catch (error) {
        logger_1.default.error('Error generating AI explanation', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to generate explanation. Check backend logs'
        });
    }
};
exports.explainContent = explainContent;
