# TrendX API Setup Guide

## 🔑 API Keys You Need to Obtain

This guide will walk you through getting all the API keys needed for TrendX's real-time trending system.

---

## 1. YouTube Data API v3 (FREE)

**What it's for**: Get trending videos, video statistics, and search YouTube content

### How to get it:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the YouTube Data API v3:
   - Go to "APIs & Services" → "Library"
   - Search for "YouTube Data API v3"
   - Click "Enable"
4. Create credentials:
   - Go to "APIs & Services" → "Credentials"
   - Click "+ CREATE CREDENTIALS" → "API key"
   - Copy your API key

### Limits:
- **FREE**: 10,000 units/day (sufficient for ~3,000 requests)
- Each video request costs 1 unit
- Search requests cost 100 units

### Add to `.env`:
```
YOUTUBE_API_KEY=your_youtube_api_key_here
```

---

## 2. Twitter API v2 (FREE tier available)

**What it's for**: Get trending topics, tweets, and Twitter trends by location

### How to get it:
1. Go to [Twitter Developer Portal](https://developer.twitter.com/)
2. Sign in with your Twitter account
3. Apply for "Elevated access" (formerly called "Standard"):
   - Click "Sign up for free account"
   - Fill out the application form (describe use case: "Educational trending news aggregator")
   - Wait for approval (usually within a few hours)
4. Create an app:
   - Go to "Projects & Apps" → "+ Create App"
   - Name your app (e.g., "TrendX")
5. Get your Bearer Token:
   - Go to your app's "Keys and tokens" tab
   - Generate "Bearer Token"
   - Copy it

### Limits:
- **FREE tier**: 500,000 tweets/month
- Trends endpoint: 75 requests per 15-minute window

### Add to `.env`:
```
TWITTER_BEARER_TOKEN=your_twitter_bearer_token_here
```

---

## 3. NewsAPI.org (FREE)

**What it's for**: Get news articles from various sources and categories

### How to get it:
1. Go to [NewsAPI.org](https://newsapi.org/)
2. Click "Get API Key"
3. Sign up with your email
4. Confirm your email
5. Copy your API key from the dashboard

### Limits:
- **FREE**: 100 requests/day
- **Developer plan**: $449/month for 250,000 requests

### Add to `.env`:
```
NEWS_API_KEY=your_newsapi_key_here
```

---

## 4. RapidAPI (For Instagram & TikTok) (FREE tier)

**What it's for**: Get Instagram and TikTok trending content

### How to get it:
1. Go to [RapidAPI](https://rapidapi.com/)
2. Sign up for a free account
3. Subscribe to these APIs:

#### Instagram Scraper API
- Search for "Instagram Scraper API" on RapidAPI
- Subscribe to the FREE plan (usually 500-1000 requests/month)
- Copy your RapidAPI key from the dashboard

#### TikTok Scraper API
- Search for "TikTok Scraper" on RapidAPI  
- Subscribe to the FREE plan
- Use the same RapidAPI key

### Limits:
- **FREE**: 500-1000 requests/month per API
- Can upgrade to paid plans if needed

### Add to `.env`:
```
RAPIDAPI_KEY=your_rapidapi_key_here
```

---

## 5. Reddit API (FREE)

**What it's for**: Get hot posts, trending subreddits, and Reddit content

### How to get it:
1. Go to [Reddit Apps](https://www.reddit.com/prefs/apps)
2. Scroll down and click "Create App" or "Create Another App"
3. Fill in the form:
   - **name**: TrendX
   - **App type**: Select "script"
   - **description**: Trending news aggregator
   - **about url**: (leave blank)
   - **redirect uri**: http://localhost:8080
4. Click "Create app"
5. Note down:
   - **client_id**: The string under "personal use script"
   - **client_secret**: The "secret" field

### Limits:
- **FREE**: Unlimited (with rate limiting - 60 requests per minute)

### Add to `.env`:
```
REDDIT_CLIENT_ID=your_reddit_client_id_here
REDDIT_CLIENT_SECRET=your_reddit_client_secret_here
```

### Get Refresh Token (for snoowrap):
1. Run this command in your backend directory:
```bash
npx snoowrap-oauth-helper
```
2. Follow the prompts and get your refresh token
3. Add to `.env`:
```
REDDIT_REFRESH_TOKEN=your_reddit_refresh_token_here
```

---

## 📝 Complete .env File Example

Here's what your `.env` file should look like with all keys:

```env
# Server Configuration
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/trendx
REDIS_URL=redis://localhost:6379

# Authentication
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRE=7d
BCRYPT_ROUNDS=12

# Social Media APIs
YOUTUBE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
TWITTER_BEARER_TOKEN=AAAAAAAAAAAAAAAAAAAAAXXXXXXXXXXXXXXXXXXX
REDDIT_CLIENT_ID=xxxxxxxxxxxx
REDDIT_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxx
REDDIT_REFRESH_TOKEN=xxxxxxxx-xxxxxxxxxxxxxxxx
NEWS_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
RAPIDAPI_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# AI Services (Optional)
OPENAI_API_KEY=your-openai-api-key
GEMINI_API_KEY=your-gemini-api-key

# Cache Settings
CACHE_TTL=300
CACHE_MAX_SIZE=1000

# Rate Limiting
RATE_LIMIT_WINDOW=900000
RATE_LIMIT_MAX=100
AUTH_RATE_LIMIT_MAX=5
```

---

## ✅ Testing Your Setup

After adding all API keys, test the backend:

```bash
cd backend
npm install
npm run dev
```

Check the console for:
- ✅ MongoDB connection successful
- ✅ Scheduler initialized
- ✅ Trend ingestion starting
- ✅ Trends saved to database

---

## 🆓 Cost Summary

| API | Free Tier | Sufficient For |
|-----|-----------|----------------|
| YouTube | 10,000 units/day | ~3,000 video fetches/day |
| Twitter | 500,000 tweets/month | ~16,000 requests/day |
| NewsAPI | 100 requests/day | Limited, use as supplement |
| RapidAPI | 500-1000 req/month | ~16-33 requests/day |
| Reddit | Unlimited (rate limited) | Unlimited! |

**Total Cost: $0/month** with free tiers!

---

## 🚀 Fallback Strategy

Don't have all the API keys yet? No problem!

The system is designed with fallbacks:
- **No YouTube API?** → Uses mock data
- **No Twitter API?** → Falls back to scraping
- **No NewsAPI?** → Falls back to Google News RSS (unlimited & free!)
- **No RapidAPI?** → Uses placeholder data
- **No Reddit API?** → Uses mock data

You can start testing immediately and add API keys later!

---

## 📞 Support

Having issues getting API keys?
- Check the [TrendX Discord](https://discord.gg/trendx) for community help
- Review the official API documentation links above
- Most APIs respond to support tickets within 24 hours
