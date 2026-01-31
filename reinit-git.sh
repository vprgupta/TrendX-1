#!/bin/bash

# TrendX Git Reinitialization Script (Bash)
# This script removes existing Git history and prepares for pushing to a new repository

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}TrendX Git Reinitialization Tool${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check if .git directory exists
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠️  Existing Git repository found${NC}"
    echo ""
    read -p "This will DELETE all existing Git history. Continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo -e "${RED}❌ Operation cancelled${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${YELLOW}🗑️  Removing existing .git directory...${NC}"
    rm -rf .git
    echo -e "${GREEN}✓ Removed${NC}"
else
    echo -e "${CYAN}ℹ️  No existing Git repository found${NC}"
fi

echo ""
echo -e "${YELLOW}📦 Initializing new Git repository...${NC}"
git init
echo -e "${GREEN}✓ Initialized${NC}"

echo ""
echo -e "${YELLOW}📝 Adding all files...${NC}"
git add .
echo -e "${GREEN}✓ Files added${NC}"

echo ""
echo -e "${YELLOW}💾 Creating initial commit...${NC}"
git commit -m "Initial commit: TrendX - Real-time trending platform

Features:
- Flutter mobile app with premium UI
- Node.js backend with Express & MongoDB
- Real-time updates via Socket.IO
- News & Trends aggregation
- User authentication with JWT refresh tokens
- Admin dashboard with analytics
- Production-ready logging and database optimization"

echo -e "${GREEN}✓ Commit created${NC}"

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Create a new repository on GitHub/GitLab/Bitbucket"
echo "2. Copy the repository URL"
echo -e "3. Run the following commands: ${CYAN}"
echo ""
echo -e "${WHITE}   git remote add origin <YOUR_REPO_URL>${NC}"
echo -e "${WHITE}   git branch -M main${NC}"
echo -e "${WHITE}   git push -u origin main${NC}"
echo ""
echo -e "${YELLOW}Example:${NC}"
echo -e "${WHITE}   git remote add origin https://github.com/username/trendx.git${NC}"
echo -e "${WHITE}   git branch -M main${NC}"
echo -e "${WHITE}   git push -u origin main${NC}"
echo ""

read -p "Would you like to add a remote now? (yes/no): " addRemote

if [ "$addRemote" = "yes" ]; then
    echo ""
    read -p "Enter your repository URL: " repoUrl
    
    if [ -n "$repoUrl" ]; then
        echo ""
        echo -e "${YELLOW}🔗 Adding remote origin...${NC}"
        git remote add origin "$repoUrl"
        
        echo -e "${GREEN}✓ Remote added${NC}"
        echo ""
        echo -e "${YELLOW}📊 Verifying remote...${NC}"
        git remote -v
        
        echo ""
        read -p "Would you like to push now? (yes/no): " pushNow
        
        if [ "$pushNow" = "yes" ]; then
            echo ""
            echo -e "${YELLOW}🚀 Pushing to remote...${NC}"
            git branch -M main
            git push -u origin main
            
            if [ $? -eq 0 ]; then
                echo ""
                echo -e "${GREEN}========================================${NC}"
                echo -e "${GREEN}✨ Successfully pushed to remote!${NC}"
                echo -e "${GREEN}========================================${NC}"
            else
                echo ""
                echo -e "${RED}❌ Push failed. See error above.${NC}"
                echo ""
                echo -e "${YELLOW}Common fixes:${NC}"
                echo "- Check repository URL is correct"
                echo "- Verify authentication (use Personal Access Token for HTTPS)"
                echo "- Try: git push -u origin main --force (if remote has code)"
            fi
        fi
    fi
fi

echo ""
echo -e "${GREEN}✨ Done!${NC}"
