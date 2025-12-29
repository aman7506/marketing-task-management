USE marketing_db;
GO

-- =============================================
-- ADD MISSING TASK COLUMNS AND PARTIAL CLOSE STATUS
-- This script adds missing columns and updates status constraints
-- =============================================

PRINT '=============================================';
PRINT 'ADDING MISSING TASK COLUMNS';
PRINT '=============================================';

-- Add missing columns to Tasks table if they don't exist
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'TaskType')
BEGIN
    ALTER TABLE Tasks ADD TaskType NVARCHAR(50) NULL DEFAULT 'General';
    PRINT 'TaskType column added!';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'Department')
BEGIN
    ALTER TABLE Tasks ADD Department NVARCHAR(100) NULL DEFAULT 'Marketing';
    PRINT 'Department column added!';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'ClientName')
BEGIN
    ALTER TABLE Tasks ADD ClientName NVARCHAR(200) NULL;
    PRINT 'ClientName column added!';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'ProjectCode')
BEGIN
    ALTER TABLE Tasks ADD ProjectCode NVARCHAR(100) NULL;
    PRINT 'ProjectCode column added!';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'EmployeeIdNumber')
BEGIN
    ALTER TABLE Tasks ADD EmployeeIdNumber NVARCHAR(50) NULL;
    PRINT 'EmployeeIdNumber column added!';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'EstimatedHours')
BEGIN
    ALTER TABLE Tasks ADD EstimatedHours DECIMAL(5,2) NULL;
    PRINT 'EstimatedHours column added!';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'ActualHours')
BEGIN
    ALTER TABLE Tasks ADD ActualHours DECIMAL(5,2) NULL;
    PRINT 'ActualHours column added!';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'TaskCategory')
BEGIN
    ALTER TABLE Tasks ADD TaskCategory NVARCHAR(50) NULL DEFAULT 'Field Work';
    PRINT 'TaskCategory column added!';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'AdditionalNotes')
BEGIN
    ALTER TABLE Tasks ADD AdditionalNotes NVARCHAR(1000) NULL;
    PRINT 'AdditionalNotes column added!';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'IsUrgent')
BEGIN
    ALTER TABLE Tasks ADD IsUrgent BIT NOT NULL DEFAULT 0;
    PRINT 'IsUrgent column added!';
END

-- Update Status constraint to include 'Partial Close'
-- First, find and drop the existing constraint
DECLARE @ConstraintName NVARCHAR(128)
SELECT @ConstraintName = name 
FROM sys.check_constraints 
WHERE parent_object_id = OBJECT_ID('Tasks') 
AND definition LIKE '%Status%'

IF @ConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE Tasks DROP CONSTRAINT ' + @ConstraintName)
    PRINT 'Old Status constraint dropped!';
END

-- Add new constraint with 'Partial Close'
ALTER TABLE Tasks ADD CONSTRAINT CK_Tasks_Status 
CHECK (Status IN ('Not Started', 'In Progress', 'Completed', 'Postponed', 'Partial Close'));
PRINT 'New Status constraint added with Partial Close option!';

-- Update existing tasks with default values for new columns
UPDATE Tasks 
SET 
    TaskType = ISNULL(TaskType, 'General'),
    Department = ISNULL(Department, 'Marketing'),
    TaskCategory = ISNULL(TaskCategory, 'Field Work'),
    IsUrgent = ISNULL(IsUrgent, 0)
WHERE TaskType IS NULL OR Department IS NULL OR TaskCategory IS NULL OR IsUrgent IS NULL;

PRINT 'Existing tasks updated with default values!';

-- Verify the changes
PRINT 'Verifying updated table structure:';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Tasks' 
ORDER BY ORDINAL_POSITION;

PRINT '=============================================';
PRINT 'MISSING TASK COLUMNS ADDED SUCCESSFULLY!';
PRINT '=============================================';