import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

let mongoServer: MongoMemoryServer;

export const connectDB = async () => {
  try {
    if (process.env.NODE_ENV === 'development' && !process.env.MONGODB_URI?.includes('mongodb+srv')) {
      // Use in-memory database for development
      mongoServer = await MongoMemoryServer.create();
      const mongoUri = mongoServer.getUri();
      await mongoose.connect(mongoUri);
      console.log('✅ Connected to In-Memory MongoDB');
    } else {
      // Use provided MongoDB URI (local or cloud)
      await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/trendx');
      console.log('✅ MongoDB Connected');
    }
  } catch (error) {
    console.error('❌ MongoDB Connection Error:', error);
    process.exit(1);
  }
};

export const disconnectDB = async () => {
  try {
    await mongoose.disconnect();
    if (mongoServer) {
      await mongoServer.stop();
    }
  } catch (error) {
    console.error('Error disconnecting from database:', error);
  }
};