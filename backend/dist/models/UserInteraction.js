"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mongoose_1 = __importDefault(require("mongoose"));
const userInteractionSchema = new mongoose_1.default.Schema({
    userId: { type: mongoose_1.default.Schema.Types.ObjectId, ref: 'User', required: true },
    trendId: { type: mongoose_1.default.Schema.Types.ObjectId, ref: 'Trend', required: true },
    type: { type: String, enum: ['view', 'like', 'bookmark', 'share'], required: true },
    timestamp: { type: Date, default: Date.now }
}, { timestamps: true });
exports.default = mongoose_1.default.model('UserInteraction', userInteractionSchema);
