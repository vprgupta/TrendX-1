"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateEnv = void 0;
const joi_1 = __importDefault(require("joi"));
const logger_1 = __importDefault(require("../utils/logger"));
const validateEnv = () => {
    const envSchema = joi_1.default.object({
        NODE_ENV: joi_1.default.string().valid('development', 'test', 'production').default('development'),
        PORT: joi_1.default.number().default(3000),
        MONGODB_URI: joi_1.default.string().required(),
        JWT_SECRET: joi_1.default.string().required(),
        JWT_EXPIRE: joi_1.default.string().default('7d'),
        // Social Media Keys (Required in production)
        YOUTUBE_API_KEY: joi_1.default.string().when('NODE_ENV', {
            is: 'production',
            then: joi_1.default.required(),
            otherwise: joi_1.default.optional()
        }),
        TWITTER_BEARER_TOKEN: joi_1.default.string().optional(),
        NEWS_API_KEY: joi_1.default.string().optional(),
        RAPIDAPI_KEY: joi_1.default.string().optional()
    }).unknown();
    const { error, value } = envSchema.validate(process.env);
    if (error) {
        logger_1.default.error(`Config validation error: ${error.message}`);
        if (process.env.NODE_ENV === 'production') {
            throw new Error(`Config validation error: ${error.message}`);
        }
    }
    return value;
};
exports.validateEnv = validateEnv;
