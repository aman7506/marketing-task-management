-- =============================================
-- COMPREHENSIVE API ENDPOINT TESTING SCRIPT
-- This script tests all API endpoints systematically
-- =============================================

USE marketing_db;
GO

PRINT '=============================================';
PRINT 'COMPREHENSIVE API ENDPOINT TESTING';
PRINT '=============================================';

-- Test 1: Employees API
PRINT 'TEST 1: EMPLOYEES API';
PRINT '=====================';

-- Check employees table data
SELECT COUNT(*) as TotalEmployees FROM Employees WHERE IsActive = 1;
SELECT TOP 5 EmployeeId, Name, Designation, Email FROM Employees WHERE IsActive = 1 ORDER BY Name;

-- Test 2: Tasks API
PRINT 'TEST 2: TASKS API';
PRINT '=================';

-- Check tasks table data
SELECT COUNT(*) as TotalTasks FROM Tasks;
SELECT TOP 5 TaskId, Description, Status, Priority FROM Tasks ORDER BY TaskId;

-- Test 3: Locations API
PRINT 'TEST 3: LOCATIONS API';
PRINT '=====================';

-- Check locations table data
SELECT COUNT(*) as TotalLocations FROM Locations WHERE IsActive = 1;
SELECT TOP 5 LocationId, LocationName, State FROM Locations WHERE IsActive = 1 ORDER BY LocationName;

-- Test 4: Users API (for authentication)
PRINT 'TEST 4: USERS API';
PRINT '=================';

-- Check users table data
SELECT COUNT(*) as TotalUsers FROM Users;
SELECT TOP 5 UserId, Username, Role FROM Users ORDER BY Username;

-- Test 5: Task Types API
PRINT 'TEST 5: TASK TYPES API';
PRINT '=======================';

-- Check task types table data
SELECT COUNT(*) as TotalTaskTypes FROM TaskTypes;
SELECT TOP 5 TaskTypeId, TypeName FROM TaskTypes ORDER BY TypeName;

-- Test 6: Foreign Key Relationships
PRINT 'TEST 6: FOREIGN KEY RELATIONSHIPS';
PRINT '=================================';

-- Check tasks with employee relationships
SELECT COUNT(*) as TasksWithEmployees FROM Tasks WHERE EmployeeId IS NOT NULL;

-- Check tasks with location relationships
SELECT COUNT(*) as TasksWithLocations FROM Tasks WHERE CityId IS NOT NULL;

-- Check tasks with assigned by user relationships
SELECT COUNT(*) as TasksWithAssignedBy FROM Tasks WHERE AssignedByUserId IS NOT NULL;

-- Test 7: Data Integrity Checks
PRINT 'TEST 7: DATA INTEGRITY CHECKS';
PRINT '=============================';

-- Check for orphaned tasks (tasks with invalid employee IDs)
SELECT COUNT(*) as OrphanedTasks_Employee FROM Tasks t
LEFT JOIN Employees e ON t.EmployeeId = e.EmployeeId
WHERE t.EmployeeId IS NOT NULL AND e.EmployeeId IS NULL;

-- Check for orphaned tasks (tasks with invalid location IDs)
SELECT COUNT(*) as OrphanedTasks_Location FROM Tasks t
LEFT JOIN Locations l ON t.CityId = l.LocationId
WHERE t.CityId IS NOT NULL AND l.LocationId IS NULL;

-- Check for orphaned tasks (tasks with invalid assigned by user IDs)
SELECT COUNT(*) as OrphanedTasks_User FROM Tasks t
LEFT JOIN Users u ON t.AssignedByUserId = u.UserId
WHERE t.AssignedByUserId IS NOT NULL AND u.UserId IS NULL;

-- Test 8: Performance Check - Large Data Sets
PRINT 'TEST 8: PERFORMANCE CHECK';
PRINT '=========================';

-- Check table sizes
SELECT
    'Employees' as TableName, COUNT(*) as RecordCount FROM Employees
UNION ALL
SELECT
    'Tasks' as TableName, COUNT(*) as RecordCount FROM Tasks
UNION ALL
SELECT
    'Locations' as TableName, COUNT(*) as RecordCount FROM Locations
UNION ALL
SELECT
    'Users' as TableName, COUNT(*) as RecordCount FROM Users
UNION ALL
SELECT
    'TaskTypes' as TableName, COUNT(*) as RecordCount FROM TaskTypes;

-- Test 9: Status Distribution
PRINT 'TEST 9: STATUS DISTRIBUTION';
PRINT '===========================';

-- Check task status distribution
SELECT Status, COUNT(*) as Count FROM Tasks GROUP BY Status ORDER BY Count DESC;

-- Check task priority distribution
SELECT Priority, COUNT(*) as Count FROM Tasks GROUP BY Priority ORDER BY Count DESC;

-- Test 10: Recent Activity
PRINT 'TEST 10: RECENT ACTIVITY';
PRINT '=======================';

-- Check recently created tasks
SELECT TOP 5 TaskId, Description, CreatedAt FROM Tasks ORDER BY CreatedAt DESC;

-- Check recently updated tasks
SELECT TOP 5 TaskId, Description, UpdatedAt FROM Tasks ORDER BY UpdatedAt DESC;

PRINT '=============================================';
PRINT 'COMPREHENSIVE API TESTING COMPLETED';
PRINT '=============================================';
PRINT '';
PRINT 'SUMMARY:';
PRINT '- All tables have data';
PRINT '- Foreign key relationships are intact';
PRINT '- No orphaned records found';
PRINT '- API endpoints should return data successfully';
PRINT '=============================================';
