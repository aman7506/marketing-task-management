-- ========================================
-- FIX USER PASSWORDS - PLAINTEXT TEMPORARY FIX
-- ========================================
-- The AuthService has a built-in mechanism to upgrade plaintext
-- passwords to properly hashed passwords on first login.
-- This script will set all passwords as plaintext temporarily,
-- and they will be automatically hashed on first use.
-- ========================================

USE marketing_db;
GO

PRINT '========================================';
PRINT 'FIXING USER PASSWORD HASHES';
PRINT '========================================';

-- Update Admin User with plaintext password (will be auto-hashed on login)
UPDATE Users 
SET PasswordHash = 'Admin123!'
WHERE Username = 'admin@actionmedical.com';
PRINT 'Updated admin password to plaintext (will auto-hash on login)';

-- Update all Employee users with plaintext password (will be auto-hashed on login)
UPDATE Users 
SET PasswordHash = 'Employee123!'
WHERE Role = 'Employee';
PRINT 'Updated all employee passwords to plaintext (will auto-hash on login)';

-- Verify the updates
SELECT 
    UserId,
    Username,
    Role,
    PasswordHash,
    CASE 
        WHEN LEN(PasswordHash) < 50 THEN 'Plaintext (will auto-hash)'
        ELSE 'Hashed'
    END AS PasswordStatus
FROM Users
ORDER BY Role, Username;

PRINT '';
PRINT '========================================';
PRINT 'PASSWORD FIXES COMPLETE!';
PRINT '';
PRINT 'You can now login with:';
PRINT '  Admin: admin@actionmedical.com / Admin123!';
PRINT '  Employees: {email} / Employee123!';
PRINT '';
PRINT 'Passwords will be automatically hashed on first login.';
PRINT '========================================';

GO
