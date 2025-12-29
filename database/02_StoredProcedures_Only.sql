USE marketing_db;
GO

-- =============================================
-- STORED PROCEDURES ONLY - SEPARATE FILE
-- Run this only after tables are created
-- =============================================

-- Drop existing procedures if they exist
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_InsertTask')
    DROP PROCEDURE sp_InsertTask;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateTask')
    DROP PROCEDURE sp_UpdateTask;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateTaskStatus')
    DROP PROCEDURE sp_UpdateTaskStatus;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteTask')
    DROP PROCEDURE sp_DeleteTask;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetTasks')
    DROP PROCEDURE sp_GetTasks;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_InsertEmployee')
    DROP PROCEDURE sp_InsertEmployee;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateEmployee')
    DROP PROCEDURE sp_UpdateEmployee;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteEmployee')
    DROP PROCEDURE sp_DeleteEmployee;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetEmployees')
    DROP PROCEDURE sp_GetEmployees;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_InsertLocation')
    DROP PROCEDURE sp_InsertLocation;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateLocation')
    DROP PROCEDURE sp_UpdateLocation;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeleteLocation')
    DROP PROCEDURE sp_DeleteLocation;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetLocations')
    DROP PROCEDURE sp_GetLocations;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_InsertUser')
    DROP PROCEDURE sp_InsertUser;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateUser')
    DROP PROCEDURE sp_UpdateUser;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateUserPassword')
    DROP PROCEDURE sp_UpdateUserPassword;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_DeactivateUser')
    DROP PROCEDURE sp_DeactivateUser;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUsers')
    DROP PROCEDURE sp_GetUsers;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserByUsername')
    DROP PROCEDURE sp_GetUserByUsername;
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetTaskStatusHistory')
    DROP PROCEDURE sp_GetTaskStatusHistory;
GO

-- =============================================
-- CREATE STORED PROCEDURES
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

PRINT 'All stored procedures created successfully!';

-- Show created procedures
SELECT 'Stored Procedures Created:' AS Info;
SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE' ORDER BY ROUTINE_NAME;