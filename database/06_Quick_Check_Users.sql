USE marketing_db;
GO

-- Quick check to see current users
SELECT 'Current Users in Database:' AS Info;
SELECT 
    UserId,
    Username,
    Role,
    EmployeeId,
    IsActive
FROM Users
ORDER BY Role, Username;

-- Check if we have the demo credential users
SELECT 'Demo Credential Check:' AS Info;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM Users WHERE Username = 'admin@actionmedical.com') 
        THEN 'FOUND' 
        ELSE 'MISSING' 
    END AS AdminUser,
    CASE 
        WHEN EXISTS (SELECT 1 FROM Users WHERE Username = 'rahul.sharma@actionmedical.com') 
        THEN 'FOUND' 
        ELSE 'MISSING' 
    END AS EmployeeUser;