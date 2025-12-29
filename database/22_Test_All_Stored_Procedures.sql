-- Complete test script for all stored procedures
USE [marketing_db]
GO

PRINT '============================================='
PRINT 'TESTING ALL STORED PROCEDURES'
PRINT '============================================='

-- First, run the fix script to ensure all procedures exist
PRINT 'Step 1: Running stored procedures fix...'
-- Note: You need to run database/21_Complete_Stored_Procedures_Fix.sql first

PRINT ''
PRINT 'Step 2: Testing all stored procedures...'
PRINT '============================================='

-- Test 1: Get Employees
PRINT '1. Testing sp_GetEmployees...'
EXEC sp_GetEmployees @IsActive = 1
PRINT ''

-- Test 2: Get States
PRINT '2. Testing sp_GetStates...'
EXEC sp_GetStates
PRINT ''

-- Test 3: Get Cities by State (assuming state 1 exists)
PRINT '3. Testing sp_GetCitiesByState...'
EXEC sp_GetCitiesByState @StateId = 1
PRINT ''

-- Test 4: Get Locations
PRINT '4. Testing sp_GetLocations...'
EXEC sp_GetLocations @IsActive = 1
PRINT ''

-- Test 5: Get Tasks
PRINT '5. Testing sp_GetTasks...'
EXEC sp_GetTasks @EmployeeId = NULL, @Status = NULL
PRINT ''

-- Test 6: Get Employee Summary
PRINT '6. Testing GetEmployeeSummary...'
EXEC GetEmployeeSummary
PRINT ''

-- Test 7: Get High Priority Tasks
PRINT '7. Testing GetHighPriorityTasks...'
EXEC GetHighPriorityTasks
PRINT ''

-- Test 8: Get Tasks by Department
PRINT '8. Testing GetTasksByDepartment...'
EXEC GetTasksByDepartment @Department = 'Marketing'
PRINT ''

-- Test 9: Get User by Username
PRINT '9. Testing sp_GetUserByUsername...'
EXEC sp_GetUserByUsername @Username = 'admin'
PRINT ''

-- Test 10: Get Users
PRINT '10. Testing sp_GetUsers...'
EXEC sp_GetUsers @IsActive = 1
PRINT ''

-- Test 11: Get Tasks by Employee (if exists)
PRINT '11. Testing GetTasksByEmployee...'
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetTasksByEmployee')
BEGIN
    EXEC GetTasksByEmployee @EmployeeName = 'John Doe'
END
ELSE
BEGIN
    PRINT 'GetTasksByEmployee procedure not found - this is expected if not created yet'
END
PRINT ''

-- Test 12: Get Task Status History by Employee (if exists)
PRINT '12. Testing GetTaskStatusHistoryByEmployee...'
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetTaskStatusHistoryByEmployee')
BEGIN
    EXEC GetTaskStatusHistoryByEmployee @EmployeeName = 'John Doe'
END
ELSE
BEGIN
    PRINT 'GetTaskStatusHistoryByEmployee procedure not found - this is expected if not created yet'
END
PRINT ''

-- Test 13: Get Pincodes by Area (if exists)
PRINT '13. Testing sp_GetPincodesByArea...'
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetPincodesByArea')
BEGIN
    EXEC sp_GetPincodesByArea @AreaId = 1
END
ELSE
BEGIN
    PRINT 'sp_GetPincodesByArea procedure not found - this is expected if not created yet'
END
PRINT ''

PRINT '============================================='
PRINT 'STORED PROCEDURE TESTING COMPLETE!'
PRINT '============================================='
PRINT 'If you see data above, the stored procedures are working correctly.'
PRINT 'If you see "procedure not found" messages, run the fix script first.'
