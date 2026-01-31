import { Response } from 'express';
import User from '../models/User';
import Trend from '../models/Trend';
import UserInteraction from '../models/UserInteraction';
import { AuthRequest } from '../types';

export const getProfile = async (req: AuthRequest, res: Response) => {
  const user = await User.findById(req.user?._id).select('-password').populate('savedTrends');
  res.json(user);
};

export const updateProfile = async (req: AuthRequest, res: Response) => {
  const { name, bio, avatar, preferences } = req.body;

  const updateData: any = {};
  if (name !== undefined) updateData.name = name;
  if (bio !== undefined) updateData.bio = bio;
  if (avatar !== undefined) updateData.avatar = avatar;
  if (preferences !== undefined) updateData.preferences = preferences;

  const user = await User.findByIdAndUpdate(
    req.user?._id,
    updateData,
    { new: true }
  ).select('-password');

  res.json({ message: 'Profile updated', user });
};

export const getSavedTrends = async (req: AuthRequest, res: Response) => {
  const user = await User.findById(req.user?._id).populate('savedTrends');
  res.json({ savedTrends: user?.savedTrends || [] });
};

export const saveTrend = async (req: AuthRequest, res: Response) => {
  const { trendId } = req.params;

  const trend = await Trend.findById(trendId);
  if (!trend) {
    return res.status(404).json({ error: 'Trend not found' });
  }

  await User.findByIdAndUpdate(req.user?._id, {
    $addToSet: { savedTrends: trendId }
  });

  // Track interaction
  await UserInteraction.create({
    userId: req.user?._id,
    trendId,
    type: 'save'
  });

  res.json({ message: 'Trend saved' });
};

export const unsaveTrend = async (req: AuthRequest, res: Response) => {
  const { trendId } = req.params;

  await User.findByIdAndUpdate(req.user?._id, {
    $pull: { savedTrends: trendId }
  });

  res.json({ message: 'Trend unsaved' });
};

export const trackInteraction = async (req: AuthRequest, res: Response) => {
  const { trendId, type } = req.body;

  await UserInteraction.create({
    userId: req.user?._id,
    trendId,
    type
  });

  res.json({ message: 'Interaction tracked' });
};

export const updatePreferences = async (req: AuthRequest, res: Response) => {
  const { platforms, countries, worldCategories, techCategories } = req.body;

  const user = await User.findByIdAndUpdate(
    req.user?._id,
    {
      preferences: {
        platforms: platforms || [],
        countries: countries || [],
        categories: [...(worldCategories || []), ...(techCategories || [])]
      }
    },
    { new: true }
  ).select('-password');

  res.json({ message: 'Preferences updated', preferences: user?.preferences });
};

export const getPreferences = async (req: AuthRequest, res: Response) => {
  const user = await User.findById(req.user?._id).select('preferences');
  res.json({ preferences: user?.preferences || { platforms: [], countries: [], categories: [] } });
};