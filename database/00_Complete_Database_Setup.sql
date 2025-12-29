-- =============================================
-- COMPLETE DATABASE SETUP SCRIPT
-- This script will create the database, tables, and stored procedures
-- =============================================

USE master;
GO

-- Drop database if exists (for clean setup)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'marketing_db')
BEGIN
    ALTER DATABASE marketing_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE marketing_db;
END
GO

-- Create database
CREATE DATABASE marketing_db;
GO

USE marketing_db;
GO

PRINT 'Database created successfully!';

-- =============================================
-- CREATE TABLES
-- =============================================

-- Create Employees table first (referenced by Users)
CREATE TABLE Employees (
    EmployeeId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Contact NVARCHAR(50) NOT NULL,
    Designation NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

PRINT 'Employees table created successfully!';

-- Create Users table
CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(256) NOT NULL,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'Employee')),
    EmployeeId INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
);

PRINT 'Users table created successfully!';

-- Create Locations table
CREATE TABLE Locations (
    LocationId INT PRIMARY KEY IDENTITY(1,1),
    LocationName NVARCHAR(100) NOT NULL UNIQUE,
    State NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

PRINT 'Locations table created successfully!';

-- Create Tasks table
CREATE TABLE Tasks (
    TaskId INT PRIMARY KEY IDENTITY(1,1),
    AssignedByUserId INT NOT NULL,
    EmployeeId INT NOT NULL,
    LocationId INT NULL,
    CustomLocation NVARCHAR(100) NULL,
    Description NVARCHAR(500) NOT NULL,
    Priority NVARCHAR(10) NOT NULL CHECK (Priority IN ('Low', 'Medium', 'High')),
    TaskDate DATE NOT NULL,
    Deadline DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Not Started' CHECK (Status IN ('Not Started', 'In Progress', 'Completed', 'Postponed')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (AssignedByUserId) REFERENCES Users(UserId),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
    FOREIGN KEY (LocationId) REFERENCES Locations(LocationId)
);

PRINT 'Tasks table created successfully!';

-- Create TaskStatusHistory table
CREATE TABLE TaskStatusHistory (
    HistoryId INT PRIMARY KEY IDENTITY(1,1),
    TaskId INT NOT NULL,
    Status NVARCHAR(20) NOT NULL,
    Remarks NVARCHAR(500) NULL,
    ChangedByUserId INT NOT NULL,
    ChangedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (TaskId) REFERENCES Tasks(TaskId),
    FOREIGN KEY (ChangedByUserId) REFERENCES Users(UserId)
);

PRINT 'TaskStatusHistory table created successfully!';

-- Verify tables were created
PRINT 'Verifying table creation...';
SELECT 
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- Verify columns for each table
PRINT 'Verifying Tasks table columns...';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Tasks'
ORDER BY ORDINAL_POSITION;

PRINT 'Verifying Users table columns...';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Users'
ORDER BY ORDINAL_POSITION;

PRINT 'Verifying Employees table columns...';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Employees'
ORDER BY ORDINAL_POSITION;

PRINT 'Verifying Locations table columns...';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Locations'
ORDER BY ORDINAL_POSITION;

PRINT 'Verifying TaskStatusHistory table columns...';
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'TaskStatusHistory'
ORDER BY ORDINAL_POSITION;

-- =============================================
-- CREATE STORED PROCEDURES
-- =============================================

PRINT 'Creating stored procedures...';

-- =============================================
-- TASK STORED PROCEDURES
-- =============================================

-- Insert Task
CREATE PROCEDURE sp_InsertTask
    @AssignedByUserId INT,
    @EmployeeId INT,
    @LocationId INT = NULL,
    @CustomLocation NVARCHAR(100) = NULL,
    @Description NVARCHAR(500),
    @Priority NVARCHAR(10),
    @TaskDate DATE,
    @Deadline DATE,
    @Status NVARCHAR(20) = 'Not Started'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TaskId INT;
    
    INSERT INTO Tasks (
        AssignedByUserId,
        EmployeeId,
        LocationId,
        CustomLocation,
        Description,
        Priority,
        TaskDate,
        Deadline,
        Status,
        CreatedAt,
        UpdatedAt
    )
    VALUES (
        @AssignedByUserId,
        @EmployeeId,
        @LocationId,
        @CustomLocation,
        @Description,
        @Priority,
        @TaskDate,
        @Deadline,
        @Status,
        GETDATE(),
        GETDATE()
    );
    
    SET @TaskId = SCOPE_IDENTITY();
    
    -- Insert initial status history
    INSERT INTO TaskStatusHistory (
        TaskId,
        Status,
        Remarks,
        ChangedByUserId,
        ChangedAt
    )
    VALUES (
        @TaskId,
        @Status,
        'Task created',
        @AssignedByUserId,
        GETDATE()
    );
    
    SELECT @TaskId AS TaskId;
END
GO

PRINT 'sp_InsertTask created successfully!';

-- Update Task
CREATE PROCEDURE sp_UpdateTask
    @TaskId INT,
    @LocationId INT = NULL,
    @CustomLocation NVARCHAR(100) = NULL,
    @Description NVARCHAR(500),
    @Priority NVARCHAR(10),
    @TaskDate DATE,
    @Deadline DATE,
    @UpdatedByUserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Tasks 
    SET 
        LocationId = @LocationId,
        CustomLocation = @CustomLocation,
        Description = @Description,
        Priority = @Priority,
        TaskDate = @TaskDate,
        Deadline = @Deadline,
        UpdatedAt = GETDATE()
    WHERE TaskId = @TaskId;
    
    -- Insert status history for update
    INSERT INTO TaskStatusHistory (
        TaskId,
        Status,
        Remarks,
        ChangedByUserId,
        ChangedAt
    )
    SELECT 
        @TaskId,
        Status,
        'Task updated',
        @UpdatedByUserId,
        GETDATE()
    FROM Tasks 
    WHERE TaskId = @TaskId;
END
GO

PRINT 'sp_UpdateTask created successfully!';

-- Update Task Status
CREATE PROCEDURE sp_UpdateTaskStatus
    @TaskId INT,
    @Status NVARCHAR(20),
    @Remarks NVARCHAR(500) = NULL,
    @ChangedByUserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Tasks 
    SET 
        Status = @Status,
        UpdatedAt = GETDATE()
    WHERE TaskId = @TaskId;
    
    -- Insert status history
    INSERT INTO TaskStatusHistory (
        TaskId,
        Status,
        Remarks,
        ChangedByUserId,
        ChangedAt
    )
    VALUES (
        @TaskId,
        @Status,
        @Remarks,
        @ChangedByUserId,
        GETDATE()
    );
END
GO

PRINT 'sp_UpdateTaskStatus created successfully!';

-- Delete Task
CREATE PROCEDURE sp_DeleteTask
    @TaskId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Delete task status history first (foreign key constraint)
    DELETE FROM TaskStatusHistory WHERE TaskId = @TaskId;
    
    -- Delete the task
    DELETE FROM Tasks WHERE TaskId = @TaskId;
END
GO

PRINT 'sp_DeleteTask created successfully!';

-- Get Tasks
CREATE PROCEDURE sp_GetTasks
    @EmployeeId INT = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        t.TaskId,
        t.AssignedByUserId,
        u.Username AS AssignedByUsername,
        t.EmployeeId,
        e.Name AS EmployeeName,
        e.Email AS EmployeeEmail,
        t.LocationId,
        l.LocationName,
        l.State,
        t.CustomLocation,
        t.Description,
        t.Priority,
        t.TaskDate,
        t.Deadline,
        t.Status,
        t.CreatedAt,
        t.UpdatedAt
    FROM Tasks t
    INNER JOIN Users u ON t.AssignedByUserId = u.UserId
    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
    LEFT JOIN Locations l ON t.LocationId = l.LocationId
    WHERE 
        (@EmployeeId IS NULL OR t.EmployeeId = @EmployeeId)
        AND (@Status IS NULL OR t.Status = @Status)
    ORDER BY t.CreatedAt DESC;
END
GO

PRINT 'sp_GetTasks created successfully!';

-- =============================================
-- EMPLOYEE STORED PROCEDURES
-- =============================================

-- Insert Employee
CREATE PROCEDURE sp_InsertEmployee
    @Name NVARCHAR(100),
    @Contact NVARCHAR(50),
    @Designation NVARCHAR(50),
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Employees (
        Name,
        Contact,
        Designation,
        Email,
        CreatedAt,
        IsActive
    )
    VALUES (
        @Name,
        @Contact,
        @Designation,
        @Email,
        GETDATE(),
        1
    );
    
    SELECT SCOPE_IDENTITY() AS EmployeeId;
END
GO

PRINT 'sp_InsertEmployee created successfully!';

-- Update Employee
CREATE PROCEDURE sp_UpdateEmployee
    @EmployeeId INT,
    @Name NVARCHAR(100),
    @Contact NVARCHAR(50),
    @Designation NVARCHAR(50),
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Employees 
    SET 
        Name = @Name,
        Contact = @Contact,
        Designation = @Designation,
        Email = @Email
    WHERE EmployeeId = @EmployeeId;
END
GO

PRINT 'sp_UpdateEmployee created successfully!';

-- Delete Employee (Deactivate)
CREATE PROCEDURE sp_DeleteEmployee
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Employees 
    SET IsActive = 0
    WHERE EmployeeId = @EmployeeId;
END
GO

PRINT 'sp_DeleteEmployee created successfully!';

-- Get Employees
CREATE PROCEDURE sp_GetEmployees
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        EmployeeId,
        Name,
        Contact,
        Designation,
        Email,
        CreatedAt,
        IsActive
    FROM Employees
    WHERE IsActive = @IsActive
    ORDER BY Name;
END
GO

PRINT 'sp_GetEmployees created successfully!';

-- =============================================
-- LOCATION STORED PROCEDURES
-- =============================================

-- Insert Location
CREATE PROCEDURE sp_InsertLocation
    @LocationName NVARCHAR(100),
    @State NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Locations (
        LocationName,
        State,
        CreatedAt,
        IsActive
    )
    VALUES (
        @LocationName,
        @State,
        GETDATE(),
        1
    );
    
    SELECT SCOPE_IDENTITY() AS LocationId;
END
GO

PRINT 'sp_InsertLocation created successfully!';

-- Update Location
CREATE PROCEDURE sp_UpdateLocation
    @LocationId INT,
    @LocationName NVARCHAR(100),
    @State NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Locations 
    SET 
        LocationName = @LocationName,
        State = @State
    WHERE LocationId = @LocationId;
END
GO

PRINT 'sp_UpdateLocation created successfully!';

-- Delete Location (Deactivate)
CREATE PROCEDURE sp_DeleteLocation
    @LocationId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Locations 
    SET IsActive = 0
    WHERE LocationId = @LocationId;
END
GO

PRINT 'sp_DeleteLocation created successfully!';

-- Get Locations
CREATE PROCEDURE sp_GetLocations
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        LocationId,
        LocationName,
        State,
        CreatedAt,
        IsActive
    FROM Locations
    WHERE IsActive = @IsActive
    ORDER BY LocationName;
END
GO

PRINT 'sp_GetLocations created successfully!';

-- =============================================
-- USER STORED PROCEDURES
-- =============================================

-- Insert User
CREATE PROCEDURE sp_InsertUser
    @Username NVARCHAR(50),
    @PasswordHash NVARCHAR(256),
    @Role NVARCHAR(20),
    @EmployeeId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO Users (
        Username,
        PasswordHash,
        Role,
        EmployeeId,
        CreatedAt,
        IsActive
    )
    VALUES (
        @Username,
        @PasswordHash,
        @Role,
        @EmployeeId,
        GETDATE(),
        1
    );
    
    SELECT SCOPE_IDENTITY() AS UserId;
END
GO

PRINT 'sp_InsertUser created successfully!';

-- Update User
CREATE PROCEDURE sp_UpdateUser
    @UserId INT,
    @Username NVARCHAR(50),
    @Role NVARCHAR(20),
    @EmployeeId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Users 
    SET 
        Username = @Username,
        Role = @Role,
        EmployeeId = @EmployeeId
    WHERE UserId = @UserId;
END
GO

PRINT 'sp_UpdateUser created successfully!';

-- Update User Password
CREATE PROCEDURE sp_UpdateUserPassword
    @UserId INT,
    @PasswordHash NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Users 
    SET PasswordHash = @PasswordHash
    WHERE UserId = @UserId;
END
GO

PRINT 'sp_UpdateUserPassword created successfully!';

-- Deactivate User
CREATE PROCEDURE sp_DeactivateUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Users 
    SET IsActive = 0
    WHERE UserId = @UserId;
END
GO

PRINT 'sp_DeactivateUser created successfully!';

-- Get Users
CREATE PROCEDURE sp_GetUsers
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        u.UserId,
        u.Username,
        u.Role,
        u.EmployeeId,
        e.Name AS EmployeeName,
        u.CreatedAt,
        u.IsActive
    FROM Users u
    LEFT JOIN Employees e ON u.EmployeeId = e.EmployeeId
    WHERE u.IsActive = @IsActive
    ORDER BY u.Username;
END
GO

PRINT 'sp_GetUsers created successfully!';

-- Get User by Username (for authentication)
CREATE PROCEDURE sp_GetUserByUsername
    @Username NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        u.UserId,
        u.Username,
        u.PasswordHash,
        u.Role,
        u.EmployeeId,
        e.Name AS EmployeeName,
        u.CreatedAt,
        u.IsActive
    FROM Users u
    LEFT JOIN Employees e ON u.EmployeeId = e.EmployeeId
    WHERE u.Username = @Username AND u.IsActive = 1;
END
GO

PRINT 'sp_GetUserByUsername created successfully!';

-- =============================================
-- TASK STATUS HISTORY PROCEDURES
-- =============================================

-- Get Task Status History
CREATE PROCEDURE sp_GetTaskStatusHistory
    @TaskId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        tsh.HistoryId,
        tsh.TaskId,
        tsh.Status,
        tsh.Remarks,
        tsh.ChangedByUserId,
        u.Username AS ChangedByUsername,
        tsh.ChangedAt
    FROM TaskStatusHistory tsh
    INNER JOIN Users u ON tsh.ChangedByUserId = u.UserId
    WHERE tsh.TaskId = @TaskId
    ORDER BY tsh.ChangedAt DESC;
END
GO

PRINT 'sp_GetTaskStatusHistory created successfully!';

-- =============================================
-- FINAL VERIFICATION
-- =============================================

PRINT 'Verifying all stored procedures were created...';
SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;

PRINT '=============================================';
PRINT 'DATABASE SETUP COMPLETED SUCCESSFULLY!';
PRINT '=============================================';
PRINT 'Database: marketing_db';
PRINT 'Tables created: 5';
PRINT 'Stored procedures created: 20';
PRINT '=============================================';