-- Fix TaskStatusHistories table name issue
USE [marketing_db]
GO

-- Check if TaskStatusHistory exists and rename to TaskStatusHistories
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TaskStatusHistory')
BEGIN
    EXEC sp_rename 'TaskStatusHistory', 'TaskStatusHistories';
    PRINT 'Table renamed from TaskStatusHistory to TaskStatusHistories';
END
ELSE IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TaskStatusHistories')
BEGIN
    PRINT 'TaskStatusHistories table already exists';
END
ELSE
BEGIN
    -- Create TaskStatusHistories table if it doesn't exist
    CREATE TABLE [dbo].[TaskStatusHistories](
        [StatusHistoryId] INT IDENTITY(1,1) NOT NULL,
        [TaskId] INT NOT NULL,
        [Status] NVARCHAR(20) NOT NULL,
        [Remarks] NVARCHAR(500) NULL,
        [ChangedByUserId] INT NOT NULL,
        [ChangedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [PK_TaskStatusHistories] PRIMARY KEY CLUSTERED ([StatusHistoryId] ASC)
    );
    
    CREATE NONCLUSTERED INDEX [IX_TaskStatusHistories_TaskId] ON [dbo].[TaskStatusHistories] ([TaskId]);
    
    PRINT 'TaskStatusHistories table created';
END
GO
