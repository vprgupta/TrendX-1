import joi from 'joi';
import logger from '../utils/logger';

export const validateEnv = () => {
    const envSchema = joi.object({
        NODE_ENV: joi.string().valid('development', 'test', 'production').default('development'),
        PORT: joi.number().default(3000),
        MONGODB_URI: joi.string().required(),
        JWT_SECRET: joi.string().required(),
        JWT_EXPIRE: joi.string().default('7d'),

        // Social Media Keys (Required in production)
        YOUTUBE_API_KEY: joi.string().when('NODE_ENV', {
            is: 'production',
            then: joi.required(),
            otherwise: joi.optional()
        }),
        TWITTER_BEARER_TOKEN: joi.string().optional(),
        NEWS_API_KEY: joi.string().optional(),
        RAPIDAPI_KEY: joi.string().optional()
    }).unknown();

    const { error, value } = envSchema.validate(process.env);

    if (error) {
        logger.error(`Config validation error: ${error.message}`);
        if (process.env.NODE_ENV === 'production') {
            throw new Error(`Config validation error: ${error.message}`);
        }
    }

    return value;
};
