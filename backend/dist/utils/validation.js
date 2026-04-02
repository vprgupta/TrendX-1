"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.interactionSchema = exports.updateProfileSchema = exports.trendSchema = exports.loginSchema = exports.registerSchema = void 0;
const joi_1 = __importDefault(require("joi"));
exports.registerSchema = joi_1.default.object({
    email: joi_1.default.string().email().required(),
    password: joi_1.default.string().min(6).required(),
    name: joi_1.default.string().min(2).max(50).required()
});
exports.loginSchema = joi_1.default.object({
    email: joi_1.default.string().email().required(),
    password: joi_1.default.string().required()
});
exports.trendSchema = joi_1.default.object({
    title: joi_1.default.string().required(),
    content: joi_1.default.string().required(),
    platform: joi_1.default.string().valid('youtube', 'twitter', 'reddit', 'news').required(),
    category: joi_1.default.string().required(),
    country: joi_1.default.string().default('global')
});
exports.updateProfileSchema = joi_1.default.object({
    name: joi_1.default.string().min(2).max(50),
    preferences: joi_1.default.object({
        platforms: joi_1.default.array().items(joi_1.default.string().valid('youtube', 'twitter', 'reddit', 'news')),
        categories: joi_1.default.array().items(joi_1.default.string()),
        countries: joi_1.default.array().items(joi_1.default.string())
    })
});
exports.interactionSchema = joi_1.default.object({
    trendId: joi_1.default.string().required(),
    type: joi_1.default.string().valid('view', 'like', 'save', 'share').required()
});
