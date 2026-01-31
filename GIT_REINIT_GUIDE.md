# Git Reinitialization Guide

This guide shows you how to reinitialize your Git repository and push to a new remote repository.

## 🎯 Quick Start

### Option 1: Automated Script (Recommended)

**Windows (PowerShell):**
```powershell
.\reinit-git.ps1
```

**Linux/Mac:**
```bash
chmod +x ./reinit-git.sh
./reinit-git.sh
```

The script will guide you through the process interactively.

---

## 📝 Manual Steps

### Step 1: Remove Existing Git History

**Windows (PowerShell):**
```powershell
Remove-Item -Recurse -Force .git
```

**Linux/Mac:**
```bash
rm -rf .git
```

### Step 2: Initialize New Git Repository

```bash
git init
```

### Step 3: Create .gitignore (if needed)

Make sure you have a `.gitignore` file to exclude unnecessary files:

```bash
# Already exists in backend/ and frontend_app/
# Check if root .gitignore exists, if not create one
```

### Step 4: Add All Files

```bash
git add .
```

### Step 5: Create Initial Commit

```bash
git commit -m "Initial commit: TrendX - Real-time trending platform"
```

### Step 6: Add New Remote Repository

Replace `<YOUR_REPO_URL>` with your new repository URL:

```bash
git remote add origin <YOUR_REPO_URL>
```

**Examples:**
- GitHub: `git remote add origin https://github.com/username/trendx.git`
- GitLab: `git remote add origin https://gitlab.com/username/trendx.git`
- Bitbucket: `git remote add origin https://bitbucket.org/username/trendx.git`

### Step 7: Verify Remote

```bash
git remote -v
```

Expected output:
```
origin  <YOUR_REPO_URL> (fetch)
origin  <YOUR_REPO_URL> (push)
```

### Step 8: Push to Remote

**First time push:**
```bash
git push -u origin main
```

If your default branch is `master` instead of `main`:
```bash
git branch -M main
git push -u origin main
```

---

## 🔧 Troubleshooting

### Issue: Remote repository has existing code

If the remote repository already has code, you'll get an error. Choose one:

**Option A: Force push (overwrites remote)**
```bash
git push -u origin main --force
```
⚠️ **Warning:** This will delete all existing code in the remote repository!

**Option B: Pull and merge first**
```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### Issue: Authentication failed

**For GitHub (HTTPS):**
1. Use a Personal Access Token instead of password
2. Go to: Settings → Developer settings → Personal access tokens → Generate new token
3. Use token as password when prompted

**For GitHub (SSH):**
```bash
git remote set-url origin git@github.com:username/trendx.git
```

### Issue: Large files error

If you have files larger than 50MB:

1. Install Git LFS:
```bash
git lfs install
```

2. Track large files:
```bash
git lfs track "*.psd"  # Example for Photoshop files
git lfs track "*.zip"  # Example for archives
```

3. Commit and push again:
```bash
git add .gitattributes
git commit -m "Add Git LFS tracking"
git push -u origin main
```

---

## 📦 What Gets Committed?

### ✅ Included:
- All source code (`backend/`, `frontend_app/`)
- Configuration files
- Documentation (`.md` files)
- Scripts
- `.gitignore` files

### ❌ Excluded (via .gitignore):
- `node_modules/` (backend dependencies)
- `.env` files (secrets)
- Build outputs
- Temporary files
- IDE-specific files

---

## 🎨 Recommended Commit Message Structure

```bash
# Initial commit
git commit -m "Initial commit: TrendX - Real-time trending platform

Features:
- Flutter mobile app with premium UI
- Node.js backend with Express & MongoDB
- Real-time updates via Socket.IO
- News & Trends aggregation
- User authentication with JWT
- Admin dashboard"
```

---

## 🚀 Next Steps After Pushing

1. **Add repository description** on GitHub/GitLab
2. **Add topics/tags**: `flutter`, `nodejs`, `mongodb`, `trending`, `real-time`
3. **Create README.md** in root (if you want a project-wide README)
4. **Set up CI/CD** (optional)
5. **Enable branch protection** for `main`

---

## 📋 Pre-Push Checklist

- [ ] Removed sensitive data (API keys, passwords) from code
- [ ] All `.env.example` files present (without actual secrets)
- [ ] `.gitignore` properly configured
- [ ] Code compiles/runs without errors
- [ ] Documentation is up to date
- [ ] Large files handled with Git LFS (if needed)
- [ ] Created new remote repository on GitHub/GitLab/Bitbucket
- [ ] Tested that repository URL is correct

---

## 🔐 Security Best Practices

### Before Pushing, Ensure:

1. **No API keys in code:**
   ```bash
   # Search for potential secrets
   grep -r "API_KEY" --exclude-dir=node_modules
   grep -r "SECRET" --exclude-dir=node_modules
   ```

2. **Check .env files:**
   ```bash
   # Make sure .env is in .gitignore
   git check-ignore backend/.env
   ```
   Should output: `backend/.env` ✅

3. **Review files to be committed:**
   ```bash
   git status
   ```

---

## 🌿 Branch Strategy Recommendations

### Simple Strategy (Solo Developer):
- `main` - stable production code
- Work directly on `main` with frequent commits

### Team Strategy:
```bash
# Create development branch
git checkout -b develop

# Create feature branches
git checkout -b feature/user-auth
git checkout -b feature/admin-dashboard

# Merge to develop when ready
git checkout develop
git merge feature/user-auth

# Merge to main for releases
git checkout main
git merge develop
git tag -a v1.0.0 -m "First stable release"
git push origin main --tags
```

---

## 📖 Useful Git Commands

```bash
# View commit history
git log --oneline --graph --all

# Check repository status
git status

# See what changed
git diff

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Create and push a tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Clone your new repository elsewhere
git clone <YOUR_REPO_URL>
```

---

## ✨ Success!

Once pushed, your repository should be visible at your Git hosting platform with all your code!

**Repository URL format:**
- GitHub: `https://github.com/username/trendx`
- GitLab: `https://gitlab.com/username/trendx`
- Bitbucket: `https://bitbucket.org/username/trendx`
