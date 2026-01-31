import mongoose, { Document, Schema } from 'mongoose';

export interface ISavedItem extends Document {
    user: mongoose.Types.ObjectId;
    itemType: 'trend' | 'news';
    itemId: mongoose.Types.ObjectId;
    savedAt: Date;
    category?: string; // User's custom folder/category
    notes?: string; // User's personal notes about this item
    tags?: string[]; // User-defined tags
}

const savedItemSchema = new Schema<ISavedItem>({
    user: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    itemType: {
        type: String,
        enum: ['trend', 'news'],
        required: true
    },
    itemId: {
        type: Schema.Types.ObjectId,
        required: true,
        refPath: 'itemType' // Dynamically references either Trend or News model
    },
    savedAt: {
        type: Date,
        default: Date.now,
        index: true
    },
    category: {
        type: String,
        default: 'general'
    },
    notes: String,
    tags: [String]
}, { timestamps: true });

// Compound index for efficient queries
savedItemSchema.index({ user: 1, itemType: 1 });
savedItemSchema.index({ user: 1, savedAt: -1 });
savedItemSchema.index({ user: 1, category: 1 });

// Prevent duplicate saves
savedItemSchema.index({ user: 1, itemType: 1, itemId: 1 }, { unique: true });

export default mongoose.model<ISavedItem>('SavedItem', savedItemSchema);
