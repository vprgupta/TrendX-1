import mongoose, { Document } from 'mongoose';
import bcrypt from 'bcryptjs';

interface IUser extends Document {
  email: string;
  password: string;
  name: string;
  bio?: string;
  avatar?: string;
  role: 'user' | 'admin' | 'moderator';
  status: 'active' | 'inactive' | 'blocked';
  lastActive: Date;
  savedTrends: mongoose.Types.ObjectId[];
  preferences: {
    platforms: string[];
    countries: string[];
    categories: string[];
  };
  stats: {
    following: number;
    bookmarks: number;
    views: number;
  };
  // Authentication enhancements
  refreshToken?: string;
  emailVerified: boolean;
  emailVerificationToken?: string;
  emailVerificationExpires?: Date;
  resetPasswordToken?: string;
  resetPasswordExpires?: Date;
  comparePassword(password: string): Promise<boolean>;
}

const userSchema = new mongoose.Schema<IUser>({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name: { type: String, required: true },
  bio: { type: String, default: '' },
  avatar: { type: String, default: '' },
  role: { type: String, enum: ['user', 'admin', 'moderator'], default: 'user' },
  status: { type: String, enum: ['active', 'inactive', 'blocked'], default: 'active' },
  lastActive: { type: Date, default: Date.now },
  savedTrends: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Trend' }],
  preferences: {
    platforms: [String],
    countries: [String],
    categories: [String]
  },
  stats: {
    following: { type: Number, default: 0 },
    bookmarks: { type: Number, default: 0 },
    views: { type: Number, default: 0 }
  },
  // Authentication enhancements
  refreshToken: String,
  emailVerified: { type: Boolean, default: false },
  emailVerificationToken: String,
  emailVerificationExpires: Date,
  resetPasswordToken: String,
  resetPasswordExpires: Date
}, { timestamps: true });

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

userSchema.methods.comparePassword = async function (password: string) {
  return bcrypt.compare(password, this.password);
};

// Performance indexes
userSchema.index({ email: 1 }, { unique: true }); // Already enforced, explicit index
userSchema.index({ role: 1 });
userSchema.index({ status: 1 });
userSchema.index({ emailVerified: 1 });
userSchema.index({ emailVerificationToken: 1 });
userSchema.index({ resetPasswordToken: 1 });
userSchema.index({ refreshToken: 1 });

export default mongoose.model<IUser>('User', userSchema);