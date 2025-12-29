# 🔄 QUICK UPDATE GUIDE
## How to Update Your Deployed Application

---

## 📋 OVERVIEW

**Your current setup:**
```
Git Push → GitHub → Auto-Deploy
                  ↓
            Netlify (Frontend)
            Render (Backend)
```

**Every time you push to GitHub, your apps auto-deploy in 2-5 minutes!**

---

## ⚡ QUICK UPDATE (Common Changes)

### **Step 1: Make Changes Locally**
```powershell
# Edit files in VS Code
# Example: frontend/src/app/components/admin-dashboard/admin-dashboard.component.ts
```

### **Step 2: Test Locally**
```powershell
# Terminal 1 - Backend
cd "c:\Marketing Form\backend"
dotnet run

# Terminal 2 - Frontend
cd "c:\Marketing Form\frontend"
npm start

# Open: http://localhost:4200
# Verify your changes work
```

### **Step 3: Commit & Push**
```powershell
cd "c:\Marketing Form"

# Check what changed
git status

# Add all changes
git add .

# Commit with good message
git commit -m "feat: add export to Excel functionality"

# Push to GitHub
git push origin main
```

### **Step 4: Wait for Auto-Deploy**
```
GitHub receives push
  ↓
Netlify detects change → Builds frontend (2-3 min)
Render detects change → Builds backend (3-5 min)
  ↓
✅ LIVE on production!
```

### **Step 5: Verify Production**
```
Visit: https://marketing-task-management.netlify.app
Test your new feature
Check Render logs for errors (if any)
```

**✅ DONE!**

---

## 🔧 UPDATE SCENARIOS

### **Scenario 1: Frontend-Only Change (UI, HTML, CSS)**

**Example:** Change dashboard color scheme

```powershell
# 1. Edit files
# frontend/src/app/components/admin-dashboard/admin-dashboard.component.css

# 2. Test locally
cd frontend
npm start

# 3. Commit
git add frontend/
git commit -m "style: update admin dashboard color scheme"
git push origin main

# 4. Only Netlify rebuilds (backend unchanged)
```

---

### **Scenario 2: Backend-Only Change (API Logic)**

**Example:** Add validation to task creation

```powershell
# 1. Edit backend file
# backend/Controllers/TasksController.cs

# 2. Test locally
cd backend
dotnet run

# Test API with Postman/browser

# 3. Commit
git add backend/
git commit -m "feat: add validation for task due date"
git push origin main

# 4. Only Render rebuilds (frontend unchanged)
```

---

### **Scenario 3: Full-Stack Change (Frontend + Backend)**

**Example:** Add new "Priority" field to tasks

**Step 1: Update Database**
```sql
-- Connect to Azure SQL via SSMS
-- Run this script:
ALTER TABLE MarketingTasks ADD Priority VARCHAR(20);
```

**Step 2: Update Backend Model**
```csharp
// backend/Models/MarketingTask.cs
public class MarketingTask
{
    // ... existing properties
    
    public string? Priority { get; set; }  // ← Add this
}
```

**Step 3: Update Backend Controller (if needed)**
```csharp
// backend/Controllers/TasksController.cs
// Make sure Priority is included in DTOs
```

**Step 4: Update Frontend Model**
```typescript
// frontend/src/app/models/task.model.ts
export interface Task {
  // ... existing fields
  priority?: string;  // ← Add this
}
```

**Step 5: Update Frontend UI**
```html
<!-- frontend/src/app/components/admin-task-modal/admin-task-modal.component.html -->
<div class="form-group">
  <label>Priority</label>
  <select formControlName="priority" class="form-control">
    <option value="Low">Low</option>
    <option value="Medium">Medium</option>
    <option value="High">High</option>
  </select>
</div>
```

```typescript
// admin-task-modal.component.ts
this.taskForm = this.fb.group({
  // ... existing controls
  priority: ['Medium', Validators.required]
});
```

**Step 6: Test Locally**
```powershell
# Backend
cd backend
dotnet run

# Frontend
cd frontend
npm start

# Test creating task with priority field
```

**Step 7: Commit & Push**
```powershell
git add .
git commit -m "feat: add priority field to tasks

- Added Priority column to MarketingTasks table
- Updated Task model in backend and frontend
- Added priority dropdown to task creation UI
- Default priority set to Medium"

git push origin main
```

**Step 8: Verify Production**
```
Wait 5 minutes for both frontend + backend to redeploy
Test on: https://marketing-task-management.netlify.app
Create a task with priority = High
Verify it saves to database
```

---

## 🗄️ DATABASE UPDATES

### **Safe Database Changes (Non-Breaking):**

**Adding a nullable column:**
```sql
-- Safe! Doesn't break existing code
ALTER TABLE MarketingTasks ADD Notes TEXT NULL;
```

**Adding a column with default value:**
```sql
-- Safe! Existing rows get default value
ALTER TABLE MarketingTasks ADD IsArchived BIT DEFAULT 0;
```

### **Breaking Database Changes (Requires Planning):**

**Renaming a column:**
```sql
-- ⚠️ BREAKING! Code expects old name

-- Step 1: Add new column
ALTER TABLE Users ADD FullName VARCHAR(200);

-- Step 2: Copy data
UPDATE Users SET FullName = FirstName + ' ' + LastName;

-- Step 3: Deploy code that uses FullName (not FirstName/LastName)
# Push code update

-- Step 4: AFTER code deployed, remove old columns
ALTER TABLE Users DROP COLUMN FirstName;
ALTER TABLE Users DROP COLUMN LastName;
```

**Best Practice:**
1. Make database changes backward-compatible if possible
2. Plan breaking changes during low-traffic periods
3. Test on local database first
4. Have rollback plan ready

---

## 🌿 COMMIT MESSAGE GUIDELINES

**Format:**
```
<type>: <short description>

<optional detailed explanation>
```

**Types:**

| Type | Use Case | Example |
|------|----------|---------|
| `feat` | New feature | `feat: add PDF export for tasks` |
| `fix` | Bug fix | `fix: resolve incorrect city dropdown in Gurgaon` |
| `style` | UI/CSS changes | `style: improve mobile responsiveness` |
| `refactor` | Code cleanup | `refactor: optimize location service queries` |
| `docs` | Documentation | `docs: update API documentation` |
| `chore` | Maintenance | `chore: update npm packages` |
| `test` | Tests | `test: add unit tests for auth service` |
| `perf` | Performance | `perf: reduce task list load time` |

**✅ Good Commits:**
```bash
git commit -m "feat: implement task priority filtering on dashboard"
git commit -m "fix: resolve CORS error for production frontend"
git commit -m "docs: add deployment troubleshooting section"
```

**❌ Bad Commits:**
```bash
git commit -m "changes"
git commit -m "fixed stuff"
git commit -m "update"
```

---

## 🚨 ROLLBACK (If Something Breaks)

### **Method 1: Revert Last Commit**
```powershell
# View recent commits
git log --oneline

# Output:
# abc1234 feat: add priority field (current - BROKEN)
# def5678 fix: resolve dropdown issue (this was working!)
# ghi9012 feat: add export feature

# Revert the broken commit
git revert abc1234

# Push
git push origin main

# Render & Netlify will auto-redeploy previous working version
```

### **Method 2: Rollback on Render (Backend)**
```bash
1. Go to: https://dashboard.render.com
2. Select: marketing-api service
3. Click: "Events" or "Deploys" tab
4. Find: Previous successful deploy
5. Click: "Rollback" or "Redeploy"

✅ Backend instantly reverts to previous version
```

### **Method 3: Rollback on Netlify (Frontend)**
```bash
1. Go to: https://app.netlify.com
2. Select: marketing-task-management site
3. Click: "Deploys" tab
4. Find: Previous "Published" deploy
5. Click deploy → "Publish deploy" button

✅ Frontend instantly reverts to previous version
```

---

## 📊 MONITORING YOUR DEPLOYMENT

### **Check Netlify Build Status:**
```bash
1. Netlify Dashboard → Site → Deploys
2. Look for:
   ✅ Published (green) = Success
   🟡 Building = In progress
   ❌ Failed (red) = Error

3. Click deploy to see build logs
```

**Common Netlify Errors:**
- `npm install failed` → Check `package.json` syntax
- `ng build failed` → Check TypeScript errors locally first
- `Module not found` → Missing dependency, run `npm install <package>` locally

### **Check Render Deployment Status:**
```bash
1. Render Dashboard → Service → Logs
2. Look for:
   ✅ "Your service is live 🎉"
   ❌ Red error messages

3. Common errors:
   - "Connection refused" → Database connection issue
   - "Missing environment variable" → Check env vars
   - "Build failed" → Check C# compilation errors
```

### **Check Application Health:**
```bash
# Backend health check
curl https://marketing-api.onrender.com/api/areas/states

# Should return JSON array of states

# Frontend health check
# Visit: https://marketing-task-management.netlify.app
# Should load login page
```

---

## 🔔 NOTIFICATIONS

### **Enable Email Notifications:**

**Netlify:**
```bash
1. Site settings → Build & deploy → Deploy notifications
2. Add notification → Email notification
3. Select: "Deploy failed" and "Deploy succeeded"
4. Enter your email
```

**Render:**
```bash
1. Dashboard → Account → Notifications
2. Enable:
   - Deploy failed
   - Service unhealthy
3. Add email address
```

---

## 💡 BEST PRACTICES

### **Before Every Push:**
- ✅ Test locally (both frontend + backend)
- ✅ Check browser console for errors
- ✅ Verify API calls work
- ✅ Write good commit message
- ✅ Review `git status` before committing

### **After Every Push:**
- ✅ Wait for deployment to complete (5 min)
- ✅ Test production site
- ✅ Check critical features:
  - Login works
  - Can create task
  - Dropdowns load
  - Data saves correctly
- ✅ Monitor logs for errors

### **Weekly Maintenance:**
- ✅ Check Azure SQL database size/cost
- ✅ Review Render/Netlify usage/logs
- ✅ Update npm packages (if security updates available)
- ✅ Backup database (manual export from Azure)

---

## 🎯 QUICK REFERENCE COMMANDS

```powershell
# ===== CHECK STATUS =====
git status                              # See what changed
git log --oneline                       # View recent commits
git diff                                # See exact changes

# ===== COMMIT & PUSH =====
git add .                               # Stage all changes
git add frontend/                       # Stage only frontend
git commit -m "type: description"       # Commit
git push origin main                    # Push to GitHub

# ===== UNDO CHANGES =====
git checkout -- filename.ts             # Discard local changes to file
git reset HEAD~1                        # Undo last commit (keep changes)
git revert abc1234                      # Revert specific commit

# ===== VIEW REMOTE =====
git remote -v                           # Show GitHub URL
git pull origin main                    # Get latest changes from GitHub

# ===== BRANCHES (Advanced) =====
git branch                              # List branches
git checkout -b feature-name            # Create new branch
git checkout main                       # Switch to main branch
git merge feature-name                  # Merge branch to main
```

---

## 🆘 TROUBLESHOOTING

### **Problem: Push rejected**
```
error: failed to push some refs to GitHub
```

**Solution:**
```powershell
# Someone else pushed changes (or you pushed from another machine)
git pull origin main     # Get latest changes
git push origin main     # Try again
```

### **Problem: Merge conflict**
```
CONFLICT (content): Merge conflict in file.ts
```

**Solution:**
```powershell
# Open conflicted file in VS Code
# Look for:
<<<<<<< HEAD
Your changes
=======
Their changes
>>>>>>> branch-name

# Choose which to keep, delete markers
# Then:
git add file.ts
git commit -m "fix: resolve merge conflict"
git push origin main
```

### **Problem: Deploy succeeded but app broken**
```
Netlify shows "Published" but site shows errors
```

**Solution:**
```powershell
# Check browser console (F12) for errors
# Common issues:
# 1. Environment variable wrong (check environment.prod.ts)
# 2. API URL typo
# 3. CORS not configured

# Fix locally, test, then push again
```

### **Problem: Database changes not reflecting**
```
Code updated but old data structure still in use
```

**Solution:**
```sql
-- Verify on Azure SQL:
-- Connect via SSMS to: your-server.database.windows.net
SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'MarketingTasks';

-- If column missing, run ALTER TABLE script again
```

---

## 📞 NEED HELP?

**Error Logs:**
- Netlify: Dashboard → Deploys → Click deploy → View logs
- Render: Dashboard → Service → Logs tab
- Browser: F12 → Console tab

**Documentation:**
- `GITHUB_DEPLOYMENT_GUIDE.md` - Full deployment guide
- `DEPLOYMENT_CHECKLIST.md` - Checklist for deployment
- `DEVELOPER_GUIDE.md` - Coding guidelines
- `API_DOCUMENTATION.md` - API reference

**Platform Support:**
- Netlify: https://docs.netlify.com
- Render: https://render.com/docs
- Azure: https://learn.microsoft.com/azure

---

**Happy Coding! Keep pushing updates and improving your app! 🚀**

_Last Updated: December 2025_
