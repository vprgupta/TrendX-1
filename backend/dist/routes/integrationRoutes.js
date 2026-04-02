"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const integrationController_1 = require("../controllers/integrationController");
const youtubeService_1 = require("../services/youtubeService");
const router = express_1.default.Router();
router.get('/status', integrationController_1.getIntegrationStatus);
router.get('/youtube/trending', async (req, res) => {
    try {
        const country = req.query.country || 'US';
        const category = req.query.category || '28';
        const trends = await (0, youtubeService_1.getYouTubeTrends)(country, category);
        res.json({ success: true, count: trends.length, trends });
    }
    catch (error) {
        res.status(500).json({ success: false, error: 'Failed' });
    }
});
exports.default = router;
