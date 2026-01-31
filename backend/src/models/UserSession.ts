import mongoose, { Document } from 'mongoose';

interface IUserSession extends Document {
  userId: mongoose.Types.ObjectId;
  sessionId: string;
  startTime: Date;
  endTime?: Date;
  duration?: number; // in seconds
  platform: string; // web, mobile, etc.
  deviceInfo: {
    userAgent?: string;
    ip?: string;
    country?: string;
    city?: string;
  };
  activities: {
    screenViews: number;
    trendsViewed: number;
    searchQueries: number;
    bookmarks: number;
    shares: number;
  };
  isActive: boolean;
}

const userSessionSchema = new mongoose.Schema<IUserSession>({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  sessionId: { type: String, required: true, unique: true },
  startTime: { type: Date, default: Date.now },
  endTime: { type: Date },
  duration: { type: Number },
  platform: { type: String, default: 'web' },
  deviceInfo: {
    userAgent: String,
    ip: String,
    country: String,
    city: String
  },
  activities: {
    screenViews: { type: Number, default: 0 },
    trendsViewed: { type: Number, default: 0 },
    searchQueries: { type: Number, default: 0 },
    bookmarks: { type: Number, default: 0 },
    shares: { type: Number, default: 0 }
  },
  isActive: { type: Boolean, default: true }
}, { timestamps: true });

export default mongoose.model<IUserSession>('UserSession', userSessionSchema);
export { IUserSession };