-- =============================================
-- Create TaskReschedules Table
-- =============================================
USE [marketing_db]
GO

-- Drop table if exists
IF OBJECT_ID('dbo.TaskReschedules', 'U') IS NOT NULL
    DROP TABLE dbo.TaskReschedules;
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
    CONSTRAINT [PK_TaskReschedules] PRIMARY KEY CLUSTERED ([RescheduleId] ASC),
    CONSTRAINT [FK_TaskReschedules_Tasks] FOREIGN KEY ([TaskId]) 
        REFERENCES [dbo].[Tasks]([TaskId]) ON DELETE CASCADE,
    CONSTRAINT [FK_TaskReschedules_Users] FOREIGN KEY ([RescheduledByUserId]) 
        REFERENCES [dbo].[Users]([UserId])
);
GO

-- Create indexes
CREATE NONCLUSTERED INDEX [IX_TaskReschedules_TaskId] ON [dbo].[TaskReschedules] ([TaskId]);
GO

CREATE NONCLUSTERED INDEX [IX_TaskReschedules_RescheduledByUserId] ON [dbo].[TaskReschedules] ([RescheduledByUserId]);
GO

PRINT 'TaskReschedules table created successfully';
GO
