import { Response } from 'express';
import SavedItem from '../models/SavedItem';
import Trend from '../models/Trend';
import { AuthRequest } from '../types';

/**
 * Get all saved items for the current user
 * GET /api/users/me/saved?type=trend|news&category=general
 */
export const getSavedItems = async (req: AuthRequest, res: Response) => {
    try {
        const userId = req.user?._id;
        const { type, category } = req.query;

        const filter: any = { user: userId };
        if (type) filter.itemType = type;
        if (category) filter.category = category;

        const savedItems = await SavedItem.find(filter)
            .populate('itemId') // Populate the actual trend or news item
            .sort({ savedAt: -1 })
            .lean();

        res.json({
            savedItems,
            count: savedItems.length
        });
    } catch (error) {
        console.error('Error fetching saved items:', error);
        res.status(500).json({ error: 'Failed to fetch saved items' });
    }
};

/**
 * Save an item (trend or news)
 * POST /api/users/me/saved
 * Body: { itemType: 'trend' | 'news', itemId: string, category?: string, notes?: string, tags?: string[] }
 */
export const saveItem = async (req: AuthRequest, res: Response) => {
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
        const ItemModel = itemType === 'trend' ? Trend : require('../models/News').default;
        const item = await ItemModel.findById(itemId);
        if (!item) {
            return res.status(404).json({ error: `${itemType} not found` });
        }

        // Check if already saved
        const existing = await SavedItem.findOne({ user: userId, itemType, itemId });
        if (existing) {
            return res.status(400).json({ error: 'Item already saved' });
        }

        const savedItem = await SavedItem.create({
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
    } catch (error) {
        console.error('Error saving item:', error);
        res.status(500).json({ error: 'Failed to save item' });
    }
};

/**
 * Remove a saved item
 * DELETE /api/users/me/saved/:id
 */
export const unsaveItem = async (req: AuthRequest, res: Response) => {
    try {
        const userId = req.user?._id;
        const { id } = req.params;

        const savedItem = await SavedItem.findOneAndDelete({
            _id: id,
            user: userId
        });

        if (!savedItem) {
            return res.status(404).json({ error: 'Saved item not found' });
        }

        res.json({ message: 'Item removed from saved', savedItem });
    } catch (error) {
        console.error('Error removing saved item:', error);
        res.status(500).json({ error: 'Failed to remove saved item' });
    }
};

/**
 * Update saved item metadata (category, notes, tags)
 * PUT /api/users/me/saved/:id
 */
export const updateSavedItem = async (req: AuthRequest, res: Response) => {
    try {
        const userId = req.user?._id;
        const { id } = req.params;
        const { category, notes, tags } = req.body;

        const updateData: any = {};
        if (category !== undefined) updateData.category = category;
        if (notes !== undefined) updateData.notes = notes;
        if (tags !== undefined) updateData.tags = tags;

        const savedItem = await SavedItem.findOneAndUpdate(
            { _id: id, user: userId },
            updateData,
            { new: true }
        ).populate('itemId');

        if (!savedItem) {
            return res.status(404).json({ error: 'Saved item not found' });
        }

        res.json({
            message: 'Saved item updated',
            savedItem
        });
    } catch (error) {
        console.error('Error updating saved item:', error);
        res.status(500).json({ error: 'Failed to update saved item' });
    }
};

/**
 * Get user's saved categories
 * GET /api/users/me/saved/categories
 */
export const getSavedCategories = async (req: AuthRequest, res: Response) => {
    try {
        const userId = req.user?._id;

        const categories = await SavedItem.distinct('category', { user: userId });

        res.json({
            categories: categories.filter(c => c) // Remove null/undefined
        });
    } catch (error) {
        console.error('Error fetching categories:', error);
        res.status(500).json({ error: 'Failed to fetch categories' });
    }
};

/**
 * Get saved items count by type
 * GET /api/users/me/saved/stats
 */
export const getSavedStats = async (req: AuthRequest, res: Response) => {
    try {
        const userId = req.user?._id;

        const [totalCount, trendCount, newsCount] = await Promise.all([
            SavedItem.countDocuments({ user: userId }),
            SavedItem.countDocuments({ user: userId, itemType: 'trend' }),
            SavedItem.countDocuments({ user: userId, itemType: 'news' })
        ]);

        res.json({
            total: totalCount,
            trends: trendCount,
            news: newsCount
        });
    } catch (error) {
        console.error('Error fetching saved stats:', error);
        res.status(500).json({ error: 'Failed to fetch stats' });
    }
};
