# 📋 MARKETING TASK MANAGEMENT SYSTEM

## 🎯 Project Overview

A comprehensive full-stack web application for managing marketing campaigns and field tasks. Built with Angular (Frontend) and .NET 8 (Backend), this system enables admins to create and assign tasks to employees, track progress in real-time, and manage marketing campaigns with a hierarchical location-based structure.

**GitHub Repository:** https://github.com/aman7506/marketing-task-management

---

## 🏗️ Technology Stack

### **Frontend:**
- **Framework:** Angular 17
- **Language:** TypeScript
- **Styling:** CSS (Custom styles)
- **Maps:** Leaflet.js
- **Real-time:** SignalR Client

### **Backend:**
- **Framework:** ASP.NET Core 8.0 (Web API)
- **Language:** C# 12
- **Database:** SQL Server
- **ORM:** Entity Framework Core 8
- **Authentication:** JWT Bearer Tokens
- **Real-time:** SignalR
- **Password:** BCrypt.Net

### **Database:**
- **DBMS:** Microsoft SQL Server
- **Database Name:** `marketing_db`
- **Approach:** Code-First with Stored Procedures

---

## 📁 Project Structure

```
Marketing Form/
│
├── 📂 backend/                      # .NET 8 Web API
│   ├── Controllers/                 # API Controllers
│   │   ├── AreasController.cs      # Location management
│   │   ├── AuthController.cs       # Authentication
│   │   ├── TasksController.cs      # Task management
│   │   └── UsersController.cs      # User management
│   │
│   ├── Models/                      # Entity models
│   │   ├── User.cs                 # User entity
│   │   ├── MarketingTask.cs        # Task entity
│   │   ├── MarketingCampaign.cs    # Campaign entity
│   │   ├── State.cs, City.cs, etc. # Location entities
│   │   └── DTOs/                   # Data Transfer Objects
│   │
│   ├── Services/                    # Business logic
│   │   ├── ITaskService.cs         # Task service interface
│   │   ├── TaskService.cs          # Task service implementation
│   │   └── NotificationHub.cs      # SignalR hub
│   │
│   ├── Data/                        # Database context
│   │   └── MarketingTaskDbContext.cs
│   │
│   ├── appsettings.json            # Configuration
│   ├── Program.cs                  # Application entry point
│   └── web.config                  # IIS configuration
│
├── 📂 frontend/                     # Angular 17 Application
│   ├── src/
│   │   ├── app/
│   │   │   ├── components/         # UI Components
│   │   │   │   ├── admin-dashboard/
│   │   │   │   ├── employee-dashboard/
│   │   │   │   ├── login/
│   │   │   │   ├── marketing-form/
│   │   │   │   └── admin-task-modal/
│   │   │   │
│   │   │   ├── services/           # Angular Services
│   │   │   │   ├── auth.service.ts
│   │   │   │   ├── task.service.ts
│   │   │   │   ├── notification.service.ts
│   │   │   │   └── location.service.ts
│   │   │   │
│   │   │   ├── guards/             # Route Guards
│   │   │   │   └── auth.guard.ts
│   │   │   │
│   │   │   ├── interceptors/       # HTTP Interceptors
│   │   │   │   └── auth.interceptor.ts
│   │   │   │
│   │   │   ├── models/             # TypeScript Interfaces
│   │   │   │   ├── user.model.ts
│   │   │   │   ├── task.model.ts
│   │   │   │   └── location.model.ts
│   │   │   │
│   │   │   └── app.routes.ts       # Route configuration
│   │   │
│   │   ├── assets/                 # Static assets
│   │   │   └── images/
│   │   │
│   │   └── environments/           # Environment configs
│   │       ├── environment.ts
│   │       └── environment.prod.ts
│   │
│   ├── angular.json                # Angular CLI config
│   ├── package.json                # NPM dependencies
│   └── tsconfig.json               # TypeScript config
│
├── 📂 database/                     # SQL Scripts
│   ├── 01_Create_Database.sql      # Database creation
│   ├── 02_Create_Tables.sql        # Table schemas
│   ├── 03_Insert_Sample_Data.sql   # Initial data
│   ├── 04_Stored_Procedures.sql    # Stored procedures
│   └── 05_Location_Hierarchy.sql   # Location data
│
├── 📂 Batch Files/                  # Quick start scripts
│   ├── AUTO_START.bat              # Start both (recommended)
│   ├── START_BACKEND.bat           # Backend only
│   ├── START_FRONTEND.bat          # Frontend only
│   └── start-clean-publish.ps1     # IIS deployment
│
└── 📄 Documentation/
    ├── README.md                    # This file
    ├── DEVELOPER_GUIDE.md           # Development guide
    ├── API_DOCUMENTATION.md         # API endpoints
    ├── DATABASE_SCHEMA.md           # Database structure
    └── DEPLOYMENT_GUIDE.md          # Deployment instructions
```

---

## 🚀 Quick Start

### **Prerequisites:**
1. ✅ Node.js 18+ and npm
2. ✅ .NET 8 SDK
3. ✅ SQL Server (Local or Remote)
4. ✅ Visual Studio Code (recommended)

### **Installation:**

```bash
# 1. Clone/Copy project
cd "c:\Marketing Form"

# 2. Backend setup
cd backend
dotnet restore
dotnet build

# 3. Frontend setup
cd ../frontend
npm install
npm run build

# 4. Database setup
# Run SQL scripts in order (01, 02, 03, 04, 05)
# Update connection string in backend/appsettings.json
```

### **Running the Application:**

**Option 1: Quick Start (Recommended)**
```bash
Double-click: AUTO_START.bat
```

**Option 2: Manual Start**
```bash
# Terminal 1 - Backend
cd backend
dotnet run

# Terminal 2 - Frontend
cd frontend
ng serve
```

**Access:**
- Frontend: http://localhost:4200
- Backend API: http://localhost:5005
- Swagger: http://localhost:5005/swagger

---

## 🔑 Default Credentials

**Admin:**
- Email: `admin@actionmedical.com`
- Password: `Admin123!`

**Employee (Test):**
- Email: (from database)
- Password: `Employee123!`

---

## 🎨 Key Features

### **Admin Portal:**
- ✅ Task Creation & Assignment
- ✅ Employee Management
- ✅ Marketing Campaign Management
- ✅ Task Status Tracking
- ✅ Real-time Notifications
- ✅ Location-based Task Assignment
- ✅ Task Rescheduling
- ✅ Dashboard Analytics

### **Employee Portal:**
- ✅ View Assigned Tasks
- ✅ Update Task Status
- ✅ Submit Task Feedback
- ✅ View Task History
- ✅ Real-time Task Updates
- ✅ Print Task Details

### **Location Hierarchy:**
- **State** → **City** → **Locality** → **Pincode**
- Complete India location data
- Cascading dropdowns
- Location-based filtering

---

## 📊 Database Schema

**Core Tables:**
- `Users` - User accounts (Admins & Employees)
- `MarketingTasks` - Task information
- `MarketingCampaigns` - Campaign data
- `States` - State master
- `Cities` - City master
- `Localities` - Locality master
- `Pincodes` - Pincode master
- `TaskStatusHistory` - Task status audit trail

**See:** `DATABASE_SCHEMA.md` for detailed schema

---

## 🔌 API Endpoints

**Authentication:**
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration

**Tasks:**
- `GET /api/tasks` - Get all tasks
- `GET /api/tasks/{id}` - Get task by ID
- `POST /api/tasks` - Create task
- `PUT /api/tasks/{id}` - Update task
- `PUT /api/tasks/{id}/status` - Update task status
- `POST /api/tasks/{id}/reschedule` - Reschedule task

**Users:**
- `GET /api/users` - Get all users
- `GET /api/users/employees` - Get employees only

**Locations:**
- `GET /api/areas/states` - Get states
- `GET /api/areas/cities/{stateId}` - Get cities by state
- `GET /api/areas/localities/{cityId}` - Get localities
- `GET /api/areas/pincodes/{localityId}` - Get pincodes

**See:** `API_DOCUMENTATION.md` for complete API reference

---

## 🛠️ Development Guidelines

### **Code Standards:**
- ✅ Use meaningful variable names
- ✅ Follow C# naming conventions (PascalCase for classes/methods)
- ✅ Follow TypeScript conventions (camelCase for variables)
- ✅ Add explanatory comments for complex logic
- ✅ Keep functions small and focused
- ✅ Use async/await for async operations

### **File Naming:**
- Components: `component-name.component.ts`
- Services: `service-name.service.ts`
- Models: `model-name.model.ts`
- Controllers: `EntityController.cs`

### **Component Structure:**
```typescript
// Import section
import { Component } from '@angular/core';

// Component decorator
@Component({
  selector: 'app-component-name',
  templateUrl: './component-name.component.html',
  styleUrls: ['./component-name.component.css']
})

// Component class
export class ComponentNameComponent {
  // Properties
  // Constructor
  // Lifecycle hooks (ngOnInit, etc.)
  // Public methods
  // Private methods
}
```

---

## 📝 Common Modifications

### **Adding a New Field to Task:**

**1. Update Database:**
```sql
ALTER TABLE MarketingTasks ADD NewField VARCHAR(100);
```

**2. Update Backend Model:**
```csharp
// Models/MarketingTask.cs
public string? NewField { get; set; }
```

**3. Update Frontend Model:**
```typescript
// models/task.model.ts
export interface Task {
  // ... existing fields
  newField?: string;
}
```

**4. Update UI:**
```html
<!-- Add to form -->
<input [(ngModel)]="task.newField" />
```

### **Adding a New API Endpoint:**

**Backend:**
```csharp
// Controllers/TasksController.cs
[HttpGet("custom-endpoint")]
public async Task<IActionResult> CustomEndpoint()
{
    // Your logic
    return Ok(result);
}
```

**Frontend Service:**
```typescript
// services/task.service.ts
customEndpoint(): Observable<any> {
  return this.http.get(`${this.apiUrl}/custom-endpoint`);
}
```

---

## 🐛 Troubleshooting

### **Backend not starting:**
```bash
# Check if port 5005 is in use
netstat -ano | findstr :5005

# Kill process if needed
taskkill /F /PID <PID>
```

### **Frontend compilation errors:**
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

### **Database connection issues:**
- Check SQL Server is running
- Verify connection string in `appsettings.json`
- Test connection with SQL Server Management Studio

---

## 🚀 Deployment & GitHub

**Ready to Deploy?** Complete guides available:

- **[GITHUB_DEPLOYMENT_GUIDE.md](./GITHUB_DEPLOYMENT_GUIDE.md)** - Complete guide: Git setup → GitHub → Production deployment
- **[DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)** - Step-by-step deployment checklist
- **[QUICK_UPDATE_GUIDE.md](./QUICK_UPDATE_GUIDE.md)** - How to update your deployed app
- **[PRODUCTION_READINESS_GUIDE.md](./PRODUCTION_READINESS_GUIDE.md)** - Security, performance, monitoring

**Quick Start Deployment:**
1. Follow `GITHUB_DEPLOYMENT_GUIDE.md` (30-60 minutes)
2. Use `DEPLOYMENT_CHECKLIST.md` to track progress
3. Deploy to:
   - Frontend: Netlify (Free)
   - Backend: Render (Free tier available)
   - Database: Azure SQL ($5-15/month)

---

## 📚 Additional Documentation

- **[DEVELOPER_GUIDE.md](./DEVELOPER_GUIDE.md)** - Detailed development guide
- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** - Complete API reference
- **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** - Database structure
- **[DOCUMENTATION_GUIDE.md](./DOCUMENTATION_GUIDE.md)** - How to maintain docs

---

## 📞 Support & Maintenance

**For Issues:**
1. Check logs in backend terminal
2. Check browser console for frontend errors  
3. Check SQL Server error logs
4. Review this documentation

**For Updates:**
1. Backend: Update NuGet packages
2. Frontend: Update npm packages
3. Test thoroughly after updates

---

## ✅ Project Status

**Version:** 1.0.0  
**Status:** Production Ready  
**Last Updated:** December 2025

**Features Complete:**
- ✅ Authentication & Authorization
- ✅ Task Management
- ✅ Location Hierarchy
- ✅ Real-time Notifications
- ✅ Responsive UI
- ✅ Print Functionality
- ✅ Task Rescheduling

---

**Happy Coding! 🚀**
