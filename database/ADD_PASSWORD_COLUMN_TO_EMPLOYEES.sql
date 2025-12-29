-- =============================================
-- OPTION 2: ADD PASSWORD COLUMN DIRECTLY TO EMPLOYEES TABLE
-- =============================================
USE [marketing_db]
GO

PRINT '=== ADDING PASSWORD COLUMN TO EMPLOYEES TABLE ==='
GO

-- Check if Password column already exists
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('Employees') 
    AND name = 'Password'
)
BEGIN
    -- Add Password column to Employees table
    ALTER TABLE Employees
    ADD Password NVARCHAR(100) NULL
    
    PRINT '✅ Password column added to Employees table'
END
ELSE
BEGIN
    PRINT '✅ Password column already exists'
END
GO

-- Sync passwords from Users table to Employees table
UPDATE e
SET e.Password = u.PasswordHash
FROM Employees e
INNER JOIN Users u ON e.Email = u.Username
GO

PRINT '✅ Passwords synced from Users to Employees table'
GO

-- Now view all employees with passwords!
SELECT 
    EmployeeId,
    Name,
    Contact,
    Designation,
    Email,
    Password,  -- PASSWORD VISIBLE!
    CreatedAt,
    IsActive,
    EmployeeCode
FROM Employees
ORDER BY EmployeeId
GO

PRINT ''
PRINT '=== HOW TO CHANGE PASSWORDS ==='
PRINT ''
PRINT '1. CHANGE SPECIFIC EMPLOYEE PASSWORD:'
PRINT '   UPDATE Employees SET Password = ''NewPassword123'' WHERE EmployeeId = 2'
PRINT '   -- Then sync to Users table:'
PRINT '   UPDATE Users SET PasswordHash = (SELECT Password FROM Employees WHERE EmployeeId = 2) '
PRINT '   WHERE Username = (SELECT Email FROM Employees WHERE EmployeeId = 2)'
PRINT ''
PRINT '2. CHANGE BY EMAIL:'
PRINT '   UPDATE Employees SET Password = ''NewPassword123'' WHERE Email = ''rahul.sharma@actionmedical.com'''
PRINT '   -- Then sync:'
PRINT '   UPDATE Users SET PasswordHash = e.Password FROM Users u '
PRINT '   INNER JOIN Employees e ON u.Username = e.Email'
PRINT ''
PRINT '3. RESET ALL TO SAME PASSWORD:'
PRINT '   UPDATE Employees SET Password = ''password123'''
PRINT '   UPDATE Users SET PasswordHash = ''password123'' WHERE Role = ''Employee'''
GO

-- Create a trigger to auto-sync password changes
PRINT '=== CREATING AUTO-SYNC TRIGGER ==='
GO

IF OBJECT_ID('trg_Employees_Password_Sync', 'TR') IS NOT NULL
    DROP TRIGGER trg_Employees_Password_Sync
GO

CREATE TRIGGER trg_Employees_Password_Sync
ON Employees
AFTER UPDATE
AS
BEGIN
    -- If Password column was updated, sync to Users table
    IF UPDATE(Password)
    BEGIN
        UPDATE u
        SET u.PasswordHash = i.Password
        FROM Users u
        INNER JOIN inserted i ON u.Username = i.Email
        WHERE i.Password IS NOT NULL
    END
END
GO

PRINT '✅ Trigger created: Password changes in Employees will auto-sync to Users table'
GO

PRINT ''
PRINT '=== NOW YOU CAN ==='
PRINT '✅ View all employees with passwords: SELECT * FROM Employees'
PRINT '✅ Change password: UPDATE Employees SET Password = ''NewPass'' WHERE EmployeeId = X'
PRINT '✅ Changes auto-sync to Users table via trigger!'
GO
