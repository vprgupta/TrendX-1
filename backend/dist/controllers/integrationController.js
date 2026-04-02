"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getIntegrationStatus = void 0;
const Trend_1 = __importDefault(require("../models/Trend"));
const getIntegrationStatus = async (req, res) => {
    try {
        const platforms = ['twitter', 'youtube', 'reddit', 'tiktok', 'instagram'];
        const status = {};
        for (const platform of platforms) {
            const count = await Trend_1.default.countDocuments({ platform });
            const lastTrend = await Trend_1.default.findOne({ platform }).sort({ createdAt: -1 });
            status[platform] = {
                connected: true, // Assuming connected if we have the service
                trendsCollected: count,
                lastUpdated: lastTrend ? lastTrend.createdAt : null,
                status: count > 0 ? 'active' : 'inactive'
            };
        }
        // News API is a placeholder for now
        status['news'] = {
            connected: false,
            trendsCollected: 0,
            lastUpdated: null,
            status: 'inactive'
        };
        res.json(status);
    }
    catch (error) {
        console.error('Error fetching integration status:', error);
        res.status(500).json({ error: 'Failed to fetch integration status' });
    }
};
exports.getIntegrationStatus = getIntegrationStatus;
