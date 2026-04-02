"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const dotenv_1 = __importDefault(require("dotenv"));
const path_1 = __importDefault(require("path"));
const http_1 = require("http");
const socket_io_1 = require("socket.io");
require("express-async-errors");
const auth_1 = __importDefault(require("./routes/auth"));
const trends_1 = __importDefault(require("./routes/trends"));
const users_1 = __importDefault(require("./routes/users"));
const admin_1 = __importDefault(require("./routes/admin"));
const sessions_1 = __importDefault(require("./routes/sessions"));
const errorHandler_1 = require("./middleware/errorHandler");
const database_1 = require("./config/database");
const envValidator_1 = require("./config/envValidator");
const auth_2 = require("./middleware/auth");
const logger_1 = __importDefault(require("./utils/logger"));
const analyticsRoutes_1 = __importDefault(require("./routes/analyticsRoutes"));
const integrationRoutes_1 = __importDefault(require("./routes/integrationRoutes"));
const ai_1 = __importDefault(require("./routes/ai"));
const newsController = __importStar(require("./controllers/newsController"));
const trendingNewsController = __importStar(require("./controllers/trendingNewsController"));
const newsService_1 = require("./services/newsService");
const trendScheduler_1 = require("./jobs/trendScheduler");
const breakingNewsService_1 = require("./services/breakingNewsService");
const breakthroughService_1 = require("./services/breakthroughService");
dotenv_1.default.config();
(0, envValidator_1.validateEnv)();
const app = (0, express_1.default)();
const server = (0, http_1.createServer)(app);
const io = new socket_io_1.Server(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] }
});
// Middleware to pass io to routes
app.use((req, res, next) => {
    req.io = io;
    next();
});
const PORT = process.env.PORT || 3000;
// Make io available globally
app.set('io', io);
// Security middleware
app.use((0, helmet_1.default)({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: [
                "'self'",
                "'unsafe-inline'",
                "cdn.jsdelivr.net",
                "cdnjs.cloudflare.com",
                "cdn.socket.io",
            ],
            scriptSrcAttr: ["'unsafe-inline'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            connectSrc: ["'self'", "ws:", "wss:"],
            imgSrc: ["'self'", "data:", "https:"],
            fontSrc: ["'self'", "https:"],
        },
    },
}));
app.use((0, cors_1.default)());
app.use(express_1.default.json({ limit: '10mb' }));
// Rate limiting
const generalLimiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: { error: 'Too many requests, please try again later' }
});
const authLimiter = (0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000,
    max: 50, // limit auth requests
    message: { error: 'Too many auth attempts, please try again later' }
});
app.use('/api/', generalLimiter);
app.use('/api/auth/', authLimiter);
// Custom HTTP request logging using winston
app.use((req, res, next) => {
    logger_1.default.info(`${req.method} ${req.url}`);
    next();
});
// Serve static files (HTML dashboards)
app.use(express_1.default.static(path_1.default.join(__dirname, '../public')));
// Routes
app.use('/api/auth', auth_1.default);
app.use('/api/trends', trends_1.default);
app.use('/api/users', users_1.default);
app.use('/api/admin', admin_1.default);
app.use('/api/sessions', sessions_1.default);
app.use('/api/analytics', analyticsRoutes_1.default);
app.use('/api/integrations', integrationRoutes_1.default);
app.use('/api/ai', ai_1.default);
// News Routes
app.get('/api/news', newsController.getNewsByCategory);
app.get('/api/news/trending', trendingNewsController.getTrending);
app.get('/api/news/breakthrough', async (req, res) => {
    try {
        const items = await (0, breakthroughService_1.getBreakthroughs)();
        res.json(items);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch breakthroughs' });
    }
});
// Hyper-local state news — bypasses getNews entirely
app.get('/api/news/local', async (req, res) => {
    try {
        const state = req.query.state ?? 'India';
        const city = req.query.city ?? '';
        const category = req.query.category ?? 'general';
        const items = await (0, newsService_1.getLocalNews)(state, city, category);
        res.json(items);
    }
    catch (err) {
        res.status(500).json({ error: 'Failed to fetch local news' });
    }
});
// Serve dashboard (with optional auth based on DASHBOARD_AUTH environment variable)
const dashboardPath = path_1.default.join(__dirname, '../public/admin-dashboard-csp-fixed.html');
app.get('/dashboard', (req, res, next) => {
    if (process.env.DASHBOARD_AUTH === 'true') {
        next();
    }
    else {
        res.sendFile(dashboardPath);
    }
}, auth_2.authenticate, auth_2.isAdmin, (req, res) => {
    res.sendFile(dashboardPath);
});
// API Documentation endpoint
app.get('/api/docs', (req, res) => {
    res.json({
        version: '1.0.0',
        title: 'TrendX API Documentation',
        endpoints: {
            auth: {
                'POST /api/auth/login': 'User login',
                'POST /api/auth/register': 'User registration',
                'POST /api/auth/logout': 'User logout'
            },
            trends: {
                'GET /api/trends': 'Get all trends',
                'GET /api/trends/:platform': 'Get platform trends',
                'POST /api/trends': 'Create trend'
            },
            admin: {
                'GET /api/admin/stats': 'Dashboard statistics',
                'GET /api/admin/users': 'User management',
                'GET /api/admin/analytics': 'Analytics data'
            }
        }
    });
});
// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', message: 'TrendX Backend is running' });
});
// Error handler
app.use(errorHandler_1.errorHandler);
// Start server
const startServer = async () => {
    await (0, database_1.connectDB)();
    // Start real-time breaking news pre-fetcher (BBC/Reuters/AP — refreshes every 5 min)
    (0, breakingNewsService_1.startBreakingNewsRefresher)();
    // Start breakthrough discovery pre-fetcher (refreshes every 10 min)
    (0, breakthroughService_1.startBreakthroughRefresher)();
    // Initialize background jobs with Socket.IO
    (0, trendScheduler_1.initializeScheduler)(io);
    server.listen(PORT, () => {
        logger_1.default.info(`🚀 TrendX Backend running on port ${PORT}`);
        logger_1.default.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });
};
// Map to track who is typing in which room
const typingUsers = new Map();
// Socket.IO connection handling
io.on('connection', (socket) => {
    logger_1.default.info(`Client connected: ${socket.id}`);
    // Chat Room Logic
    socket.on('join_chat', async (data) => {
        const { trendId, userName } = data;
        if (!trendId)
            return;
        socket.join(trendId);
        logger_1.default.info(`Client ${socket.id} joined chat room: ${trendId}`);
        try {
            // Fetch recent message history dynamically
            const ChatMessage = (await Promise.resolve().then(() => __importStar(require('./models/ChatMessage')))).default;
            const history = await ChatMessage.find({ trendId })
                .sort({ timestamp: 1 })
                .limit(50);
            socket.emit('chat_history', history);
        }
        catch (err) {
            logger_1.default.error(`Error fetching chat history for ${trendId}:`, err);
        }
    });
    socket.on('leave_chat', (data) => {
        const { trendId } = data;
        if (trendId) {
            socket.leave(trendId);
            logger_1.default.info(`Client ${socket.id} left chat room: ${trendId}`);
        }
    });
    socket.on('send_message', async (data) => {
        const { trendId, text, senderName } = data;
        if (!trendId || !text || !senderName)
            return;
        try {
            // Persist the message
            const ChatMessage = (await Promise.resolve().then(() => __importStar(require('./models/ChatMessage')))).default;
            const newMessage = await ChatMessage.create({
                trendId,
                text,
                senderName,
                timestamp: new Date()
            });
            // Broadcast to room
            io.to(trendId).emit('receive_message', newMessage);
        }
        catch (err) {
            logger_1.default.error(`Error saving message for ${trendId}:`, err);
        }
    });
    // Typing indicator logic
    socket.on('typing_start', (data) => {
        const { trendId, userName } = data;
        if (!trendId || !userName)
            return;
        if (!typingUsers.has(trendId)) {
            typingUsers.set(trendId, new Set());
        }
        typingUsers.get(trendId).add(userName);
        socket.to(trendId).emit('typing_status', {
            isTyping: true,
            users: Array.from(typingUsers.get(trendId))
        });
    });
    socket.on('typing_end', (data) => {
        const { trendId, userName } = data;
        if (!trendId || !userName)
            return;
        if (typingUsers.has(trendId)) {
            typingUsers.get(trendId).delete(userName);
            socket.to(trendId).emit('typing_status', {
                isTyping: typingUsers.get(trendId).size > 0,
                users: Array.from(typingUsers.get(trendId))
            });
        }
    });
    socket.on('disconnect', () => {
        logger_1.default.info(`Client disconnected: ${socket.id}`);
        // Optional: cleanup typing states
    });
});
startServer();
