-- =============================================
-- Fix TaskStatusHistories Table - Add UserId Column
-- =============================================
USE [marketing_db]
GO

PRINT '=== FIXING TaskStatusHistories TABLE ==='
GO

-- Check if UserId column exists
IF NOT EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('dbo.TaskStatusHistories') 
    AND name = 'UserId'
)
BEGIN
    PRINT 'Adding UserId column to TaskStatusHistories table...'
    
    ALTER TABLE [dbo].[TaskStatusHistories]
    ADD [UserId] INT NULL
    
    PRINT '✅ UserId column added successfully!'
END
ELSE
BEGIN
    PRINT '✅ UserId column already exists - no action needed'
END
GO

-- Verify the fix
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'TaskStatusHistories'
AND COLUMN_NAME IN ('UserId', 'ChangedByUserId')
ORDER BY COLUMN_NAME
GO

PRINT '=== FIX COMPLETE ==='
GO
