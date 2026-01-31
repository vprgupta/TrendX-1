import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import path from 'path';
import morgan from 'morgan';
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
import logger, { morganStream } from './utils/logger';

dotenv.config();

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
app.use(helmet());
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
  max: 5, // limit auth requests
  message: { error: 'Too many auth attempts, please try again later' }
});

app.use('/api/', generalLimiter);
app.use('/api/auth/', authLimiter);

// HTTP request logging
if (process.env.NODE_ENV === 'production') {
  app.use(morgan('combined', { stream: morganStream }));
} else {
  app.use(morgan('dev', { stream: morganStream }));
}

// Serve static files (HTML dashboards)
app.use(express.static(path.join(__dirname, '../public')));

import analyticsRoutes from './routes/analyticsRoutes';
import integrationRoutes from './routes/integrationRoutes';

import * as newsController from './controllers/newsController';

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/trends', trendRoutes);
app.use('/api/users', userRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/sessions', sessionRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/integrations', integrationRoutes);

// News Route
app.get('/api/news', newsController.getNewsByCategory);

// Serve dashboard (with optional auth)
app.get('/dashboard', (req, res) => {
  // TODO: Add authentication check if DASHBOARD_AUTH=true
  res.sendFile(path.join(__dirname, '../public/admin-dashboard-csp-fixed.html'));
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

import { initializeScheduler } from './jobs/trendScheduler';

// Start server
const startServer = async () => {
  await connectDB();

  // Initialize background jobs with Socket.IO
  initializeScheduler(io);

  server.listen(PORT, () => {
    logger.info(`🚀 TrendX Backend running on port ${PORT}`);
    logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
  });
};

// Socket.IO connection handling
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
  });
});

startServer();