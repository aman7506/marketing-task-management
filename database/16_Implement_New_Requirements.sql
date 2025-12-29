USE marketing_db;
GO

-- =============================================
-- IMPLEMENT NEW REQUIREMENTS
-- This script implements all the new requirements:
-- 1. Add Employee ID field to tasks
-- 2. Add Partial Close status
-- 3. Add Employee Feedback field
-- 4. Support for multiple locations and task types
-- =============================================

PRINT '=============================================';
PRINT 'IMPLEMENTING NEW REQUIREMENTS';
PRINT '=============================================';

-- 1. Add Employee ID field to Tasks table (separate from EmployeeId foreign key)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'EmployeeIdNumber')
BEGIN
    ALTER TABLE Tasks ADD EmployeeIdNumber NVARCHAR(50) NULL;
    PRINT 'EmployeeIdNumber column added to Tasks table!';
END
ELSE
BEGIN
    PRINT 'EmployeeIdNumber column already exists in Tasks table.';
END

-- 2. Update Status constraint to include 'Partial Close'
-- First, drop the existing constraint
IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK__Tasks__Status__*' OR name LIKE '%Tasks%Status%')
BEGIN
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
END

-- Add new constraint with 'Partial Close'
ALTER TABLE Tasks ADD CONSTRAINT CK_Tasks_Status 
CHECK (Status IN ('Not Started', 'In Progress', 'Completed', 'Postponed', 'Partial Close'));
PRINT 'New Status constraint added with Partial Close option!';

-- 3. Create Employee Feedback table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'EmployeeFeedback')
BEGIN
    CREATE TABLE EmployeeFeedback (
        FeedbackId INT PRIMARY KEY IDENTITY(1,1),
        TaskId INT NOT NULL,
        EmployeeId INT NOT NULL,
        ConsultantName NVARCHAR(200) NULL,
        FeedbackText NVARCHAR(2000) NOT NULL,
        MeetingDate DATETIME NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        UpdatedAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (TaskId) REFERENCES Tasks(TaskId),
        FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
    );
    PRINT 'EmployeeFeedback table created successfully!';
END
ELSE
BEGIN
    PRINT 'EmployeeFeedback table already exists.';
END

-- 4. Create tables for multiple selections support

-- Task Locations junction table (for multiple location support)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TaskLocations')
BEGIN
    CREATE TABLE TaskLocations (
        TaskLocationId INT PRIMARY KEY IDENTITY(1,1),
        TaskId INT NOT NULL,
        LocationId INT NOT NULL,
        CustomLocation NVARCHAR(100) NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (TaskId) REFERENCES Tasks(TaskId),
        FOREIGN KEY (LocationId) REFERENCES Locations(LocationId),
        UNIQUE(TaskId, LocationId)
    );
    PRINT 'TaskLocations table created successfully!';
END
ELSE
BEGIN
    PRINT 'TaskLocations table already exists.';
END

-- Task Types lookup table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TaskTypes')
BEGIN
    CREATE TABLE TaskTypes (
        TaskTypeId INT PRIMARY KEY IDENTITY(1,1),
        TypeName NVARCHAR(50) NOT NULL UNIQUE,
        Description NVARCHAR(200) NULL,
        IsActive BIT DEFAULT 1,
        CreatedAt DATETIME DEFAULT GETDATE()
    );
    PRINT 'TaskTypes table created successfully!';
    
    -- Insert default task types
    INSERT INTO TaskTypes (TypeName, Description) VALUES
    ('General', 'General marketing tasks'),
    ('Marketing Campaign', 'Marketing campaign related tasks'),
    ('Client Meeting', 'Client meeting and consultation tasks'),
    ('Field Survey', 'Field survey and data collection tasks'),
    ('Data Collection', 'Data collection and analysis tasks'),
    ('Report Generation', 'Report generation and documentation tasks'),
    ('Training', 'Training and development tasks'),
    ('Event Management', 'Event planning and management tasks');
    
    PRINT 'Default task types inserted!';
END
ELSE
BEGIN
    PRINT 'TaskTypes table already exists.';
END

-- Task Type junction table (for multiple task type support)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TaskTaskTypes')
BEGIN
    CREATE TABLE TaskTaskTypes (
        TaskTaskTypeId INT PRIMARY KEY IDENTITY(1,1),
        TaskId INT NOT NULL,
        TaskTypeId INT NOT NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (TaskId) REFERENCES Tasks(TaskId),
        FOREIGN KEY (TaskTypeId) REFERENCES TaskTypes(TaskTypeId),
        UNIQUE(TaskId, TaskTypeId)
    );
    PRINT 'TaskTaskTypes table created successfully!';
END
ELSE
BEGIN
    PRINT 'TaskTaskTypes table already exists.';
END

-- 5. Update existing data to maintain compatibility
-- Migrate existing single location to TaskLocations table
IF EXISTS (SELECT * FROM Tasks WHERE LocationId IS NOT NULL)
BEGIN
    INSERT INTO TaskLocations (TaskId, LocationId, CustomLocation)
    SELECT TaskId, LocationId, CustomLocation
    FROM Tasks 
    WHERE LocationId IS NOT NULL
    AND TaskId NOT IN (SELECT TaskId FROM TaskLocations);
    
    PRINT 'Existing task locations migrated to TaskLocations table!';
END

-- Migrate existing task types to TaskTaskTypes table
IF EXISTS (SELECT * FROM Tasks WHERE TaskType IS NOT NULL)
BEGIN
    INSERT INTO TaskTaskTypes (TaskId, TaskTypeId)
    SELECT t.TaskId, tt.TaskTypeId
    FROM Tasks t
    INNER JOIN TaskTypes tt ON t.TaskType = tt.TypeName
    WHERE t.TaskType IS NOT NULL
    AND t.TaskId NOT IN (SELECT TaskId FROM TaskTaskTypes);
    
    PRINT 'Existing task types migrated to TaskTaskTypes table!';
END

-- 6. Create indexes for better performance
CREATE NONCLUSTERED INDEX IX_TaskLocations_TaskId ON TaskLocations(TaskId);
CREATE NONCLUSTERED INDEX IX_TaskTaskTypes_TaskId ON TaskTaskTypes(TaskId);
CREATE NONCLUSTERED INDEX IX_EmployeeFeedback_TaskId ON EmployeeFeedback(TaskId);
CREATE NONCLUSTERED INDEX IX_EmployeeFeedback_EmployeeId ON EmployeeFeedback(EmployeeId);

PRINT 'Performance indexes created!';

-- 7. Verify the changes
PRINT 'Verifying new table structures:';

SELECT 'Tasks - New Columns' as TableInfo;
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Tasks' 
    AND COLUMN_NAME IN ('EmployeeIdNumber')
ORDER BY ORDINAL_POSITION;

SELECT 'EmployeeFeedback Table' as TableInfo;
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'EmployeeFeedback'
ORDER BY ORDINAL_POSITION;

SELECT 'TaskLocations Table' as TableInfo;
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'TaskLocations'
ORDER BY ORDINAL_POSITION;

SELECT 'TaskTypes Table' as TableInfo;
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'TaskTypes'
ORDER BY ORDINAL_POSITION;

SELECT 'TaskTaskTypes Table' as TableInfo;
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'TaskTaskTypes'
ORDER BY ORDINAL_POSITION;

PRINT '=============================================';
PRINT 'NEW REQUIREMENTS IMPLEMENTED SUCCESSFULLY!';
PRINT '=============================================';