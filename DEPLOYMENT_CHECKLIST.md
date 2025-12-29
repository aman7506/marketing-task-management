# 📋 DEPLOYMENT CHECKLIST
## Marketing Task Management System - Production Deployment

---

## ✅ PRE-DEPLOYMENT CHECKLIST

### **1. CODE PREPARATION**
- [ ] All features tested locally
- [ ] Frontend runs without errors (`npm start`)
- [ ] Backend runs without errors (`dotnet run`)
- [ ] Database connection works
- [ ] No console errors in browser
- [ ] State → City → Locality → Pincode dropdowns work
- [ ] Task creation/viewing works
- [ ] Marketing campaign form works
- [ ] Login/logout works

### **2. SENSITIVE FILES SECURED**
- [ ] `.gitignore` files created (root, frontend, backend)
- [ ] `appsettings.json` added to `.gitignore`
- [ ] `appsettings.json.example` template created (with placeholder values)
- [ ] `environment.prod.ts` has correct structure (will update URL later)
- [ ] No passwords in any committed files
- [ ] No API keys hardcoded

### **3. DOCUMENTATION**
- [ ] README.md updated with project overview
- [ ] API_DOCUMENTATION.md exists
- [ ] DATABASE_SCHEMA.md exists
- [ ] DEVELOPER_GUIDE.md exists

---

## 🐙 GITHUB SETUP CHECKLIST

### **4. GIT INITIALIZATION**
```powershell
cd "c:\Marketing Form"
git init
git add .
git status  # Verify no sensitive files are staged
git commit -m "Initial commit: Marketing Task Management System v1.0"
```

**Verification:**
- [ ] Git initialized successfully
- [ ] First commit created
- [ ] `git status` shows clean working tree

### **5. GITHUB REPOSITORY CREATION**
- [ ] GitHub account created/logged in
- [ ] New repository created: `marketing-task-management`
- [ ] Visibility set to **Private** (recommended for business)
- [ ] **DO NOT** initialize with README/gitignore (already have them)
- [ ] Repository URL copied (e.g., `https://github.com/USERNAME/marketing-task-management.git`)

### **6. PUSH TO GITHUB**
```powershell
git remote add origin https://github.com/YOUR_USERNAME/marketing-task-management.git
git branch -M main
git push -u origin main
```

**Verification:**
- [ ] Code pushed to GitHub successfully
- [ ] All folders visible on GitHub (frontend, backend, database)
- [ ] Sensitive files NOT visible on GitHub (check `appsettings.json` is missing)

---

## 🗄️ DATABASE DEPLOYMENT CHECKLIST

### **7. AZURE SQL DATABASE SETUP**
- [ ] Azure account created (free tier with $200 credit)
- [ ] SQL Server created:
  - Name: `marketing-api-server` (or custom name)
  - Location: Southeast Asia / East US
  - Admin username: `sqladmin` (or custom)
  - Password: **STRONG PASSWORD SAVED SECURELY**
- [ ] SQL Database created:
  - Name: `marketing_db`
  - Pricing tier: Basic (5 DTUs) or Standard S0 (10 DTUs)
- [ ] Firewall configured:
  - [ ] Current client IP added
  - [ ] "Allow Azure services" enabled
- [ ] Connection string copied and saved:
  ```
  Server=tcp:YOUR-SERVER.database.windows.net,1433;
  Initial Catalog=marketing_db;
  User ID=sqladmin;
  Password=YOUR_PASSWORD;
  MultipleActiveResultSets=True;
  Encrypt=True;
  TrustServerCertificate=False;
  ```

### **8. DATABASE MIGRATION**
- [ ] Connected to Azure SQL via SSMS/Azure Data Studio
- [ ] Ran database scripts in order:
  - [ ] `00_Complete_Database_Setup.sql`
  - [ ] `03_HierarchicalLocationData.sql`
  - [ ] `03_StoredProcedures.sql`
  - [ ] `01_SeedData.sql`
- [ ] Verified data:
  - [ ] `SELECT COUNT(*) FROM Users;` returns users
  - [ ] `SELECT COUNT(*) FROM States;` returns 36
  - [ ] `SELECT COUNT(*) FROM Cities;` returns multiple cities
  - [ ] Stored procedures exist: `sp_save_marketing_campaign`, `sp_InsertTask`, etc.

---

## 🚀 BACKEND DEPLOYMENT CHECKLIST

### **9. RENDER ACCOUNT & SERVICE SETUP**
- [ ] Render account created: https://render.com
- [ ] Signed up with GitHub account
- [ ] GitHub repository authorized for Render

### **10. BACKEND WEB SERVICE CREATION**
- [ ] New Web Service created
- [ ] Repository connected: `marketing-task-management`
- [ ] Configuration:
  - Name: `marketing-api`
  - Region: Singapore / Oregon
  - Branch: `main`
  - Root Directory: `backend`
  - Runtime: **.NET**
  - Build Command: `dotnet publish -c Release -o ./publish`
  - Start Command: `dotnet ./publish/MarketingTaskAPI.dll`
  - Instance Type: **Free** (to start) or **Starter** ($7/month for production)

### **11. BACKEND ENVIRONMENT VARIABLES**
Added all required environment variables on Render:

| Variable | Value | Status |
|----------|-------|--------|
| `ConnectionStrings__DefaultConnection` | [Azure SQL connection string] | [ ] |
| `Jwt__Key` | [64-char random string] | [ ] |
| `Jwt__Issuer` | `ActionMedicalInstitute` | [ ] |
| `Jwt__Audience` | `MarketingTaskUsers` | [ ] |
| `Jwt__ExpirationHours` | `24` | [ ] |
| `ASPNETCORE_ENVIRONMENT` | `Production` | [ ] |
| `ASPNETCORE_URLS` | `http://0.0.0.0:$PORT` | [ ] |
| `Cors__AllowedOrigins__0` | [Will add after frontend deploy] | [ ] |

**Security Check:**
- [ ] Connection string includes correct Azure SQL server
- [ ] Password in connection string is correct
- [ ] JWT Key is strong (64+ characters, random)
- [ ] All values entered correctly (no typos!)

### **12. BACKEND DEPLOYMENT & VERIFICATION**
- [ ] Service deployed successfully (build log shows "Your service is live 🎉")
- [ ] Backend URL copied: `https://marketing-api.onrender.com` (or similar)
- [ ] Health checks passed:
  - [ ] `https://marketing-api.onrender.com/` returns response
  - [ ] `https://marketing-api.onrender.com/swagger` loads Swagger UI
  - [ ] `https://marketing-api.onrender.com/api/areas/states` returns JSON array
- [ ] No errors in Render logs

---

## 🌐 FRONTEND DEPLOYMENT CHECKLIST

### **13. FRONTEND PREPARATION**
- [ ] Production environment updated:
  
  Edit `frontend/src/environments/environment.prod.ts`:
  ```typescript
  const serverBaseUrl = 'https://marketing-api.onrender.com'; // ← YOUR BACKEND URL
  
  export const environment = {
    production: true,
    backendBaseUrl: serverBaseUrl,
    apiUrl: `${serverBaseUrl}/api`,
    apiBaseUrl: `${serverBaseUrl}/api`,
    signalRHubUrl: `${serverBaseUrl}/notificationHub`,
    trackingHubUrl: `${serverBaseUrl}/trackingHub`,
    lanTrackingHubUrl: `${serverBaseUrl}/trackingHub`
  };
  ```

- [ ] Netlify redirect rule created:
  - [ ] File `frontend/src/_redirects` created with content: `/* /index.html 200`
  - [ ] `angular.json` updated to include `src/_redirects` in assets array

- [ ] Changes committed and pushed:
  ```powershell
  git add frontend/src/environments/environment.prod.ts frontend/src/_redirects frontend/angular.json
  git commit -m "feat: configure production environment for deployment"
  git push origin main
  ```

### **14. NETLIFY ACCOUNT & SITE SETUP**
- [ ] Netlify account created: https://netlify.com
- [ ] Signed up with GitHub account
- [ ] GitHub repository authorized for Netlify

### **15. FRONTEND SITE DEPLOYMENT**
- [ ] New Site created from Git
- [ ] Repository connected: `marketing-task-management`
- [ ] Build Configuration:
  - Base directory: `frontend`
  - Build command: `npm run build`
  - Publish directory: `frontend/dist/marketing-form/browser`
  - Node version: 18 (set in environment variables if needed)
- [ ] Site deployed successfully
- [ ] Site name customized: `marketing-task-management` (or custom name)
- [ ] Frontend URL saved: `https://marketing-task-management.netlify.app`

### **16. FRONTEND VERIFICATION**
- [ ] Frontend loads at deployed URL
- [ ] Login page displays correctly
- [ ] No console errors in browser DevTools (F12)
- [ ] Static pages load (before testing API calls)

---

## 🔗 FRONTEND-BACKEND CONNECTION CHECKLIST

### **17. CORS CONFIGURATION**
- [ ] Backend updated with frontend URL:
  - Render Dashboard → Environment tab
  - Add/Update: `Cors__AllowedOrigins__0` = `https://marketing-task-management.netlify.app`
  - Service auto-redeployed

### **18. END-TO-END CONNECTION TEST**
- [ ] Browser console test (on frontend site):
  ```javascript
  fetch('https://marketing-api.onrender.com/api/areas/states')
    .then(res => res.json())
    .then(data => console.log(data));
  ```
  - [ ] Returns JSON array (no CORS error)

---

## 🧪 FULL APPLICATION TESTING CHECKLIST

### **19. AUTHENTICATION**
- [ ] Login page loads
- [ ] Can login as Admin (`admin@actionmedical.com` / `Admin123!`)
- [ ] JWT token stored in browser (check localStorage in DevTools)
- [ ] Invalid credentials show error message
- [ ] Can logout successfully

### **20. ADMIN DASHBOARD**
- [ ] Dashboard loads after login
- [ ] Statistics tiles show data
- [ ] Task list loads
- [ ] Can filter tasks by status
- [ ] All UI elements render correctly

### **21. CREATE TASK**
- [ ] Task creation modal/form opens
- [ ] **Employee dropdown** loads from API
- [ ] **State dropdown** loads
- [ ] Selecting state loads **Cities**
- [ ] Selecting city loads **Localities**
- [ ] Selecting locality loads **Pincodes**
- [ ] Can fill all fields
- [ ] Submit button works
- [ ] Success message appears
- [ ] New task appears in task list
- [ ] Check backend logs (Render) for successful API call

### **22. MARKETING CAMPAIGN FORM**
- [ ] Form loads
- [ ] Location hierarchy works (State → City → Locality → Pincode)
- [ ] Can fill: Campaign Name, Mobile, Date, Time, Location details
- [ ] Submit saves data (success message)
- [ ] Can view saved campaigns (if view page exists)

### **23. EMPLOYEE DASHBOARD** (If accessible)
- [ ] Can login as employee
- [ ] Assigned tasks appear
- [ ] Can update task status (Not Started → In Progress → Completed)
- [ ] Changes reflect in database

### **24. REAL-TIME FEATURES** (SignalR)
- [ ] Admin creates task
- [ ] Employee dashboard updates without refresh (if SignalR implemented)
- [ ] Check browser console for SignalR connection messages

### **25. ERROR HANDLING**
- [ ] Network errors show user-friendly messages (not raw JSON)
- [ ] Invalid form submissions show validation errors
- [ ] 401 errors redirect to login
- [ ] API timeouts handled gracefully

---

## 🔒 SECURITY & PRODUCTION CHECKLIST

### **26. SECURITY VERIFICATION**
- [ ] All secrets in environment variables (not in Git)
- [ ] `appsettings.json` NOT committed to GitHub
- [ ] HTTPS enabled on frontend (Netlify auto-provides)
- [ ] HTTPS enabled on backend (Render auto-provides)
- [ ] CORS allows ONLY your frontend domain (not `*`)
- [ ] JWT expiration set (24 hours)
- [ ] SQL Server firewall configured (Azure services + your IP only)
- [ ] Passwords are strong (checked with password strength tool)

### **27. PERFORMANCE OPTIMIZATION**
- [ ] Frontend build uses production mode (`ng build` with optimizations)
- [ ] Backend uses `Release` configuration
- [ ] Database uses connection pooling
- [ ] Async/await used in all API methods
- [ ] Large API responses are paginated (if applicable)

### **28. MONITORING SETUP**
- [ ] Render email notifications enabled (deploy failures, errors)
- [ ] Netlify notifications enabled
- [ ] Azure SQL alerts configured (DTU usage, storage)
- [ ] Health check endpoint works: `/health` or custom endpoint
- [ ] Logs reviewed for errors (Render Logs tab)

### **29. BACKUP & RECOVERY**
- [ ] Azure SQL automatic backups verified (check Azure Portal)
- [ ] Manual database export completed (.bacpac file downloaded)
- [ ] GitHub repository backed up (cloned to local machine)
- [ ] Environment variables documented in secure location (password manager)
- [ ] Disaster recovery plan documented

---

## 📝 POST-DEPLOYMENT CHECKLIST

### **30. DOCUMENTATION UPDATES**
- [ ] README.md updated with:
  - [ ] Live frontend URL
  - [ ] Live backend API URL
  - [ ] Deployment date
- [ ] GITHUB_DEPLOYMENT_GUIDE.md available for future reference
- [ ] Team members notified (if applicable)

### **31. CREDENTIALS & KEYS SAVED**
- [ ] Azure SQL Server connection string (in password manager)
- [ ] Azure SQL admin password
- [ ] JWT Secret Key
- [ ] GitHub repository URL
- [ ] Render dashboard URL
- [ ] Netlify dashboard URL
- [ ] All credentials stored securely (NOT in plain text files!)

### **32. LIVE URLs DOCUMENTED**
```
✅ Frontend URL:  https://marketing-task-management.netlify.app
✅ Backend API:   https://marketing-api.onrender.com
✅ Swagger Docs:  https://marketing-api.onrender.com/swagger
✅ GitHub Repo:   https://github.com/YOUR_USERNAME/marketing-task-management
✅ Database:      marketing-api-server.database.windows.net
```

---

## 🚀 FUTURE UPDATES WORKFLOW CHECKLIST

### **33. FOR EACH CODE UPDATE**
- [ ] Make changes locally
- [ ] Test locally (frontend + backend)
- [ ] Verify no breaking changes
- [ ] Commit with descriptive message (`feat:`, `fix:`, `docs:`, etc.)
- [ ] Push to GitHub: `git push origin main`
- [ ] Wait for auto-deploy (2-5 minutes)
- [ ] Test on production site
- [ ] Monitor logs for errors
- [ ] If errors, rollback immediately

### **34. FOR DATABASE SCHEMA CHANGES**
- [ ] Plan schema change (document impact)
- [ ] Test on local database first
- [ ] Run SQL script on Azure SQL via SSMS
- [ ] Update backend models/code
- [ ] Update frontend models/code
- [ ] Deploy backend (auto-deploy)
- [ ] Deploy frontend (auto-deploy)
- [ ] Test end-to-end
- [ ] Document change in DATABASE_SCHEMA.md

---

## 🎯 FINAL VERIFICATION (GO-LIVE CHECKLIST)

### **ALL SYSTEMS CHECK:**
- [ ] ✅ **Database:** Azure SQL accessible, data migrated
- [ ] ✅ **Backend:** Render service running, all endpoints work
- [ ] ✅ **Frontend:** Netlify site live, UI loads correctly
- [ ] ✅ **Connection:** Frontend can call backend API (CORS configured)
- [ ] ✅ **Authentication:** Login/logout works
- [ ] ✅ **Core Features:** Create task, marketing campaign, dropdowns work
- [ ] ✅ **Security:** All secrets in environment variables, HTTPS enabled
- [ ] ✅ **Monitoring:** Logs accessible, alerts configured
- [ ] ✅ **Backups:** Database backed up, code on GitHub
- [ ] ✅ **Documentation:** Updated with live URLs

### **STAKEHOLDER APPROVAL:**
- [ ] Demo completed for client/manager
- [ ] User acceptance testing passed
- [ ] Performance verified (load time < 3 seconds)
- [ ] Mobile responsiveness checked
- [ ] All critical bugs resolved

---

## 🎉 PROJECT IS LIVE!

**Congratulations!** Your Marketing Task Management System is now:
- ✅ **Deployed** (accessible from anywhere)
- ✅ **Secured** (HTTPS, secrets protected)
- ✅ **Backed up** (Azure SQL backups, code on GitHub)
- ✅ **Monitored** (logs, alerts)
- ✅ **Production-ready** (scalable, maintainable)

**Share Your Success:**
```
🌐 Frontend:  https://marketing-task-management.netlify.app
🔌 API:       https://marketing-api.onrender.com
📚 GitHub:    https://github.com/YOUR_USERNAME/marketing-task-management
```

**Next Steps:**
- [ ] Share URLs with team/client
- [ ] Add to portfolio/resume
- [ ] Monitor usage and performance
- [ ] Plan future enhancements
- [ ] Celebrate your achievement! 🎊

---

**Last Updated:** December 2025  
**Version:** 1.0  
**Status:** Production Ready ✅
