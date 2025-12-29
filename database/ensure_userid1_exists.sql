-- Ensure UserId 1 exists for reschedule operations
USE [marketing_db]
GO

-- Check if UserId = 1 exists
IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE UserId = 1)
BEGIN
    PRINT 'UserId 1 does not exist. Creating...'
    
    -- Insert a default admin user with UserId = 1
    SET IDENTITY_INSERT [dbo].[Users] ON
    
    INSERT INTO [dbo].[Users] (UserId, Username, PasswordHash, Role, IsActive, CreatedAt)
    VALUES (1, 'admin', 'admin123', 'Admin', 1, GETUTCDATE())
    
    SET IDENTITY_INSERT [dbo].[Users] OFF
    
    PRINT 'UserId 1 created successfully'
END
ELSE
BEGIN
    PRINT 'UserId 1 already exists'
END
GO

-- Verify
SELECT UserId, Username, Role FROM [dbo].[Users] WHERE UserId = 1
GO
