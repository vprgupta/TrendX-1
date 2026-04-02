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
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importStar(require("mongoose"));
const trendSchema = new mongoose_1.Schema({
    platform: { type: String, required: true, index: true },
    title: { type: String, required: true, index: true },
    content: String,
    author: String,
    country: { type: String, default: 'global', index: true },
    category: { type: String, default: 'general', index: true },
    videoId: String,
    mediaUrl: String,
    imageUrl: String,
    url: String,
    externalUrl: String,
    rank: Number,
    sentiment: { type: String, enum: ['positive', 'negative', 'neutral'], default: 'neutral' },
    status: { type: String, enum: ['active', 'inactive', 'pending'], default: 'active' },
    isActive: { type: Boolean, default: true },
    metrics: {
        views: { type: Number, default: 0 },
        likes: { type: Number, default: 0 },
        shares: { type: Number, default: 0 },
        comments: { type: Number, default: 0 },
        engagement: { type: Number, default: 0 }
    },
    publishedAt: { type: Date, default: Date.now },
    // Trending scores
    trendingScore: { type: Number, default: 0, index: true },
    velocityScore: Number,
    recencyScore: Number,
    viralityScore: Number,
    engagementScore: Number,
    // Cross-platform data
    platforms: [String],
    platformCount: Number,
    globalScore: { type: Number, index: true },
    aggregatedMetrics: {
        views: Number,
        likes: Number,
        comments: Number,
        shares: Number
    },
    // Keep backward compatibility
    likes: { type: Number, default: 0 },
    comments: { type: Number, default: 0 },
    shares: { type: Number, default: 0 }
}, { timestamps: true });
// Indexes for performance
trendSchema.index({ trendingScore: -1, createdAt: -1 });
trendSchema.index({ platform: 1, trendingScore: -1 });
trendSchema.index({ category: 1, trendingScore: -1 });
trendSchema.index({ country: 1, trendingScore: -1 });
trendSchema.index({ globalScore: -1 });
exports.default = mongoose_1.default.model('Trend', trendSchema);
