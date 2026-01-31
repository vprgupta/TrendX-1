# TrendX Git Reinitialization Script (PowerShell)
# This script removes existing Git history and prepares for pushing to a new repository

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TrendX Git Reinitialization Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if .git directory exists
if (Test-Path .git) {
    Write-Host "⚠️  Existing Git repository found" -ForegroundColor Yellow
    Write-Host ""
    $confirm = Read-Host "This will DELETE all existing Git history. Continue? (yes/no)"
    
    if ($confirm -ne "yes") {
        Write-Host "❌ Operation cancelled" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "🗑️  Removing existing .git directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force .git
    Write-Host "✓ Removed" -ForegroundColor Green
}
else {
    Write-Host "ℹ️  No existing Git repository found" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "📦 Initializing new Git repository..." -ForegroundColor Yellow
git init
Write-Host "✓ Initialized" -ForegroundColor Green

Write-Host ""
Write-Host "📝 Adding all files..." -ForegroundColor Yellow
git add .
Write-Host "✓ Files added" -ForegroundColor Green

Write-Host ""
Write-Host "💾 Creating initial commit..." -ForegroundColor Yellow
git commit -m "Initial commit: TrendX - Real-time trending platform

Features:
- Flutter mobile app with premium UI
- Node.js backend with Express & MongoDB
- Real-time updates via Socket.IO
- News & Trends aggregation
- User authentication with JWT refresh tokens
- Admin dashboard with analytics
- Production-ready logging and database optimization"

Write-Host "✓ Commit created" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Create a new repository on GitHub/GitLab/Bitbucket"
Write-Host "2. Copy the repository URL"
Write-Host "3. Run the following commands:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   git remote add origin <YOUR_REPO_URL>" -ForegroundColor White
Write-Host "   git branch -M main" -ForegroundColor White
Write-Host "   git push -u origin main" -ForegroundColor White
Write-Host ""
Write-Host "Example:" -ForegroundColor Yellow
Write-Host "   git remote add origin https://github.com/username/trendx.git" -ForegroundColor White
Write-Host "   git branch -M main" -ForegroundColor White
Write-Host "   git push -u origin main" -ForegroundColor White
Write-Host ""

$addRemote = Read-Host "Would you like to add a remote now? (yes/no)"

if ($addRemote -eq "yes") {
    Write-Host ""
    $repoUrl = Read-Host "Enter your repository URL"
    
    if ($repoUrl) {
        Write-Host ""
        Write-Host "🔗 Adding remote origin..." -ForegroundColor Yellow
        git remote add origin $repoUrl
        
        Write-Host "✓ Remote added" -ForegroundColor Green
        Write-Host ""
        Write-Host "📊 Verifying remote..." -ForegroundColor Yellow
        git remote -v
        
        Write-Host ""
        $pushNow = Read-Host "Would you like to push now? (yes/no)"
        
        if ($pushNow -eq "yes") {
            Write-Host ""
            Write-Host "🚀 Pushing to remote..." -ForegroundColor Yellow
            git branch -M main
            git push -u origin main
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Green
                Write-Host "✨ Successfully pushed to remote!" -ForegroundColor Green
                Write-Host "========================================" -ForegroundColor Green
            }
            else {
                Write-Host ""
                Write-Host "❌ Push failed. See error above." -ForegroundColor Red
                Write-Host ""
                Write-Host "Common fixes:" -ForegroundColor Yellow
                Write-Host "- Check repository URL is correct"
                Write-Host "- Verify authentication (use Personal Access Token for HTTPS)"
                Write-Host "- Try: git push -u origin main --force (if remote has code)"
            }
        }
    }
}

Write-Host ""
Write-Host "✨ Done!" -ForegroundColor Green
