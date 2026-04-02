import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import path from 'path';
import { createServer } from 'http';
import { Server } from 'socket.io';
import 'express-async-errors';
import authRoutes from './routes/auth';
import trendRoutes from './routes/trends';
import userRoutes from './routes/users';
import adminRoutes from './routes/admin';
import sessionRoutes from './routes/sessions';
import { errorHandler } from './middleware/errorHandler';
import { connectDB } from './config/database';
import { validateEnv } from './config/envValidator';
import { authenticate, isAdmin } from './middleware/auth';
import logger, { morganStream } from './utils/logger';
import analyticsRoutes from './routes/analyticsRoutes';
import integrationRoutes from './routes/integrationRoutes';
import aiRoutes from './routes/ai';
import * as newsController from './controllers/newsController';
import * as trendingNewsController from './controllers/trendingNewsController';
import { getLocalNews } from './services/newsService';

import { initializeScheduler } from './jobs/trendScheduler';
import { startBreakingNewsRefresher } from './services/breakingNewsService';
import { getBreakthroughs, startBreakthroughRefresher } from './services/breakthroughService';

dotenv.config();
validateEnv();

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] }
});

// Extend Request interface
declare global {
  namespace Express {
    interface Request {
      io?: Server;
    }
  }
}

// Middleware to pass io to routes
app.use((req, res, next) => {
  req.io = io;
  next();
});
const PORT = process.env.PORT || 3000;

// Make io available globally
app.set('io', io);

// Security middleware
app.use(helmet({
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
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Rate limiting
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: { error: 'Too many requests, please try again later' }
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 50, // limit auth requests
  message: { error: 'Too many auth attempts, please try again later' }
});

app.use('/api/', generalLimiter);
app.use('/api/auth/', authLimiter);

// Custom HTTP request logging using winston
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.url}`);
  next();
});

// Serve static files (HTML dashboards)
app.use(express.static(path.join(__dirname, '../public')));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/trends', trendRoutes);
app.use('/api/users', userRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/sessions', sessionRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/integrations', integrationRoutes);
app.use('/api/ai', aiRoutes);

// News Routes
app.get('/api/news', newsController.getNewsByCategory);
app.get('/api/news/trending', trendingNewsController.getTrending);
app.get('/api/news/breakthrough', async (req, res) => {
  try {
    const items = await getBreakthroughs();
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch breakthroughs' });
  }
});
// Hyper-local state news — bypasses getNews entirely
app.get('/api/news/local', async (req, res) => {
  try {
    const state    = (req.query.state    as string | undefined) ?? 'India';
    const city     = (req.query.city     as string | undefined) ?? '';
    const category = (req.query.category as string | undefined) ?? 'general';
    const items = await getLocalNews(state, city, category);
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch local news' });
  }
});



// Serve dashboard (with optional auth based on DASHBOARD_AUTH environment variable)
const dashboardPath = path.join(__dirname, '../public/admin-dashboard-csp-fixed.html');

app.get('/dashboard', (req, res, next) => {
  if (process.env.DASHBOARD_AUTH === 'true') {
    next();
  } else {
    res.sendFile(dashboardPath);
  }
}, authenticate, isAdmin, (req, res) => {
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
app.use(errorHandler);

// Start server
const startServer = async () => {
  await connectDB();

  // Start real-time breaking news pre-fetcher (BBC/Reuters/AP — refreshes every 5 min)
  startBreakingNewsRefresher();
  // Start breakthrough discovery pre-fetcher (refreshes every 10 min)
  startBreakthroughRefresher();

  // Initialize background jobs with Socket.IO
  initializeScheduler(io);

  server.listen(PORT, () => {
    logger.info(`🚀 TrendX Backend running on port ${PORT}`);
    logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
  });
};

// Map to track who is typing in which room
const typingUsers = new Map<string, Set<string>>();

// Socket.IO connection handling
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  // Chat Room Logic
  socket.on('join_chat', async (data) => {
    const { trendId, userName } = data;
    if (!trendId) return;

    socket.join(trendId);
    logger.info(`Client ${socket.id} joined chat room: ${trendId}`);

    try {
      // Fetch recent message history dynamically
      const ChatMessage = (await import('./models/ChatMessage')).default;
      const history = await ChatMessage.find({ trendId })
        .sort({ timestamp: 1 })
        .limit(50);

      socket.emit('chat_history', history);
    } catch (err) {
      logger.error(`Error fetching chat history for ${trendId}:`, err);
    }
  });

  socket.on('leave_chat', (data) => {
    const { trendId } = data;
    if (trendId) {
      socket.leave(trendId);
      logger.info(`Client ${socket.id} left chat room: ${trendId}`);
    }
  });

  socket.on('send_message', async (data) => {
    const { trendId, text, senderName } = data;
    if (!trendId || !text || !senderName) return;

    try {
      // Persist the message
      const ChatMessage = (await import('./models/ChatMessage')).default;
      const newMessage = await ChatMessage.create({
        trendId,
        text,
        senderName,
        timestamp: new Date()
      });

      // Broadcast to room
      io.to(trendId).emit('receive_message', newMessage);
    } catch (err) {
      logger.error(`Error saving message for ${trendId}:`, err);
    }
  });

  // Typing indicator logic
  socket.on('typing_start', (data) => {
    const { trendId, userName } = data;
    if (!trendId || !userName) return;

    if (!typingUsers.has(trendId)) {
      typingUsers.set(trendId, new Set());
    }
    typingUsers.get(trendId)!.add(userName);

    socket.to(trendId).emit('typing_status', {
      isTyping: true,
      users: Array.from(typingUsers.get(trendId)!)
    });
  });

  socket.on('typing_end', (data) => {
    const { trendId, userName } = data;
    if (!trendId || !userName) return;

    if (typingUsers.has(trendId)) {
      typingUsers.get(trendId)!.delete(userName);
      socket.to(trendId).emit('typing_status', {
        isTyping: typingUsers.get(trendId)!.size > 0,
        users: Array.from(typingUsers.get(trendId)!)
      });
    }
  });

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
    // Optional: cleanup typing states
  });
});

startServer();