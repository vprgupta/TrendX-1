import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';

let mongoServer: MongoMemoryServer;

export const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI;

    if (mongoUri) {
      // Always use the provided URI (local or cloud) — data persists across restarts
      await mongoose.connect(mongoUri);
      console.log(`✅ MongoDB Connected: ${mongoUri.replace(/\/\/.*@/, '//<credentials>@')}`);
    } else {
      // No URI configured — fall back to in-memory for convenience (dev only)
      console.warn('⚠️  No MONGODB_URI set — using in-memory MongoDB. Data will NOT persist!');
      mongoServer = await MongoMemoryServer.create();
      const inMemoryUri = mongoServer.getUri();
      await mongoose.connect(inMemoryUri);
      console.log('🧪 Connected to In-Memory MongoDB (ephemeral)');
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