-- =============================================
-- ADD PASSWORD COLUMN TO EMPLOYEES VIEW
-- =============================================
USE [marketing_db]
GO

PRINT '=== CREATING EMPLOYEE PASSWORD VIEW ==='
GO

-- Drop view if exists
IF OBJECT_ID('vw_Employees_With_Password', 'V') IS NOT NULL
    DROP VIEW vw_Employees_With_Password
GO

-- Create view with password column
CREATE VIEW vw_Employees_With_Password
AS
SELECT 
    e.EmployeeId,
    e.Name,
    e.Contact,
    e.Designation,
    e.Email,
    u.PasswordHash as Password,  -- PASSWORD COLUMN ADDED!
    u.UserId,
    e.CreatedAt,
    e.IsActive,
    e.EmployeeCode
FROM Employees e
LEFT JOIN Users u ON e.Email = u.Username
GO

PRINT '✅ View created: vw_Employees_With_Password'
GO

-- Now you can see all employees with passwords!
SELECT * FROM vw_Employees_With_Password
ORDER BY EmployeeId
GO

PRINT ''
PRINT '=== HOW TO USE ==='
PRINT '1. VIEW ALL WITH PASSWORDS:'
PRINT '   SELECT * FROM vw_Employees_With_Password'
PRINT ''
PRINT '2. CHANGE PASSWORD BY EMAIL:'
PRINT '   UPDATE Users SET PasswordHash = ''NewPassword123'' WHERE Username = ''email@example.com'''
PRINT ''
PRINT '3. CHANGE PASSWORD BY EMPLOYEE ID:'
PRINT '   UPDATE Users SET PasswordHash = ''NewPassword123'' '
PRINT '   WHERE Username = (SELECT Email FROM Employees WHERE EmployeeId = 2)'
PRINT ''
PRINT '4. RESET ALL EMPLOYEE PASSWORDS:'
PRINT '   UPDATE Users SET PasswordHash = ''password123'' WHERE Role = ''Employee'''
GO
