"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.morganStream = void 0;
const winston_1 = __importDefault(require("winston"));
const path_1 = __importDefault(require("path"));
const { combine, timestamp, printf, colorize, errors } = winston_1.default.format;
// Define log format
const logFormat = printf(({ level, message, timestamp, stack, ...metadata }) => {
    let msg = `${timestamp} [${level}]: ${message}`;
    // Add stack trace for errors
    if (stack) {
        msg += `\n${stack}`;
    }
    // Add metadata if present
    if (Object.keys(metadata).length > 0) {
        msg += `\n${JSON.stringify(metadata, null, 2)}`;
    }
    return msg;
});
// Create logger instance
const logger = winston_1.default.createLogger({
    level: process.env.LOG_LEVEL || 'info',
    format: combine(errors({ stack: true }), timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }), logFormat),
    transports: [
        // Console transport for all environments
        new winston_1.default.transports.Console({
            format: combine(colorize(), timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }), logFormat)
        })
    ],
    // Don't exit on uncaught errors
    exitOnError: false
});
// Add file transports in production
if (process.env.NODE_ENV === 'production') {
    const logsDir = process.env.LOGS_DIR || path_1.default.join(__dirname, '../../logs');
    // Error log file
    logger.add(new winston_1.default.transports.File({
        filename: path_1.default.join(logsDir, 'error.log'),
        level: 'error',
        maxsize: 5242880, // 5MB
        maxFiles: 5
    }));
    // Combined log file
    logger.add(new winston_1.default.transports.File({
        filename: path_1.default.join(logsDir, 'combined.log'),
        maxsize: 5242880, // 5MB
        maxFiles: 5
    }));
}
// Create a stream for Morgan HTTP logging
exports.morganStream = {
    write: (message) => {
        // Remove trailing newline
        logger.http(message.trim());
    }
};
exports.default = logger;
