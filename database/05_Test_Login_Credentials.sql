USE marketing_db;
GO

-- =============================================
-- TEST LOGIN CREDENTIALS
-- This script will test the login functionality
-- =============================================

PRINT '=============================================';
PRINT 'TESTING LOGIN CREDENTIALS';
PRINT '=============================================';

-- Check if the demo users exist
PRINT 'Checking existing users:';
SELECT 
    u.UserId,
    u.Username,
    u.Role,
    u.EmployeeId,
    e.Name as EmployeeName,
    u.IsActive
FROM Users u
LEFT JOIN Employees e ON u.EmployeeId = e.EmployeeId
ORDER BY u.Role, u.Username;

-- Check if Rahul Sharma employee exists
PRINT 'Checking Rahul Sharma employee:';
SELECT * FROM Employees WHERE Email = 'rahul.sharma@actionmedical.com';

-- Test the stored procedure that would be used for login
PRINT 'Testing sp_GetUserByUsername for admin:';
EXEC sp_GetUserByUsername @Username = 'admin@actionmedical.com';

PRINT 'Testing sp_GetUserByUsername for employee:';
EXEC sp_GetUserByUsername @Username = 'rahul.sharma@actionmedical.com';

PRINT '=============================================';
PRINT 'LOGIN CREDENTIALS TEST COMPLETED!';
PRINT '=============================================';