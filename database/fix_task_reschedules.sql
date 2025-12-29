-- =============================================
-- Drop and Recreate TaskReschedules Table (FIX)
-- =============================================
USE [marketing_db]
GO

-- Drop table if exists
IF OBJECT_ID('dbo.TaskReschedules', 'U') IS NOT NULL
BEGIN
    -- Drop foreign keys first
    IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_TaskReschedules_Tasks')
        ALTER TABLE dbo.TaskReschedules DROP CONSTRAINT FK_TaskReschedules_Tasks;
    
    IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_TaskReschedules_Users')
        ALTER TABLE dbo.TaskReschedules DROP CONSTRAINT FK_TaskReschedules_Users;
    
    DROP TABLE dbo.TaskReschedules;
END
GO

-- Create TaskReschedules table
CREATE TABLE [dbo].[TaskReschedules](
    [RescheduleId] INT IDENTITY(1,1) NOT NULL,
    [TaskId] INT NOT NULL,
    [OriginalTaskDate] DATETIME2 NOT NULL,
    [OriginalDeadline] DATETIME2 NOT NULL,
    [NewTaskDate] DATETIME2 NOT NULL,
    [NewDeadline] DATETIME2 NOT NULL,
    [RescheduleReason] NVARCHAR(500) NULL,
    [RescheduledByUserId] INT NOT NULL,
    [RescheduledAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [PK_TaskReschedules] PRIMARY KEY CLUSTERED ([RescheduleId] ASC)
);
GO

-- Create indexes
CREATE NONCLUSTERED INDEX [IX_TaskReschedules_TaskId] ON [dbo].[TaskReschedules] ([TaskId]);
GO

CREATE NONCLUSTERED INDEX [IX_TaskReschedules_RescheduledByUserId] ON [dbo].[TaskReschedules] ([RescheduledByUserId]);
GO

PRINT 'TaskReschedules table recreated successfully (without FK constraints for now)';
GO
