import express from 'express';
import * as userController from '../controllers/userController';
import * as avatarController from '../controllers/avatarController';
import { authenticate } from '../middleware/auth';

const router = express.Router();

// All user routes require authentication
router.use(authenticate);

// Profile routes (standard)
router.get('/profile', userController.getProfile);
router.put('/profile', userController.updateProfile);

// Profile routes (aliased as /me for frontend compatibility)
router.get('/me', userController.getProfile);
router.put('/me', userController.updateProfile);

// Avatar upload
router.post('/me/avatar', avatarController.upload.single('avatar'), avatarController.uploadAvatar);

// Saved trends routes
router.get('/saved-trends', userController.getSavedTrends);
router.post('/saved-trends/:trendId', userController.saveTrend);
router.delete('/saved-trends/:trendId', userController.unsaveTrend);

// NEW: Comprehensive saved items routes (supports trends AND news)
const savedItemsController = require('../controllers/savedItemsController');

router.get('/me/saved', savedItemsController.getSavedItems);
router.post('/me/saved', savedItemsController.saveItem);
router.put('/me/saved/:id', savedItemsController.updateSavedItem);
router.delete('/me/saved/:id', savedItemsController.unsaveItem);
router.get('/me/saved/categories', savedItemsController.getSavedCategories);
router.get('/me/saved/stats', savedItemsController.getSavedStats);

// Legacy: Keep old routes for backward compatibility
router.get('/me/saved-trends', userController.getSavedTrends);
router.post('/me/saved-trends/:trendId', userController.saveTrend);
router.delete('/me/saved-trends/:trendId', userController.unsaveTrend);

// Interactions and preferences
router.post('/interactions', userController.trackInteraction);
router.get('/preferences', userController.getPreferences);
router.put('/preferences', userController.updatePreferences);

export default router;