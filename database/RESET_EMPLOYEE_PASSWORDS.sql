-- =============================================
-- Reset All Employee Passwords to 'password123'
-- =============================================
USE [marketing_db]
GO

PRINT '=== RESETTING EMPLOYEE PASSWORDS ==='
GO

-- Update all employee users to have password 'password123'
UPDATE Users
SET PasswordHash = 'password123'
WHERE Role = 'Employee'
GO

-- Show all employees with their credentials
SELECT 
    e.EmployeeId,
    e.Name,
    e.Email,
    u.Username,
    u.PasswordHash as Password,
    u.Role,
    '✅ Password: password123' as LoginInfo
FROM Employees e
LEFT JOIN Users u ON e.Email = u.Username
WHERE u.Role = 'Employee'
ORDER BY e.EmployeeId
GO

PRINT '=== ALL EMPLOYEE PASSWORDS RESET TO: password123 ==='
GO

-- Summary
SELECT 
    COUNT(*) as TotalEmployees,
    'password123' as DefaultPassword
FROM Users
WHERE Role = 'Employee'
GO
