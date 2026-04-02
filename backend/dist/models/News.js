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
const newsSchema = new mongoose_1.Schema({
    title: {
        type: String,
        required: true,
        index: true
    },
    link: {
        type: String,
        required: true,
        unique: true
    },
    content: String,
    contentSnippet: String,
    source: {
        type: String,
        required: true,
        index: true
    },
    category: {
        type: String,
        required: true,
        index: true,
        default: 'general'
    },
    country: {
        type: String,
        required: true,
        index: true,
        default: 'US'
    },
    imageUrl: String,
    author: String,
    authorAvatarUrl: String,
    publishedAt: {
        type: Date,
        default: Date.now,
        index: true
    },
    metrics: {
        likes: { type: Number, default: 0 },
        comments: { type: Number, default: 0 },
        shares: { type: Number, default: 0 },
        views: { type: Number, default: 0 }
    },
    sentiment: {
        type: String,
        enum: ['positive', 'negative', 'neutral'],
        default: 'neutral'
    },
    isTrending: {
        type: Boolean,
        default: false,
        index: true
    },
    trendingScore: {
        type: Number,
        default: 0,
        index: true
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, { timestamps: true });
// Compound indexes for performance
newsSchema.index({ category: 1, country: 1, publishedAt: -1 });
newsSchema.index({ isTrending: 1, trendingScore: -1 });
newsSchema.index({ category: 1, trendingScore: -1 });
exports.default = mongoose_1.default.model('News', newsSchema);
