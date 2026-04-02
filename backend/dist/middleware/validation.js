"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateTrend = exports.validateLogin = exports.validateRegister = void 0;
const joi_1 = __importDefault(require("joi"));
const validateRegister = (req, res, next) => {
    console.log('🔍 Validating registration request. Body:', JSON.stringify(req.body, null, 2));
    const schema = joi_1.default.object({
        email: joi_1.default.string().email().required(),
        password: joi_1.default.string().min(6).required(),
        name: joi_1.default.string().min(2).max(50).required()
    });
    const { error } = schema.validate(req.body);
    if (error) {
        console.log('❌ Validation failed:', error.details[0].message);
        return res.status(400).json({ error: error.details[0].message });
    }
    console.log('✅ Validation passed');
    next();
};
exports.validateRegister = validateRegister;
const validateLogin = (req, res, next) => {
    const schema = joi_1.default.object({
        email: joi_1.default.string().email().required(),
        password: joi_1.default.string().required()
    });
    const { error } = schema.validate(req.body);
    if (error) {
        return res.status(400).json({ error: error.details[0].message });
    }
    next();
};
exports.validateLogin = validateLogin;
const validateTrend = (req, res, next) => {
    const schema = joi_1.default.object({
        title: joi_1.default.string().min(3).max(200).required(),
        content: joi_1.default.string().max(1000),
        platform: joi_1.default.string().valid('youtube', 'twitter', 'reddit', 'news').required(),
        category: joi_1.default.string().required(),
        country: joi_1.default.string().default('global')
    });
    const { error } = schema.validate(req.body);
    if (error) {
        return res.status(400).json({ error: error.details[0].message });
    }
    next();
};
exports.validateTrend = validateTrend;
