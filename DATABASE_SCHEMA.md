# 🗄️ DATABASE SCHEMA DOCUMENTATION

## Database Information

**Database Name:** `marketing_db`  
**DBMS:** Microsoft SQL Server  
**Version:** SQL Server 2019+  
**Collation:** SQL_Latin1_General_CP1_CI_AS

---

## 📊 Tables Overview

### Core Tables
1. **Users** - User accounts (Admin & Employees)
2. **MarketingTasks** - Task information
3. **MarketingCampaigns** - Marketing campaign data
4. **TaskStatusHistory** - Audit trail for task status changes

### Location Tables
5. **States** - Indian states
6. **Cities** - Cities within states
7. **Localities** - Localities within cities
8. **Pincodes** - PIN codes within localities

---

## 📋 Detailed Schema

### 1. Users

**Purpose:** Store user account information

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| Id | INT | PRIMARY KEY, IDENTITY | Unique user ID |
| Name | NVARCHAR(100) | NOT NULL | User's full name |
| Email | NVARCHAR(100) | NOT NULL, UNIQUE | Email address |
| PasswordHash | NVARCHAR(MAX) | NOT NULL | BCrypt hashed password |
| Role | NVARCHAR(20) | NOT NULL | "Admin" or "Employee" |
| PhoneNumber | NVARCHAR(15) | NULL | Contact number |
| IsActive | BIT | DEFAULT 1 | Account status |
| CreatedAt | DATETIME2 | DEFAULT GETDATE() | Account creation date |
| UpdatedAt | DATETIME2 | NULL | Last update date |

**Indexes:**
- `IX_Users_Email` (UNIQUE)
- `IX_Users_Role`

**Sample Data:**
```sql
INSERT INTO Users (Name, Email, PasswordHash, Role, PhoneNumber)
VALUES ('Admin User', 'admin@actionmedical.com', '<bcrypt_hash>', 'Admin', '9876543210');
```

---

### 2. MarketingTasks

**Purpose:** Store task assignments and details

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| Id | INT | PRIMARY KEY, IDENTITY | Unique task ID |
| TaskName | NVARCHAR(200) | NOT NULL | Task title |
| Description | NVARCHAR(MAX) | NULL | Detailed description |
| StateId | INT | FOREIGN KEY → States | State location |
| CityId | INT | FOREIGN KEY → Cities | City location |
| LocalityId | INT | FOREIGN KEY → Localities | Locality location |
| PincodeId | INT | FOREIGN KEY → Pincodes | Pincode location |
| AssignedToId | INT | FOREIGN KEY → Users | Assigned employee |
| CreatedById | INT | FOREIGN KEY → Users | Admin who created |
| Status | NVARCHAR(20) | NOT NULL | Task status |
| ScheduledDate | DATETIME2 | NOT NULL | Scheduled date/time |
| CompletedDate | DATETIME2 | NULL | Actual completion date |
| Feedback | NVARCHAR(MAX) | NULL | Employee feedback |
| CreatedAt | DATETIME2 | DEFAULT GETDATE() | Creation timestamp |
| UpdatedAt | DATETIME2 | NULL | Last update timestamp |

**Valid Status Values:**
- `Not Started`
- `In Progress`
- `Completed`
- `Cancelled`

**Indexes:**
- `IX_MarketingTasks_Status`
- `IX_MarketingTasks_AssignedToId`
- `IX_MarketingTasks_ScheduledDate`

**Foreign Keys:**
- `FK_MarketingTasks_States`
- `FK_MarketingTasks_Cities`
- `FK_MarketingTasks_Localities`
- `FK_MarketingTasks_Pincodes`
- `FK_MarketingTasks_AssignedTo`
- `FK_MarketingTasks_CreatedBy`

---

### 3. TaskStatusHistory

**Purpose:** Audit trail for all task status changes

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| Id | INT | PRIMARY KEY, IDENTITY | Unique record ID |
| TaskId | INT | FOREIGN KEY → MarketingTasks | Related task |
| OldStatus | NVARCHAR(20) | NULL | Previous status |
| NewStatus | NVARCHAR(20) | NOT NULL | New status |
| ChangedById | INT | FOREIGN KEY → Users | User who changed |
| ChangedAt | DATETIME2 | DEFAULT GETDATE() | Change timestamp |
| Remarks | NVARCHAR(500) | NULL | Change reason/notes |

**Indexes:**
- `IX_TaskStatusHistory_TaskId`
- `IX_TaskStatusHistory_ChangedAt`

---

### 4. MarketingCampaigns

**Purpose:** Store marketing campaign information

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| Id | INT | PRIMARY KEY, IDENTITY | Unique campaign ID |
| CampaignName | NVARCHAR(200) | NOT NULL | Campaign  name |
| Description | NVARCHAR(MAX) | NULL | Campaign details |
| StateId | INT | FOREIGN KEY → States | Target state |
| CityId | INT | NULL, FOREIGN KEY → Cities | Target city |
| LocalityId | INT | NULL, FOREIGN KEY → Localities | Target locality |
| PincodeId | INT | NULL, FOREIGN KEY → Pincodes | Target pincode |
| StartDate | DATETIME2 | NULL | Campaign start |
| EndDate | DATETIME2 | NULL | Campaign end |
| CreatedById | INT | FOREIGN KEY → Users | Creator user |
| CreatedAt | DATETIME2 | DEFAULT GETDATE() | Creation timestamp |

**Indexes:**
- `IX_MarketingCampaigns_StateId`
- `IX_MarketingCampaigns_StartDate`

---

### 5. States

**Purpose:** Master data for Indian states

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| Id | INT | PRIMARY KEY, IDENTITY | Unique state ID |
| Name | NVARCHAR(100) | NOT NULL, UNIQUE | State name |
| Code | NVARCHAR(10) | NULL | State code |

**Sample Data:**
- Delhi
- Maharashtra
- Karnataka
- Tamil Nadu
- (All Indian states)

---

### 6. Cities

**Purpose:** Cities within states

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| Id | INT | PRIMARY KEY, IDENTITY | Unique city ID |
| Name | NVARCHAR(100) | NOT NULL | City name |
| StateId | INT | FOREIGN KEY → States | Parent state |

**Indexes:**
- `IX_Cities_StateId`
- `IX_Cities_Name`

**Sample Data:**
- New Delhi (StateId: 1)
- Mumbai (StateId: 2)
- Bangalore (StateId: 3)

---

### 7. Localities

**Purpose:** Localities/areas within cities

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| Id | INT | PRIMARY KEY, IDENTITY | Unique locality ID |
| Name | NVARCHAR(100) | NOT NULL | Locality name |
| CityId | INT | FOREIGN KEY → Cities | Parent city |

**Indexes:**
- `IX_Localities_CityId`
- `IX_Localities_Name`

---

### 8. Pincodes

**Purpose:** PIN codes within localities

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| Id | INT | PRIMARY KEY, IDENTITY | Unique pincode ID |
| Pincode | NVARCHAR(10) | NOT NULL | 6-digit PIN code |
| LocalityId | INT | FOREIGN KEY → Localities | Parent locality |

**Indexes:**
- `IX_Pincodes_LocalityId`
- `IX_Pincodes_Pincode`

---

## 🔗 Relationships Diagram

```
States
  └── Cities
        └── Localities
              └── Pincodes

Users
  ├── MarketingTasks (AssignedTo)
  ├── MarketingTasks (CreatedBy)
  ├── MarketingCampaigns (CreatedBy)
  └── TaskStatusHistory (ChangedBy)

MarketingTasks
  ├── States, Cities, Localities, Pincodes
  └── TaskStatusHistory
```

---

## 📝 Stored Procedures

### sp_InsertTask

**Purpose:** Insert a new task with all location details

```sql
CREATE PROCEDURE sp_InsertTask
    @TaskName NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @StateId INT,
    @CityId INT,
    @LocalityId INT,
    @PincodeId INT,
    @AssignedToId INT,
    @CreatedById INT,
    @ScheduledDate DATETIME2
AS
BEGIN
    INSERT INTO MarketingTasks (
        TaskName, Description, StateId, CityId, 
        LocalityId, PincodeId, AssignedToId, CreatedById, 
        Status, ScheduledDate, CreatedAt
    )
    VALUES (
        @TaskName, @Description, @StateId, @CityId,
        @LocalityId, @PincodeId, @AssignedToId, @CreatedById,
        'Not Started', @ScheduledDate, GETDATE()
    );
    
    SELECT SCOPE_IDENTITY() AS NewTaskId;
END
```

### sp_UpdateTaskStatus

**Purpose:** Update task status and log to history

```sql
CREATE PROCEDURE sp_UpdateTaskStatus
    @TaskId INT,
    @NewStatus NVARCHAR(20),
    @ChangedById INT,
    @Feedback NVARCHAR(MAX) = NULL
AS
BEGIN
    DECLARE @OldStatus NVARCHAR(20);
    
    SELECT @OldStatus = Status FROM MarketingTasks WHERE Id = @TaskId;
    
    UPDATE MarketingTasks
    SET Status = @NewStatus,
        Feedback = COALESCE(@Feedback, Feedback),
        UpdatedAt = GETDATE(),
        CompletedDate = CASE WHEN @NewStatus = 'Completed' 
            THEN GETDATE() ELSE CompletedDate END
    WHERE Id = @TaskId;
    
    INSERT INTO TaskStatusHistory (TaskId, OldStatus, NewStatus, ChangedById, ChangedAt)
    VALUES (@TaskId, @OldStatus, @NewStatus, @ChangedById, GETDATE());
END
```

### sp_GetTasksByUser

**Purpose:** Get tasks assigned to a specific user

```sql
CREATE PROCEDURE sp_GetTasksByUser
    @UserId INT
AS
BEGIN
    SELECT 
        t.*,
        s.Name AS StateName,
        c.Name AS CityName,
        l.Name AS LocalityName,
        p.Pincode,
        u.Name AS AssignedToName
    FROM MarketingTasks t
    LEFT JOIN States s ON t.StateId = s.Id
    LEFT JOIN Cities c ON t.CityId = c.Id
    LEFT JOIN Localities l ON t.LocalityId = l.Id
    LEFT JOIN Pincodes p ON t.PincodeId = p.Id
    LEFT JOIN Users u ON t.AssignedToId = u.Id
    WHERE t.AssignedToId = @UserId
    ORDER BY t.ScheduledDate DESC;
END
```

---

## 🔐 Security Considerations

### Sensitive Data
- **PasswordHash**: Never return in API responses
- **Email**: Include only when authorized
- **PhoneNumber**: Mask when displaying to non-admins

### Data Validation
- Email must be unique
- Status values must be from enum
- Dates must be valid
- Foreign keys must exist

---

## 🗑️ Data Retention

**TaskStatusHistory:** Keep indefinitely for audit  
**Completed Tasks:** Archive after 1 year  
**Inactive Users:** Soft delete (IsActive = 0)

---

## 📊 Common Queries

### Get All Tasks with Full Details
```sql
SELECT 
    t.Id,
    t.TaskName,
    t.Status,
    s.Name AS State,
    c.Name AS City,
    l.Name AS Locality,
    p.Pincode,
    u.Name AS AssignedTo,
    t.ScheduledDate
FROM MarketingTasks t
LEFT JOIN States s ON t.StateId = s.Id
LEFT JOIN Cities c ON t.CityId = c.Id
LEFT JOIN Localities l ON t.LocalityId = l.Id
LEFT JOIN Pincodes p ON t.PincodeId = p.Id
LEFT JOIN Users u ON t.AssignedToId = u.Id
ORDER BY t.CreatedAt DESC;
```

### Get Task Status History
```sql
SELECT 
    h.*,
    u.Name AS ChangedByName
FROM TaskStatusHistory h
LEFT JOIN Users u ON h.ChangedById = u.Id
WHERE h.TaskId = @TaskId
ORDER BY h.ChangedAt DESC;
```

---

## 🔄 Migration Scripts

Located in: `database/` folder
- `01_Create_Database.sql`
- `02_Create_Tables.sql`
- `03_Insert_Sample_Data.sql`
- `04_Stored_Procedures.sql`
- `05_Location_Hierarchy.sql`

**Run in order!**

---

## 📞 Backup Strategy

**Frequency:** Daily  
**Retention:** 30 days  
**Type:** Full backup

```sql
BACKUP DATABASE marketing_db 
TO DISK = 'C:\Backups\marketing_db_backup.bak'
WITH FORMAT, COMPRESSION;
```

---

**Schema Version:** 1.0  
**Last Updated:** December 2025
