USE marketing_db;
GO

-- =============================================
-- ADD COMPREHENSIVE TASK FIELDS
-- This script adds additional fields to the Tasks table
-- =============================================

PRINT '=============================================';
PRINT 'ADDING COMPREHENSIVE TASK FIELDS';
PRINT '=============================================';

-- Add new columns to Tasks table
ALTER TABLE Tasks ADD 
    TaskType NVARCHAR(50) NULL DEFAULT 'General',
    Department NVARCHAR(100) NULL DEFAULT 'Marketing',
    ClientName NVARCHAR(200) NULL,
    ProjectCode NVARCHAR(100) NULL,
    EstimatedHours DECIMAL(5,2) NULL,
    ActualHours DECIMAL(5,2) NULL,
    TaskCategory NVARCHAR(50) NULL DEFAULT 'Field Work',
    AdditionalNotes NVARCHAR(1000) NULL,
    IsUrgent BIT NOT NULL DEFAULT 0;

PRINT 'New columns added to Tasks table successfully!';

-- Update existing tasks with default values
UPDATE Tasks 
SET 
    TaskType = 'General',
    Department = 'Marketing',
    TaskCategory = 'Field Work',
    IsUrgent = 0;

PRINT 'Existing tasks updated with default values!';

-- Verify the changes
PRINT 'Verifying table structure:';
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Tasks' 
    AND COLUMN_NAME IN ('TaskType', 'Department', 'ClientName', 'ProjectCode', 'EstimatedHours', 'ActualHours', 'TaskCategory', 'AdditionalNotes', 'IsUrgent')
ORDER BY ORDINAL_POSITION;

PRINT '=============================================';
PRINT 'COMPREHENSIVE TASK FIELDS ADDED SUCCESSFULLY!';
PRINT '=============================================';