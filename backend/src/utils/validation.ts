import Joi from 'joi';

export const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  name: Joi.string().min(2).max(50).required()
});

export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required()
});

export const trendSchema = Joi.object({
  title: Joi.string().required(),
  content: Joi.string().required(),
  platform: Joi.string().valid('youtube', 'twitter', 'reddit', 'news').required(),
  category: Joi.string().required(),
  country: Joi.string().default('global')
});

export const updateProfileSchema = Joi.object({
  name: Joi.string().min(2).max(50),
  preferences: Joi.object({
    platforms: Joi.array().items(Joi.string().valid('youtube', 'twitter', 'reddit', 'news')),
    categories: Joi.array().items(Joi.string()),
    countries: Joi.array().items(Joi.string())
  })
});

export const interactionSchema = Joi.object({
  trendId: Joi.string().required(),
  type: Joi.string().valid('view', 'like', 'save', 'share').required()
});