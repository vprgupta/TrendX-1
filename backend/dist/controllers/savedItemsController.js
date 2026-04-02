"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getSavedStats = exports.getSavedCategories = exports.updateSavedItem = exports.unsaveItem = exports.saveItem = exports.getSavedItems = void 0;
const SavedItem_1 = __importDefault(require("../models/SavedItem"));
const Trend_1 = __importDefault(require("../models/Trend"));
/**
 * Get all saved items for the current user
 * GET /api/users/me/saved?type=trend|news&category=general
 */
const getSavedItems = async (req, res) => {
    try {
        const userId = req.user?._id;
        const { type, category } = req.query;
        const filter = { user: userId };
        if (type)
            filter.itemType = type;
        if (category)
            filter.category = category;
        const savedItems = await SavedItem_1.default.find(filter)
            .populate('itemId') // Populate the actual trend or news item
            .sort({ savedAt: -1 })
            .lean();
        res.json({
            savedItems,
            count: savedItems.length
        });
    }
    catch (error) {
        console.error('Error fetching saved items:', error);
        res.status(500).json({ error: 'Failed to fetch saved items' });
    }
};
exports.getSavedItems = getSavedItems;
/**
 * Save an item (trend or news)
 * POST /api/users/me/saved
 * Body: { itemType: 'trend' | 'news', itemId: string, category?: string, notes?: string, tags?: string[] }
 */
const saveItem = async (req, res) => {
    try {
        const userId = req.user?._id;
        const { itemType, itemId, category, notes, tags } = req.body;
        if (!itemType || !itemId) {
            return res.status(400).json({ error: 'itemType and itemId are required' });
        }
        if (!['trend', 'news'].includes(itemType)) {
            return res.status(400).json({ error: 'itemType must be "trend" or "news"' });
        }
        // Check if item exists
        const ItemModel = itemType === 'trend' ? Trend_1.default : require('../models/News').default;
        const item = await ItemModel.findById(itemId);
        if (!item) {
            return res.status(404).json({ error: `${itemType} not found` });
        }
        // Check if already saved
        const existing = await SavedItem_1.default.findOne({ user: userId, itemType, itemId });
        if (existing) {
            return res.status(400).json({ error: 'Item already saved' });
        }
        const savedItem = await SavedItem_1.default.create({
            user: userId,
            itemType,
            itemId,
            category: category || 'general',
            notes,
            tags
        });
        res.status(201).json({
            message: 'Item saved successfully',
            savedItem
        });
    }
    catch (error) {
        console.error('Error saving item:', error);
        res.status(500).json({ error: 'Failed to save item' });
    }
};
exports.saveItem = saveItem;
/**
 * Remove a saved item
 * DELETE /api/users/me/saved/:id
 */
const unsaveItem = async (req, res) => {
    try {
        const userId = req.user?._id;
        const { id } = req.params;
        const savedItem = await SavedItem_1.default.findOneAndDelete({
            _id: id,
            user: userId
        });
        if (!savedItem) {
            return res.status(404).json({ error: 'Saved item not found' });
        }
        res.json({ message: 'Item removed from saved', savedItem });
    }
    catch (error) {
        console.error('Error removing saved item:', error);
        res.status(500).json({ error: 'Failed to remove saved item' });
    }
};
exports.unsaveItem = unsaveItem;
/**
 * Update saved item metadata (category, notes, tags)
 * PUT /api/users/me/saved/:id
 */
const updateSavedItem = async (req, res) => {
    try {
        const userId = req.user?._id;
        const { id } = req.params;
        const { category, notes, tags } = req.body;
        const updateData = {};
        if (category !== undefined)
            updateData.category = category;
        if (notes !== undefined)
            updateData.notes = notes;
        if (tags !== undefined)
            updateData.tags = tags;
        const savedItem = await SavedItem_1.default.findOneAndUpdate({ _id: id, user: userId }, updateData, { new: true }).populate('itemId');
        if (!savedItem) {
            return res.status(404).json({ error: 'Saved item not found' });
        }
        res.json({
            message: 'Saved item updated',
            savedItem
        });
    }
    catch (error) {
        console.error('Error updating saved item:', error);
        res.status(500).json({ error: 'Failed to update saved item' });
    }
};
exports.updateSavedItem = updateSavedItem;
/**
 * Get user's saved categories
 * GET /api/users/me/saved/categories
 */
const getSavedCategories = async (req, res) => {
    try {
        const userId = req.user?._id;
        const categories = await SavedItem_1.default.distinct('category', { user: userId });
        res.json({
            categories: categories.filter(c => c) // Remove null/undefined
        });
    }
    catch (error) {
        console.error('Error fetching categories:', error);
        res.status(500).json({ error: 'Failed to fetch categories' });
    }
};
exports.getSavedCategories = getSavedCategories;
/**
 * Get saved items count by type
 * GET /api/users/me/saved/stats
 */
const getSavedStats = async (req, res) => {
    try {
        const userId = req.user?._id;
        const [totalCount, trendCount, newsCount] = await Promise.all([
            SavedItem_1.default.countDocuments({ user: userId }),
            SavedItem_1.default.countDocuments({ user: userId, itemType: 'trend' }),
            SavedItem_1.default.countDocuments({ user: userId, itemType: 'news' })
        ]);
        res.json({
            total: totalCount,
            trends: trendCount,
            news: newsCount
        });
    }
    catch (error) {
        console.error('Error fetching saved stats:', error);
        res.status(500).json({ error: 'Failed to fetch stats' });
    }
};
exports.getSavedStats = getSavedStats;
