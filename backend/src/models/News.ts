import mongoose, { Document, Schema } from 'mongoose';

export interface INews extends Document {
    title: string;
    link: string;
    content: string;
    contentSnippet: string;
    source: string;
    category: string;
    country: string;
    imageUrl?: string;
    author?: string;
    authorAvatarUrl?: string;
    publishedAt: Date;
    metrics: {
        likes: number;
        comments: number;
        shares: number;
        views: number;
    };
    sentiment?: 'positive' | 'negative' | 'neutral';
    isTrending: boolean;
    trendingScore: number;
    isActive: boolean;
}

const newsSchema = new Schema<INews>({
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

export default mongoose.model<INews>('News', newsSchema);
