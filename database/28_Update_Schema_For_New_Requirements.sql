-- =============================================
-- UPDATE DATABASE SCHEMA FOR NEW REQUIREMENTS
-- =============================================

USE marketing_db;
GO

-- Add EmployeeCode column to Employees table if it doesn't exist
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Employees' AND COLUMN_NAME = 'EmployeeCode')
BEGIN
    ALTER TABLE Employees ADD EmployeeCode NVARCHAR(50) NULL;
    PRINT 'Added EmployeeCode column to Employees table';
END

-- Add ConsultantFeedback column to Tasks table if it doesn't exist
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'ConsultantFeedback')
BEGIN
    ALTER TABLE Tasks ADD ConsultantFeedback NVARCHAR(1000) NULL;
    PRINT 'Added ConsultantFeedback column to Tasks table';
END

-- Update TaskStatuses table to include "Partial Close" status
IF NOT EXISTS (SELECT * FROM TaskStatuses WHERE StatusName = 'Partial Close')
BEGIN
    INSERT INTO TaskStatuses (StatusName, StatusCode) VALUES ('Partial Close', 'PARTIAL_CLOSE');
    PRINT 'Added Partial Close status';
END

-- Update TaskTypes table to include "Meeting Consultant" and other types
IF NOT EXISTS (SELECT * FROM TaskTypes WHERE TypeName = 'Meeting Consultant')
BEGIN
    INSERT INTO TaskTypes (TypeName, Description, IsActive) VALUES 
    ('Meeting Consultant', 'Meeting with consultant', 1);
    PRINT 'Added Meeting Consultant task type';
END

-- Add other task types if they don't exist
IF NOT EXISTS (SELECT * FROM TaskTypes WHERE TypeName = 'Client Meeting')
BEGIN
    INSERT INTO TaskTypes (TypeName, Description, IsActive) VALUES 
    ('Client Meeting', 'Client meetings and presentations', 1);
    PRINT 'Added Client Meeting task type';
END

IF NOT EXISTS (SELECT * FROM TaskTypes WHERE TypeName = 'Training')
BEGIN
    INSERT INTO TaskTypes (TypeName, Description, IsActive) VALUES 
    ('Training', 'Training and development activities', 1);
    PRINT 'Added Training task type';
END

-- Update existing employees to have EmployeeCode (generate if missing)
UPDATE Employees 
SET EmployeeCode = 'EMP' + RIGHT('000' + CAST(EmployeeId AS VARCHAR(3)), 3)
WHERE EmployeeCode IS NULL OR EmployeeCode = '';

PRINT 'Updated employee codes for existing employees';

-- Verify the changes
SELECT 'Employees Table' as TableName, COUNT(*) as RecordCount FROM Employees
UNION ALL
SELECT 'TaskStatuses Table' as TableName, COUNT(*) as RecordCount FROM TaskStatuses
UNION ALL
SELECT 'TaskTypes Table' as TableName, COUNT(*) as RecordCount FROM TaskTypes;

PRINT 'Database schema update completed successfully!';
GO
