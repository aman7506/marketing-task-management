-- Test script to verify all stored procedures are working correctly
USE [marketing_db]
GO

PRINT 'Testing Stored Procedures...'
PRINT '====================================='

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
-- First run the fix script, then test
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

PRINT '====================================='
PRINT 'Stored Procedure Testing Complete!'
PRINT 'If you see data above, the stored procedures are working correctly.'
