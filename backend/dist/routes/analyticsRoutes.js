"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const analyticsController_1 = require("../controllers/analyticsController");
const router = express_1.default.Router();
router.get('/overview', analyticsController_1.getAnalyticsOverview);
router.get('/sentiment', analyticsController_1.getSentimentAnalysis);
router.get('/top-trends', analyticsController_1.getTopTrends);
router.get('/chart', analyticsController_1.getTrendChartData);
exports.default = router;
