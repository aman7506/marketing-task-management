-- =============================================
-- ADD MISSING COLUMNS TO Tasks TABLE
-- =============================================

USE marketing_db;
GO

-- Add StateId column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'StateId')
BEGIN
    ALTER TABLE Tasks ADD StateId INT NULL;
    PRINT 'Added StateId column to Tasks table';
END

-- Add TaskType column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'TaskType')
BEGIN
    ALTER TABLE Tasks ADD TaskType NVARCHAR(50) NULL DEFAULT 'General';
    PRINT 'Added TaskType column to Tasks table';
END

-- Add Department column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'Department')
BEGIN
    ALTER TABLE Tasks ADD Department NVARCHAR(100) NULL DEFAULT 'Marketing';
    PRINT 'Added Department column to Tasks table';
END

-- Add ClientName column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'ClientName')
BEGIN
    ALTER TABLE Tasks ADD ClientName NVARCHAR(200) NULL;
    PRINT 'Added ClientName column to Tasks table';
END

-- Add ProjectCode column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'ProjectCode')
BEGIN
    ALTER TABLE Tasks ADD ProjectCode NVARCHAR(100) NULL;
    PRINT 'Added ProjectCode column to Tasks table';
END

-- Add EstimatedHours column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'EstimatedHours')
BEGIN
    ALTER TABLE Tasks ADD EstimatedHours DECIMAL(5,2) NULL;
    PRINT 'Added EstimatedHours column to Tasks table';
END

-- Add ActualHours column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'ActualHours')
BEGIN
    ALTER TABLE Tasks ADD ActualHours DECIMAL(5,2) NULL;
    PRINT 'Added ActualHours column to Tasks table';
END

-- Add TaskCategory column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'TaskCategory')
BEGIN
    ALTER TABLE Tasks ADD TaskCategory NVARCHAR(50) NULL DEFAULT 'Field Work';
    PRINT 'Added TaskCategory column to Tasks table';
END

-- Add AdditionalNotes column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'AdditionalNotes')
BEGIN
    ALTER TABLE Tasks ADD AdditionalNotes NVARCHAR(1000) NULL;
    PRINT 'Added AdditionalNotes column to Tasks table';
END

-- Add IsUrgent column if missing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'IsUrgent')
BEGIN
    ALTER TABLE Tasks ADD IsUrgent BIT NOT NULL DEFAULT 0;
    PRINT 'Added IsUrgent column to Tasks table';
END

GO
