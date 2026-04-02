"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const userSessionSchema = new mongoose_1.default.Schema({
    userId: { type: mongoose_1.default.Schema.Types.ObjectId, ref: 'User', required: true },
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
exports.default = mongoose_1.default.model('UserSession', userSessionSchema);
