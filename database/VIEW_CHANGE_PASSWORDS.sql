-- =============================================
-- VIEW & CHANGE EMPLOYEE PASSWORDS DIRECTLY
-- =============================================
USE [marketing_db]
GO

PRINT '=== CURRENT EMPLOYEE PASSWORDS ==='
GO

-- 1. VIEW ALL EMPLOYEE PASSWORDS
SELECT 
    u.UserId,
    u.Username,
    u.PasswordHash as [Current Password],
    u.Role,
    e.EmployeeId,
    e.Name as EmployeeName,
    e.Designation,
    u.IsActive
FROM Users u
LEFT JOIN Employees e ON u.Username = e.Email
WHERE u.Role = 'Employee'
ORDER BY u.UserId
GO

PRINT '=== HOW TO CHANGE INDIVIDUAL PASSWORD ==='
GO

-- 2. CHANGE SPECIFIC EMPLOYEE PASSWORD (Example)
-- Uncomment and modify to change individual password:

-- Change password for UserId = 2 (Rahul Sharma)
-- UPDATE Users SET PasswordHash = 'newpassword123' WHERE UserId = 2

-- Change password for specific email
-- UPDATE Users SET PasswordHash = 'newpassword123' WHERE Username = 'rahul.sharma@actionmedical.com'

GO

PRINT '=== RESET ALL EMPLOYEE PASSWORDS TO SAME (Uncomment to use) ==='
GO

-- 3. RESET ALL EMPLOYEE PASSWORDS TO 'password123' 
-- Uncomment line below to reset all:
-- UPDATE Users SET PasswordHash = 'password123' WHERE Role = 'Employee'

GO

PRINT '=== VIEW USERS TABLE DIRECTLY ==='
GO

-- 4. SEE ALL USERS WITH PASSWORDS
SELECT 
    UserId,
    Username,
    PasswordHash as Password,
    Role,
    IsActive,
    CreatedAt
FROM Users
ORDER BY UserId
GO

PRINT '=== QUICK REFERENCE ==='
PRINT 'To change password: UPDATE Users SET PasswordHash = ''YourNewPassword'' WHERE UserId = X'
PRINT 'To view passwords: SELECT Username, PasswordHash FROM Users WHERE Role = ''Employee'''
GO
