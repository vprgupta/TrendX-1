import mongoose, { Schema, Document } from 'mongoose';

export interface ITrend extends Document {
  title: string;
  content: string;
  platform: string;
  category: string;
  country: string;
  imageUrl?: string;
  url?: string;
  videoId?: string;
  mediaUrl?: string;
  externalUrl?: string;
  metrics: {
    views: number;
    likes: number;
    comments: number;
    shares: number;
    engagement: number;
  };
  author?: string;
  publishedAt: Date;
  createdAt: Date;
  updatedAt: Date;

  // Trending algorithm fields
  trendingScore: number;
  velocityScore?: number;
  recencyScore?: number;
  viralityScore?: number;
  engagementScore?: number;

  // Cross-platform aggregation
  platforms?: string[];
  platformCount?: number;
  globalScore?: number;
  aggregatedMetrics?: {
    views: number;
    likes: number;
    comments: number;
    shares: number;
  };

  // Legacy fields for backward compatibility
  rank?: number;
  sentiment?: string;
  status?: string;
  isActive?: boolean;
  likes?: number;
  comments?: number;
  shares?: number;
}

const trendSchema = new Schema({
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

export default mongoose.model<ITrend>('Trend', trendSchema);