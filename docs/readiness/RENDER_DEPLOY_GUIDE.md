# Cloud Deployment Guide (Free Hosting)

This guide provides instructions for deploying the TrendX backend and database to free cloud platforms.

## 1. Database: MongoDB Atlas (Free Tier)
1. Sign up/Log in to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas/register).
2. Create a new project named "TrendX".
3. Click "Build a Cluster" and select the **Free M0 Sandbox**.
4. Choose a provider (e.g., AWS) and a region (e.g., N. Virginia).
5. In "Security Quickstart":
   - Create a database user (e.g., `trendx_admin`) and a password. **Keep these safe.**
   - Add `0.0.0.0/0` to your IP Access List (allows connection from cloud platforms).
6. Click "Connect" -> "Connect your application" and copy the **Connection String**.
   - It will look like: `mongodb+srv://trendx_admin:<password>@cluster0.abcde.mongodb.net/?retryWrites=true&w=majority`

## 2. Backend: Hosting (Render or Railway)

### Option A: Render.com (Recommended)
1. Connect your GitHub repository to [Render](https://render.com).
2. Create a new **Web Service**.
3. Set the following:
   - **Environment:** `Node`
   - **Build Command:** `npm install && npm run build`
   - **Start Command:** `npm start`
4. Add Environment Variables (from `.env.example`):
   - `MONGODB_URI`: Your MongoDB Atlas connection string (replace `<password>`).
   - `JWT_SECRET`: A long random string.
   - `PORT`: `10000` (Render's default, though it sets it automatically).
   - `NODE_ENV`: `production`

### Option B: Railway.app
1. Connect GitHub to [Railway](https://railway.app).
2. Create a new Project -> Deploy from GitHub repo.
3. Railway will automatically detect the `package.json` and start.
4. Add the same environment variables as above in the "Variables" tab.

## 3. Frontend: Live API URL
Once the backend is deployed, you will get a URL (e.g., `https://trendx-backend.onrender.com`).
1. Update `frontend_app/lib/config/environment.dart` production URL.
2. Build the app with `--dart-define=ENV=production`.
