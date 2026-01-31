import mongoose, { Document } from 'mongoose';

interface IUserInteraction extends Document {
  userId: mongoose.Types.ObjectId;
  trendId: mongoose.Types.ObjectId;
  type: 'view' | 'like' | 'bookmark' | 'share';
  timestamp: Date;
}

const userInteractionSchema = new mongoose.Schema<IUserInteraction>({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  trendId: { type: mongoose.Schema.Types.ObjectId, ref: 'Trend', required: true },
  type: { type: String, enum: ['view', 'like', 'bookmark', 'share'], required: true },
  timestamp: { type: Date, default: Date.now }
}, { timestamps: true });

export default mongoose.model<IUserInteraction>('UserInteraction', userInteractionSchema);
export { IUserInteraction };