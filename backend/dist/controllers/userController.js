"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPreferences = exports.updatePreferences = exports.trackInteraction = exports.unsaveTrend = exports.saveTrend = exports.getSavedTrends = exports.updateProfile = exports.getProfile = void 0;
const User_1 = __importDefault(require("../models/User"));
const Trend_1 = __importDefault(require("../models/Trend"));
const UserInteraction_1 = __importDefault(require("../models/UserInteraction"));
const getProfile = async (req, res) => {
    const user = await User_1.default.findById(req.user?._id).select('-password').populate('savedTrends');
    res.json(user);
};
exports.getProfile = getProfile;
const updateProfile = async (req, res) => {
    const { name, bio, avatar, preferences } = req.body;
    const updateData = {};
    if (name !== undefined)
        updateData.name = name;
    if (bio !== undefined)
        updateData.bio = bio;
    if (avatar !== undefined)
        updateData.avatar = avatar;
    if (preferences !== undefined)
        updateData.preferences = preferences;
    const user = await User_1.default.findByIdAndUpdate(req.user?._id, updateData, { new: true }).select('-password');
    res.json({ message: 'Profile updated', user });
};
exports.updateProfile = updateProfile;
const getSavedTrends = async (req, res) => {
    const user = await User_1.default.findById(req.user?._id).populate('savedTrends');
    res.json({ savedTrends: user?.savedTrends || [] });
};
exports.getSavedTrends = getSavedTrends;
const saveTrend = async (req, res) => {
    const { trendId } = req.params;
    const trend = await Trend_1.default.findById(trendId);
    if (!trend) {
        return res.status(404).json({ error: 'Trend not found' });
    }
    await User_1.default.findByIdAndUpdate(req.user?._id, {
        $addToSet: { savedTrends: trendId }
    });
    // Track interaction
    await UserInteraction_1.default.create({
        userId: req.user?._id,
        trendId,
        type: 'save'
    });
    res.json({ message: 'Trend saved' });
};
exports.saveTrend = saveTrend;
const unsaveTrend = async (req, res) => {
    const { trendId } = req.params;
    await User_1.default.findByIdAndUpdate(req.user?._id, {
        $pull: { savedTrends: trendId }
    });
    res.json({ message: 'Trend unsaved' });
};
exports.unsaveTrend = unsaveTrend;
const trackInteraction = async (req, res) => {
    const { trendId, type } = req.body;
    await UserInteraction_1.default.create({
        userId: req.user?._id,
        trendId,
        type
    });
    res.json({ message: 'Interaction tracked' });
};
exports.trackInteraction = trackInteraction;
const updatePreferences = async (req, res) => {
    const { platforms, countries, worldCategories, techCategories } = req.body;
    const user = await User_1.default.findByIdAndUpdate(req.user?._id, {
        preferences: {
            platforms: platforms || [],
            countries: countries || [],
            categories: [...(worldCategories || []), ...(techCategories || [])]
        }
    }, { new: true }).select('-password');
    res.json({ message: 'Preferences updated', preferences: user?.preferences });
};
exports.updatePreferences = updatePreferences;
const getPreferences = async (req, res) => {
    const user = await User_1.default.findById(req.user?._id).select('preferences');
    res.json({ preferences: user?.preferences || { platforms: [], countries: [], categories: [] } });
};
exports.getPreferences = getPreferences;
