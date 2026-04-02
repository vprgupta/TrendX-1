"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const userController = __importStar(require("../controllers/userController"));
const avatarController = __importStar(require("../controllers/avatarController"));
const auth_1 = require("../middleware/auth");
const router = express_1.default.Router();
// All user routes require authentication
router.use(auth_1.authenticate);
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
exports.default = router;
