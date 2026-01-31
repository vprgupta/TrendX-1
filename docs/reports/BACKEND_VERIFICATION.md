# 🔍 TrendX Backend Verification Guide

## Prerequisites
- Node.js installed
- MongoDB running (local or cloud)
- Backend dependencies installed

## Step-by-Step Verification

### 1. Start MongoDB (if using local)
```bash
# Windows (if MongoDB is installed locally)
mongod

# Or use MongoDB Atlas (cloud) - update .env file
```

### 2. Install Dependencies
```bash
cd backend
npm install
```

### 3. Check Environment Configuration
```bash
# Verify .env file exists with:
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/trendx
JWT_SECRET=trendx-super-secret-jwt-key-change-in-production
JWT_EXPIRE=7d
BCRYPT_ROUNDS=12
```

### 4. Start Backend Server
```bash
# In backend directory
npm run dev
```

**Expected Output:**
```
✅ Connected to MongoDB
🚀 Server running on port 5000
```

### 5. Manual API Testing

#### A. Health Check
```bash
curl http://localhost:5000/health
```
**Expected Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-XX..."
}
```

#### B. Get Trends (No Auth Required)
```bash
curl http://localhost:5000/api/trends
```
**Expected Response:**
```json
{
  "trends": [],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 0,
    "pages": 0
  }
}
```

#### C. User Registration
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```
**Expected Response:**
```json
{
  "message": "User registered successfully",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "...",
    "email": "test@example.com",
    "name": "Test User"
  }
}
```

#### D. User Login
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 6. Automated Testing
```bash
# In backend directory
node test-backend.js
```

## 🚨 Common Issues & Solutions

### Issue 1: MongoDB Connection Error
**Error:** `MongoDB connection error`
**Solution:**
- Ensure MongoDB is running locally OR
- Update MONGODB_URI in .env to use MongoDB Atlas
- Check firewall settings

### Issue 2: Port Already in Use
**Error:** `EADDRINUSE: address already in use :::5000`
**Solution:**
```bash
# Kill process on port 5000
netstat -ano | findstr :5000
taskkill /PID <PID_NUMBER> /F

# Or change PORT in .env file
```

### Issue 3: TypeScript Compilation Errors
**Error:** TypeScript compilation issues
**Solution:**
```bash
# Install TypeScript globally
npm install -g typescript

# Compile manually
npm run build
```

### Issue 4: Missing Dependencies
**Error:** Module not found
**Solution:**
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

## 📊 API Endpoints Summary

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| GET | `/health` | No | Health check |
| GET | `/api/trends` | No | Get all trends |
| GET | `/api/trends/search?q=query` | No | Search trends |
| GET | `/api/trends/platform/:platform` | No | Platform-specific trends |
| GET | `/api/trends/country/:country` | No | Country-specific trends |
| GET | `/api/trends/category/:category` | No | Category-specific trends |
| GET | `/api/trends/:id` | No | Get specific trend |
| POST | `/api/trends` | Yes | Create new trend |
| POST | `/api/auth/register` | No | User registration |
| POST | `/api/auth/login` | No | User login |

## 🔧 Development Tools

### Using Postman
1. Import the following collection:
   - Base URL: `http://localhost:5000`
   - Add requests for each endpoint above
   - For protected routes, add Authorization header: `Bearer <token>`

### Using Thunder Client (VS Code)
1. Install Thunder Client extension
2. Create new collection
3. Add requests for each endpoint

### Using curl (Command Line)
See examples in Step 5 above

## ✅ Success Indicators

Your backend is working correctly if:
- ✅ Server starts without errors
- ✅ MongoDB connection is successful
- ✅ Health check returns 200 status
- ✅ User registration/login works
- ✅ JWT tokens are generated
- ✅ Protected routes require authentication
- ✅ CORS is configured for frontend
- ✅ Rate limiting is active
- ✅ Error handling works properly

## 🔄 Next Steps

Once backend verification is complete:
1. Test frontend-backend integration
2. Verify real-time features (if implemented)
3. Test with sample data
4. Performance testing
5. Security testing