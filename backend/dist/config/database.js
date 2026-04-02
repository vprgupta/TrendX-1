"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.disconnectDB = exports.connectDB = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const mongodb_memory_server_1 = require("mongodb-memory-server");
let mongoServer;
const connectDB = async () => {
    try {
        const mongoUri = process.env.MONGODB_URI;
        if (mongoUri) {
            // Always use the provided URI (local or cloud) — data persists across restarts
            await mongoose_1.default.connect(mongoUri);
            console.log(`✅ MongoDB Connected: ${mongoUri.replace(/\/\/.*@/, '//<credentials>@')}`);
        }
        else {
            // No URI configured — fall back to in-memory for convenience (dev only)
            console.warn('⚠️  No MONGODB_URI set — using in-memory MongoDB. Data will NOT persist!');
            mongoServer = await mongodb_memory_server_1.MongoMemoryServer.create();
            const inMemoryUri = mongoServer.getUri();
            await mongoose_1.default.connect(inMemoryUri);
            console.log('🧪 Connected to In-Memory MongoDB (ephemeral)');
        }
    }
    catch (error) {
        console.error('❌ MongoDB Connection Error:', error);
        process.exit(1);
    }
};
exports.connectDB = connectDB;
const disconnectDB = async () => {
    try {
        await mongoose_1.default.disconnect();
        if (mongoServer) {
            await mongoServer.stop();
        }
    }
    catch (error) {
        console.error('Error disconnecting from database:', error);
    }
};
exports.disconnectDB = disconnectDB;
