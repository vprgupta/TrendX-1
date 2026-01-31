export const appConfig = {
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key',
    expiresIn: '7d'
  },
  api: {
    version: 'v1',
    baseUrl: process.env.API_BASE_URL || 'http://localhost:3000/api',
    rateLimit: {
      windowMs: 15 * 60 * 1000,
      max: 100
    }
  },
  dashboard: {
    requireAuth: process.env.DASHBOARD_AUTH === 'true',
    adminEmails: (process.env.ADMIN_EMAILS || '').split(',').filter(Boolean)
  },
  platforms: {
    twitter: {
      enabled: true,
      apiKey: process.env.TWITTER_API_KEY
    },
    youtube: {
      enabled: true,
      apiKey: process.env.YOUTUBE_API_KEY
    },
    reddit: {
      enabled: true,
      clientId: process.env.REDDIT_CLIENT_ID
    }
  }
};