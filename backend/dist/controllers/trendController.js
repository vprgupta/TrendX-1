"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateTrend = exports.deleteTrend = exports.createTrend = exports.getTrendsByCategory = exports.getTrendsByCountry = exports.getTrendsByPlatform = exports.searchTrends = exports.getTrendById = exports.getTrends = void 0;
const Trend_1 = __importDefault(require("../models/Trend"));
const getTrends = async (req, res) => {
    const { platform, country, category, limit = 20, page = 1 } = req.query;
    const filter = {};
    if (platform)
        filter.platform = platform;
    if (country)
        filter.country = country;
    if (category)
        filter.category = category;
    const trends = await Trend_1.default.find(filter)
        .sort({ createdAt: -1 })
        .limit(Number(limit))
        .skip((Number(page) - 1) * Number(limit));
    const total = await Trend_1.default.countDocuments(filter);
    res.json({
        trends,
        pagination: {
            page: Number(page),
            limit: Number(limit),
            total,
            pages: Math.ceil(total / Number(limit))
        }
    });
};
exports.getTrends = getTrends;
const getTrendById = async (req, res) => {
    const trend = await Trend_1.default.findById(req.params.id);
    if (!trend) {
        return res.status(404).json({ error: 'Trend not found' });
    }
    res.json(trend);
};
exports.getTrendById = getTrendById;
const searchTrends = async (req, res) => {
    const { q, limit = 20 } = req.query;
    if (!q) {
        return res.status(400).json({ error: 'Search query required' });
    }
    const trends = await Trend_1.default.find({
        $or: [
            { title: { $regex: q, $options: 'i' } },
            { content: { $regex: q, $options: 'i' } }
        ]
    })
        .sort({ createdAt: -1 })
        .limit(Number(limit));
    res.json({ trends, count: trends.length });
};
exports.searchTrends = searchTrends;
const getTrendsByPlatform = async (req, res) => {
    const { platform } = req.params;
    const { limit = 20 } = req.query;
    const trends = await Trend_1.default.find({ platform })
        .sort({ createdAt: -1 })
        .limit(Number(limit));
    res.json({ platform, trends, count: trends.length });
};
exports.getTrendsByPlatform = getTrendsByPlatform;
const getTrendsByCountry = async (req, res) => {
    const { country } = req.params;
    const { limit = 20 } = req.query;
    const trends = await Trend_1.default.find({ country })
        .sort({ createdAt: -1 })
        .limit(Number(limit));
    res.json({ country, trends, count: trends.length });
};
exports.getTrendsByCountry = getTrendsByCountry;
const getTrendsByCategory = async (req, res) => {
    const { category } = req.params;
    const { limit = 20 } = req.query;
    const trends = await Trend_1.default.find({ category })
        .sort({ createdAt: -1 })
        .limit(Number(limit));
    res.json({ category, trends, count: trends.length });
};
exports.getTrendsByCategory = getTrendsByCategory;
const createTrend = async (req, res) => {
    const trend = await Trend_1.default.create(req.body);
    req.io?.emit('trendCreated', trend);
    res.status(201).json({ message: 'Trend created', trend });
};
exports.createTrend = createTrend;
const deleteTrend = async (req, res) => {
    try {
        const trend = await Trend_1.default.findByIdAndDelete(req.params.id);
        if (!trend) {
            return res.status(404).json({ error: 'Trend not found' });
        }
        // Emit Socket.IO event for real-time updates
        req.io?.emit('trendDeleted', { id: trend._id });
        res.json({ message: 'Trend deleted successfully', trend });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to delete trend' });
    }
};
exports.deleteTrend = deleteTrend;
const updateTrend = async (req, res) => {
    try {
        const { title, description, platform, category, country, metrics, sentiment, status } = req.body;
        const trend = await Trend_1.default.findByIdAndUpdate(req.params.id, {
            title,
            description,
            platform,
            category,
            country,
            metrics,
            sentiment,
            status,
            updatedAt: new Date()
        }, { new: true, runValidators: true });
        if (!trend) {
            return res.status(404).json({ error: 'Trend not found' });
        }
        res.json({ message: 'Trend updated successfully', trend });
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to update trend' });
    }
};
exports.updateTrend = updateTrend;
