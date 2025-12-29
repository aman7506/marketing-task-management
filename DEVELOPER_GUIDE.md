# 👨‍💻 DEVELOPER GUIDE

## 📌 Table of Contents
1. [Development Setup](#development-setup)
2. [Project Architecture](#project-architecture)
3. [Backend Development](#backend-development)
4. [Frontend Development](#frontend-development)
5. [Database Management](#database-management)
6. [Common Tasks](#common-tasks)
7. [Best Practices](#best-practices)

---

## 🔧 Development Setup

### **1. Install Prerequisites**

```bash
# Node.js & npm
node --version  # Should be 18+
npm --version

# .NET SDK
dotnet --version  # Should be 8.0+

# SQL Server
# Use SQL Server Management Studio to verify
```

### **2. IDE Setup (VS Code Recommended)**

**Extensions:**
- C# Dev Kit
- Angular Language Service
- ESLint
- Prettier
- SQL Server (mssql)

### **3. Clone Project**

```bash
cd "c:\Marketing Form"
code .  # Open in VS Code
```

### **4. Backend Setup**

```bash
cd backend

# Restore NuGet packages
dotnet restore

# Build
dotnet build

# Run
dotnet run
```

**Backend will start on:** `http://localhost:5005`

### **5. Frontend Setup**

```bash
cd frontend

# Install npm packages
npm install

# Run development server
ng serve
```

**Frontend will start on:** `http://localhost:4200`

---

## 🏛️ Project Architecture

### **Architecture Pattern: N-Tier**

```
┌─────────────┐
│  Frontend   │  Angular SPA
│  (Angular)  │  
└──────┬──────┘
       │ HTTP/SignalR
┌──────▼──────┐
│   Backend   │  RESTful API
│  (.NET 8)   │  
└──────┬──────┘
       │ EF Core
┌──────▼──────┐
│  Database   │  SQL Server
│ (SQL Server)│  
└─────────────┘
```

### **Backend Layers:**

1. **Controllers** - HTTP endpoints
2. **Services** - Business logic
3. **Models** - Data entities
4. **Data** - Database context

### **Frontend Structure:**

1. **Components** - UI elements
2. **Services** - HTTP/SignalR communication
3. **Guards** - Route protection
4. **Interceptors** - HTTP middleware
5. **Models** - TypeScript interfaces

---

## 🎯 Backend Development

### **Creating a New Controller**

```csharp
// Controllers/ExampleController.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace MarketingTaskAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]  // Requires authentication
    public class ExampleController : ControllerBase
    {
        private readonly IExampleService _service;

        public ExampleController(IExampleService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var items = await _service.GetAllAsync();
            return Ok(items);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var item = await _service.GetByIdAsync(id);
            if (item == null) return NotFound();
            return Ok(item);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateDto dto)
        {
            var created = await _service.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateDto dto)
        {
            await _service.UpdateAsync(id, dto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }
    }
}
```

### **Creating a Service**

```csharp
// Services/IExampleService.cs
public interface IExampleService
{
    Task<List<ExampleDto>> GetAllAsync();
    Task<ExampleDto?> GetByIdAsync(int id);
    Task<ExampleDto> CreateAsync(CreateDto dto);
    Task UpdateAsync(int id, UpdateDto dto);
    Task DeleteAsync(int id);
}

// Services/ExampleService.cs
public class ExampleService : IExampleService
{
    private readonly MarketingTaskDbContext _context;

    public ExampleService(MarketingTaskDbContext context)
    {
        _context = context;
    }

    public async Task<List<ExampleDto>> GetAllAsync()
    {
        return await _context.Examples
            .Select(e => new ExampleDto
            {
                Id = e.Id,
                Name = e.Name
            })
            .ToListAsync();
    }

    // ... implement other methods
}
```

**Register in Program.cs:**
```csharp
builder.Services.AddScoped<IExampleService, ExampleService>();
```

### **Creating a Model**

```csharp
// Models/Example.cs
using System.ComponentModel.DataAnnotations;

namespace MarketingTaskAPI.Models
{
    public class Example
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public virtual User? CreatedBy { get; set; }
    }
}
```

**Add to DbContext:**
```csharp
// Data/MarketingTaskDbContext.cs
public DbSet<Example> Examples { get; set; }

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Example>(entity =>
    {
        entity.ToTable("Examples");
        entity.HasIndex(e => e.Name);
    });
}
```

---

## 🎨 Frontend Development

### **Creating a New Component**

```bash
cd frontend/src/app/components
ng generate component example
```

**Component Structure:**
```typescript
// example.component.ts
import { Component, OnInit } from '@angular/core';
import { ExampleService } from '../../services/example.service';

@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  styleUrls: ['./example.component.css']
})
export class ExampleComponent implements OnInit {
  items: Example[] = [];
  loading = false;

  constructor(private exampleService: ExampleService) {}

  ngOnInit(): void {
    this.loadItems();
  }

  loadItems(): void {
    this.loading = true;
    this.exampleService.getAll().subscribe({
      next: (data) => {
        this.items = data;
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading items:', error);
        this.loading = false;
      }
    });
  }

  createItem(item: Example): void {
    this.exampleService.create(item).subscribe({
      next: () => {
        this.loadItems();
      },
      error: (error) => console.error('Error creating item:', error)
    });
  }
}
```

### **Creating a Service**

```bash
cd frontend/src/app/services
ng generate service example
```

```typescript
// example.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface Example {
  id?: number;
  name: string;
  createdAt?: Date;
}

@Injectable({
  providedIn: 'root'
})
export class ExampleService {
  private apiUrl = `${environment.apiUrl}/example`;

  constructor(private http: HttpClient) {}

  getAll(): Observable<Example[]> {
    return this.http.get<Example[]>(this.apiUrl);
  }

  getById(id: number): Observable<Example> {
    return this.http.get<Example>(`${this.apiUrl}/${id}`);
  }

  create(item: Example): Observable<Example> {
    return this.http.post<Example>(this.apiUrl, item);
  }

  update(id: number, item: Example): Observable<void> {
    return this.http.put<void>(`${this.apiUrl}/${id}`, item);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
```

### **Adding a Route**

```typescript
// app.routes.ts
export const routes: Routes = [
  {
    path: 'example',
    component: ExampleComponent,
    canActivate: [AuthGuard]  // Protect route
  }
];
```

---

## 🗄️ Database Management

### **Adding a New Table**

**1. Create Migration Script:**
```sql
-- database/06_Add_Example_Table.sql
CREATE TABLE Examples (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NULL
);

CREATE INDEX IX_Examples_Name ON Examples(Name);
```

**2. Update DbContext:**
```csharp
public DbSet<Example> Examples { get; set; }
```

**3. Run Migration:**
```sql
-- Execute SQL script in SQL Server Management Studio
```

### **Creating Stored Procedure**

```sql
-- database/sp_GetExampleData.sql
CREATE PROCEDURE sp_GetExampleData
    @UserId INT
AS
BEGIN
    SELECT 
        e.Id,
        e.Name,
        e.CreatedAt
    FROM Examples e
    WHERE e.CreatedBy = @UserId
    ORDER BY e.CreatedAt DESC;
END
```

**Use in EF Core:**
```csharp
var results = await _context.Examples
    .FromSqlRaw("EXEC sp_GetExampleData @UserId = {0}", userId)
    .ToListAsync();
```

---

## 🔨 Common Tasks

### **Adding JWT Claims**

```csharp
// In AuthController.cs
var claims = new List<Claim>
{
    new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
    new Claim(ClaimTypes.Email, user.Email),
    new Claim(ClaimTypes.Role, user.Role),
    new Claim("CustomClaim", "CustomValue")  // Add custom claim
};
```

### **SignalR Real-time Updates**

**Backend Hub:**
```csharp
// Services/NotificationHub.cs
public async Task SendTaskUpdate(int taskId, string status)
{
    await Clients.All.SendAsync("ReceiveTaskUpdate", taskId, status);
}
```

**Frontend Component:**
```typescript
this.notificationService.hubConnection.on('ReceiveTaskUpdate', (taskId, status) => {
  console.log(`Task ${taskId} status: ${status}`);
  this.updateTaskInList(taskId, status);
});
```

### **File Upload**

**Backend:**
```csharp
[HttpPost("upload")]
public async Task<IActionResult> UploadFile(IFormFile file)
{
    var path = Path.Combine("uploads", file.FileName);
    using (var stream = new FileStream(path, FileMode.Create))
    {
        await file.CopyToAsync(stream);
    }
    return Ok(new { path });
}
```

**Frontend:**
```typescript
uploadFile(file: File): Observable<any> {
  const formData = new FormData();
  formData.append('file', file);
  return this.http.post(`${this.apiUrl}/upload`, formData);
}
```

---

## ✅ Best Practices

### **Backend:**
1. ✅ Always use async/await
2. ✅ Use DTOs for API responses
3. ✅ Validate input with Data Annotations
4. ✅ Handle exceptions properly
5. ✅ Use dependency injection
6. ✅ Keep controllers thin
7. ✅ Use meaningful HTTP status codes

### **Frontend:**
1. ✅ Unsubscribe from observables
2. ✅ Use async pipe when possible
3. ✅ Keep components focused
4. ✅ Use services for data access
5. ✅ Handle errors gracefully
6. ✅ Use TypeScript strict mode
7. ✅ Follow Angular style guide

### **Database:**
1. ✅ Use stored procedures for complex queries
2. ✅ Add indexes on frequently queried columns
3. ✅ Use transactions for multi-step operations
4. ✅ Backup regularly
5. ✅ Don't expose sensitive data

### **Git:**
1. ✅ Commit often with meaningful messages
2. ✅ Use feature branches
3. ✅ Don't commit secrets
4. ✅ Keep commits atomic

---

## 🐛 Debugging

### **Backend Debugging:**
```bash
# Run with detailed logging
dotnet run --configuration Debug
```

**Enable detailed EF logs:**
```csharp
optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information);
```

### **Frontend Debugging:**
```typescript
// Enable Angular debug mode
import { enableDebugTools } from '@angular/platform-browser';

// In main.ts for development
if (!environment.production) {
  enableDebugTools(appRef.components[0]);
}
```

---

## 📚 Resources

- **Angular Docs:** https://angular.dev
- **.NET Docs:** https://docs.microsoft.com/dotnet
- **EF Core:** https://docs.microsoft.com/ef/core
- **SQL Server:** https://docs.microsoft.com/sql

---

**Happy Development! 🚀**
