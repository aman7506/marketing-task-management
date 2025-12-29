-- =============================================
-- FINAL FIX: Ensure UserId 1 Exists
-- =============================================
USE [marketing_db]
GO

PRINT '=== ENSURING USERID 1 EXISTS ==='
GO

-- Check if UserId = 1 exists
IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = 1)
BEGIN
    PRINT 'UserId 1 does not exist. Creating admin user...'
    
    SET IDENTITY_INSERT [dbo].[Users] ON
    
    INSERT INTO [dbo].[Users] (UserId, Username, PasswordHash, Role, IsActive, CreatedAt)
    VALUES (1, 'admin', 'admin123', 'Admin', 1, GETUTCDATE())
    
    SET IDENTITY_INSERT [dbo].[Users] OFF
    
    PRINT '✅ UserId 1 (admin) created successfully!'
END
ELSE
BEGIN
    PRINT '✅ UserId 1 already exists - no action needed'
END
GO

-- Verify
SELECT UserId, Username, Role, IsActive 
FROM [dbo].[Users] 
WHERE UserId = 1
GO

PRINT '=== COMPLETE - UserId 1 is ready! ==='
GO
