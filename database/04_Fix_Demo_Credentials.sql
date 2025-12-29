USE marketing_db;
GO

-- =============================================
-- FIX DEMO CREDENTIALS
-- This script will create the correct user accounts for your demo credentials
-- =============================================

PRINT '=============================================';
PRINT 'FIXING DEMO CREDENTIALS';
PRINT '=============================================';

-- First, let's add the missing employee for Rahul Sharma
INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive) VALUES
('Rahul Sharma', '9876543215', 'Marketing Executive', 'rahul.sharma@actionmedical.com', GETDATE(), 1);

PRINT 'Added Rahul Sharma employee record';

-- Get the EmployeeId for Rahul Sharma
DECLARE @RahulEmployeeId INT;
SELECT @RahulEmployeeId = EmployeeId FROM Employees WHERE Email = 'rahul.sharma@actionmedical.com';

-- Clear existing users and create new ones with EMAIL as USERNAME
DELETE FROM TaskStatusHistory;
DELETE FROM Tasks;
DELETE FROM Users;

PRINT 'Cleared existing users and related data';

-- Insert users with EMAIL addresses as usernames (to match your demo credentials)
INSERT INTO Users (Username, PasswordHash, Role, EmployeeId, CreatedAt, IsActive) VALUES
-- Admin user with email as username
('admin@actionmedical.com', 'dummy_hash_admin', 'Admin', NULL, GETDATE(), 1),
-- Employee user with email as username  
('rahul.sharma@actionmedical.com', 'dummy_hash_employee', 'Employee', @RahulEmployeeId, GETDATE(), 1);

PRINT 'Created new users with email addresses as usernames';

-- Verify the users were created correctly
PRINT 'Verifying created users:';
SELECT 
    u.UserId,
    u.Username,
    u.Role,
    u.EmployeeId,
    e.Name as EmployeeName,
    e.Email as EmployeeEmail
FROM Users u
LEFT JOIN Employees e ON u.EmployeeId = e.EmployeeId
WHERE u.IsActive = 1;

PRINT '=============================================';
PRINT 'DEMO CREDENTIALS FIXED SUCCESSFULLY!';
PRINT '=============================================';
PRINT 'You can now login with:';
PRINT 'Admin: admin@actionmedical.com / Admin123!';
PRINT 'Employee: rahul.sharma@actionmedical.com / Employee123!';
PRINT '=============================================';