const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const path = require('path');

const app = express();
const PORT = 3000;
const JWT_SECRET = 'trendx_super_secret_jwt_key_2024_development_only';

// In-memory storage (replace with MongoDB later)
const users = [];

// Create test user on startup
(async () => {
    const testUser = {
        id: 'test-user-1',
        name: 'Admin User',
        email: 'admin@trendx.com',
        password: await bcrypt.hash('admin123', 12),
        preferences: {
            platforms: ['youtube', 'twitter', 'reddit'],
            categories: ['technology', 'science', 'environment'],
            countries: ['global']
        },
        savedTrends: [],
        createdAt: new Date()
    };
    users.push(testUser);
    console.log('✅ Test user created: admin@trendx.com / admin123');
})();
const trends = [
    {
        id: '1',
        title: 'AI Revolution in 2024',
        content: 'Artificial Intelligence is transforming industries',
        platform: 'youtube',
        category: 'technology',
        country: 'global',
        metrics: { views: 1500000, likes: 45000, shares: 12000, comments: 8500, engagement: 4.3 },
        createdAt: new Date()
    },
    {
        id: '2',
        title: 'Climate Change Solutions',
        content: 'Innovative approaches to combat climate change',
        platform: 'twitter',
        category: 'environment',
        country: 'global',
        metrics: { views: 890000, likes: 23000, shares: 8900, comments: 4500, engagement: 4.1 },
        createdAt: new Date()
    },
    {
        id: '3',
        title: 'Space Exploration Updates',
        content: 'Latest developments in space technology',
        platform: 'reddit',
        category: 'science',
        country: 'global',
        metrics: { views: 650000, likes: 18000, shares: 5600, comments: 3200, engagement: 4.2 },
        createdAt: new Date()
    }
];

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// Auth middleware
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Access token required' });
    }

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid token' });
        }
        req.user = user;
        next();
    });
};

// Routes

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'OK', message: 'TrendX Backend is running!' });
});

// Auth routes
app.post('/api/auth/register', async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // Validation
        if (!name || !email || !password) {
            return res.status(400).json({ error: 'All fields are required' });
        }

        if (password.length < 6) {
            return res.status(400).json({ error: 'Password must be at least 6 characters' });
        }

        // Check if user exists
        const existingUser = users.find(u => u.email === email);
        if (existingUser) {
            return res.status(400).json({ error: 'User already exists' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 12);

        // Create user
        const user = {
            id: Date.now().toString(),
            name,
            email,
            password: hashedPassword,
            preferences: {
                platforms: ['youtube', 'twitter'],
                categories: ['technology', 'science'],
                countries: ['global']
            },
            savedTrends: [],
            createdAt: new Date()
        };

        users.push(user);

        // Generate token
        const token = jwt.sign(
            { id: user.id, email: user.email },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        // Return user without password
        const { password: _, ...userWithoutPassword } = user;

        res.status(201).json({
            message: 'User registered successfully',
            token,
            user: userWithoutPassword
        });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validation
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        // Find user
        const user = users.find(u => u.email === email);
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Check password
        const isValidPassword = await bcrypt.compare(password, user.password);
        if (!isValidPassword) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Generate token
        const token = jwt.sign(
            { id: user.id, email: user.email },
            JWT_SECRET,
            { expiresIn: '7d' }
        );

        // Return user without password
        const { password: _, ...userWithoutPassword } = user;

        res.json({
            message: 'Login successful',
            token,
            user: userWithoutPassword
        });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Trends routes
app.get('/api/trends', (req, res) => {
    const { platform, category, country, limit = 10, page = 1 } = req.query;
    
    let filteredTrends = [...trends];
    
    if (platform) {
        filteredTrends = filteredTrends.filter(t => t.platform === platform);
    }
    
    if (category) {
        filteredTrends = filteredTrends.filter(t => t.category === category);
    }
    
    if (country && country !== 'global') {
        filteredTrends = filteredTrends.filter(t => t.country === country);
    }
    
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedTrends = filteredTrends.slice(startIndex, endIndex);
    
    res.json({
        trends: paginatedTrends,
        total: filteredTrends.length,
        page: parseInt(page),
        totalPages: Math.ceil(filteredTrends.length / limit)
    });
});

app.get('/api/trends/:id', (req, res) => {
    const trend = trends.find(t => t.id === req.params.id);
    if (!trend) {
        return res.status(404).json({ error: 'Trend not found' });
    }
    res.json(trend);
});

// User routes
app.get('/api/users/profile', authenticateToken, (req, res) => {
    const user = users.find(u => u.id === req.user.id);
    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }
    
    const { password: _, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
});

// Admin routes
app.get('/api/admin/stats', (req, res) => {
    const stats = {
        totalTrends: trends.length,
        totalUsers: users.length,
        apiRequestsToday: Math.floor(Math.random() * 10000) + 5000,
        platformCoverage: 4
    };
    res.json(stats);
});

app.get('/api/admin/users', (req, res) => {
    const usersWithoutPasswords = users.map(({ password, ...user }) => user);
    res.json(usersWithoutPasswords);
});

app.get('/api/admin/trends', (req, res) => {
    res.json(trends);
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 TrendX Backend running on http://localhost:${PORT}`);
    console.log(`📊 Dashboard: http://localhost:${PORT}/modern-admin-dashboard.html`);
    console.log(`🔐 Login: http://localhost:${PORT}/login.html`);
    console.log(`📝 Signup: http://localhost:${PORT}/signup.html`);
    console.log(`✅ Health: http://localhost:${PORT}/health`);
});