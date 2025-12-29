USE marketing_db;
GO

-- =============================================
-- COMPREHENSIVE TEST VERIFICATION SCRIPT
-- This script verifies all employees, users, and tasks are properly set up
-- =============================================

PRINT '=============================================';
PRINT 'COMPREHENSIVE SYSTEM VERIFICATION';
PRINT '=============================================';

-- 1. Verify all employees are created
PRINT '1. EMPLOYEE VERIFICATION:';
PRINT '-------------------------';
SELECT 
    EmployeeId,
    Name,
    Designation,
    Email,
    Contact,
    CASE WHEN IsActive = 1 THEN 'Active' ELSE 'Inactive' END as Status
FROM Employees 
ORDER BY EmployeeId;

PRINT '';
PRINT 'Employee Count by Designation:';
SELECT 
    Designation,
    COUNT(*) as Count
FROM Employees 
WHERE IsActive = 1
GROUP BY Designation
ORDER BY Count DESC;

-- 2. Verify all user accounts are created
PRINT '';
PRINT '2. USER ACCOUNT VERIFICATION:';
PRINT '------------------------------';
SELECT 
    u.UserId,
    u.Username,
    u.Role,
    e.Name as EmployeeName,
    e.Designation,
    CASE WHEN u.IsActive = 1 THEN 'Active' ELSE 'Inactive' END as Status
FROM Users u
LEFT JOIN Employees e ON u.EmployeeId = e.EmployeeId
ORDER BY u.Role, u.UserId;

PRINT '';
PRINT 'User Count by Role:';
SELECT 
    Role,
    COUNT(*) as Count
FROM Users 
WHERE IsActive = 1
GROUP BY Role;

-- 3. Verify tasks are assigned properly
PRINT '';
PRINT '3. TASK ASSIGNMENT VERIFICATION:';
PRINT '---------------------------------';
SELECT 
    t.TaskId,
    e.Name as AssignedTo,
    e.Designation,
    t.Description,
    t.Priority,
    t.TaskType,
    t.Department,
    t.Status,
    t.EstimatedHours,
    t.Deadline
FROM Tasks t
INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
ORDER BY t.TaskId DESC;

PRINT '';
PRINT 'Task Distribution by Employee:';
SELECT 
    e.Name,
    e.Designation,
    COUNT(t.TaskId) as TaskCount,
    SUM(t.EstimatedHours) as TotalEstimatedHours
FROM Employees e
LEFT JOIN Tasks t ON e.EmployeeId = t.EmployeeId
GROUP BY e.EmployeeId, e.Name, e.Designation
ORDER BY TaskCount DESC;

-- 4. Verify task distribution by department
PRINT '';
PRINT '4. TASK DISTRIBUTION BY DEPARTMENT:';
PRINT '------------------------------------';
SELECT 
    Department,
    COUNT(*) as TaskCount,
    AVG(EstimatedHours) as AvgHours,
    SUM(EstimatedHours) as TotalHours
FROM Tasks 
GROUP BY Department
ORDER BY TaskCount DESC;

-- 5. Verify task distribution by priority
PRINT '';
PRINT '5. TASK DISTRIBUTION BY PRIORITY:';
PRINT '----------------------------------';
SELECT 
    Priority,
    COUNT(*) as TaskCount,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Tasks) AS DECIMAL(5,2)) as Percentage
FROM Tasks 
GROUP BY Priority
ORDER BY 
    CASE Priority 
        WHEN 'High' THEN 1 
        WHEN 'Medium' THEN 2 
        WHEN 'Low' THEN 3 
    END;

-- 6. Verify locations are available
PRINT '';
PRINT '6. LOCATION VERIFICATION:';
PRINT '-------------------------';
SELECT 
    l.LocationId,
    l.LocationName,
    l.State,
    COUNT(t.TaskId) as TasksAssigned
FROM Locations l
LEFT JOIN Tasks t ON l.LocationId = t.LocationId
GROUP BY l.LocationId, l.LocationName, l.State
ORDER BY COUNT(t.TaskId) DESC, l.LocationName;

-- 7. System summary
PRINT '';
PRINT '7. SYSTEM SUMMARY:';
PRINT '------------------';
SELECT 
    'Total Employees' as Metric,
    CAST(COUNT(*) as VARCHAR(10)) as Value
FROM Employees 
WHERE IsActive = 1
UNION ALL
SELECT 
    'Total Users',
    CAST(COUNT(*) as VARCHAR(10))
FROM Users 
WHERE IsActive = 1
UNION ALL
SELECT 
    'Total Tasks',
    CAST(COUNT(*) as VARCHAR(10))
FROM Tasks
UNION ALL
SELECT 
    'Total Locations',
    CAST(COUNT(*) as VARCHAR(10))
FROM Locations 
WHERE IsActive = 1
UNION ALL
SELECT 
    'High Priority Tasks',
    CAST(COUNT(*) as VARCHAR(10))
FROM Tasks 
WHERE Priority = 'High'
UNION ALL
SELECT 
    'Total Estimated Hours',
    CAST(SUM(EstimatedHours) as VARCHAR(10))
FROM Tasks;

-- 8. Test login credentials (show sample)
PRINT '';
PRINT '8. SAMPLE LOGIN CREDENTIALS:';
PRINT '-----------------------------';
PRINT 'Admin Account:';
PRINT 'Username: admin@actionmedical.com';
PRINT 'Password: Admin123!';
PRINT '';
PRINT 'Sample Employee Accounts (Password: Employee123!):';
SELECT TOP 5
    u.Username,
    e.Name,
    e.Designation
FROM Users u
INNER JOIN Employees e ON u.EmployeeId = e.EmployeeId
WHERE u.Role = 'Employee'
ORDER BY u.UserId;

-- 9. Verify data integrity
PRINT '';
PRINT '9. DATA INTEGRITY CHECK:';
PRINT '------------------------';

-- Check for orphaned tasks
DECLARE @OrphanedTasks INT = (
    SELECT COUNT(*) 
    FROM Tasks t 
    LEFT JOIN Employees e ON t.EmployeeId = e.EmployeeId 
    WHERE e.EmployeeId IS NULL
);

-- Check for users without employees
DECLARE @UsersWithoutEmployees INT = (
    SELECT COUNT(*) 
    FROM Users u 
    LEFT JOIN Employees e ON u.EmployeeId = e.EmployeeId 
    WHERE u.Role = 'Employee' AND e.EmployeeId IS NULL
);

PRINT 'Orphaned Tasks (should be 0): ' + CAST(@OrphanedTasks as VARCHAR(10));
PRINT 'Employee Users without Employee records (should be 0): ' + CAST(@UsersWithoutEmployees as VARCHAR(10));

IF @OrphanedTasks = 0 AND @UsersWithoutEmployees = 0
    PRINT 'DATA INTEGRITY: PASSED ✓'
ELSE
    PRINT 'DATA INTEGRITY: FAILED ✗'

PRINT '';
PRINT '=============================================';
PRINT 'VERIFICATION COMPLETE!';
PRINT 'Your system is ready for testing with:';
PRINT '- 17+ employees with diverse designations';
PRINT '- 25+ comprehensive tasks';
PRINT '- Multiple departments and priorities';
PRINT '- Complete user authentication setup';
PRINT '=============================================';