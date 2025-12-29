USE marketing_db;
GO

-- =============================================
-- DATABASE VERIFICATION AND TEST SCRIPT
-- =============================================

PRINT '=============================================';
PRINT 'TESTING DATABASE SETUP';
PRINT '=============================================';

-- 1. Verify all tables exist
PRINT '1. CHECKING TABLES...';
SELECT 
    TABLE_NAME as 'Table Name',
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = t.TABLE_NAME) as 'Column Count'
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- 2. Verify all stored procedures exist
PRINT '2. CHECKING STORED PROCEDURES...';
SELECT 
    ROUTINE_NAME as 'Procedure Name',
    CREATED as 'Created Date'
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;

-- 3. Test table structure
PRINT '3. CHECKING TABLE STRUCTURES...';

PRINT 'Tasks table columns:';
SELECT 
    COLUMN_NAME as 'Column',
    DATA_TYPE as 'Type',
    IS_NULLABLE as 'Nullable'
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Tasks'
ORDER BY ORDINAL_POSITION;

PRINT 'Users table columns:';
SELECT 
    COLUMN_NAME as 'Column',
    DATA_TYPE as 'Type',
    IS_NULLABLE as 'Nullable'
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Users'
ORDER BY ORDINAL_POSITION;

-- 4. Test a simple stored procedure
PRINT '4. TESTING STORED PROCEDURES...';

-- Test inserting an employee
EXEC sp_InsertEmployee 
    @Name = 'Test Employee',
    @Contact = '1234567890',
    @Designation = 'Test Position',
    @Email = 'test@example.com';

-- Test getting employees
PRINT 'Testing sp_GetEmployees:';
EXEC sp_GetEmployees @IsActive = 1;

-- Test inserting a location
EXEC sp_InsertLocation 
    @LocationName = 'Test Location',
    @State = 'Test State';

-- Test getting locations
PRINT 'Testing sp_GetLocations:';
EXEC sp_GetLocations @IsActive = 1;

-- Test inserting a user
EXEC sp_InsertUser 
    @Username = 'testuser',
    @PasswordHash = 'testhash123',
    @Role = 'Admin',
    @EmployeeId = 1;

-- Test getting users
PRINT 'Testing sp_GetUsers:';
EXEC sp_GetUsers @IsActive = 1;

-- Test inserting a task
EXEC sp_InsertTask 
    @AssignedByUserId = 1,
    @EmployeeId = 1,
    @LocationId = 1,
    @Description = 'Test task description',
    @Priority = 'High',
    @TaskDate = '2024-01-15',
    @Deadline = '2024-01-20';

-- Test getting tasks
PRINT 'Testing sp_GetTasks:';
EXEC sp_GetTasks;

-- Test getting task status history
PRINT 'Testing sp_GetTaskStatusHistory:';
EXEC sp_GetTaskStatusHistory @TaskId = 1;

PRINT '=============================================';
PRINT 'DATABASE TEST COMPLETED!';
PRINT '=============================================';
PRINT 'If you see data above, everything is working perfectly!';
PRINT '=============================================';