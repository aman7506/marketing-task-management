USE marketing_db;
GO

-- =============================================
-- CREATE USEFUL STORED PROCEDURES FOR TABLE JOINS
-- These procedures make it easy to query related data
-- =============================================

PRINT '=============================================';
PRINT 'CREATING USEFUL STORED PROCEDURES';
PRINT '=============================================';

-- 1. Get Task Status History by Employee Name
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetTaskStatusHistoryByEmployee')
    DROP PROCEDURE GetTaskStatusHistoryByEmployee;
GO

CREATE PROCEDURE GetTaskStatusHistoryByEmployee
    @EmployeeName NVARCHAR(100)
AS
BEGIN
    SELECT 
        tsh.HistoryId,
        e.Name as EmployeeName,
        e.Designation,
        t.Description as TaskDescription,
        tsh.Status,
        tsh.Remarks,
        tsh.ChangedAt,
        changedBy.Username as ChangedByUser
    FROM TaskStatusHistory tsh
    INNER JOIN Tasks t ON tsh.TaskId = t.TaskId
    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
    INNER JOIN Users changedBy ON tsh.ChangedByUserId = changedBy.UserId
    WHERE e.Name = @EmployeeName
    ORDER BY tsh.ChangedAt;
END
GO

-- 2. Get All Tasks by Employee Name
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetTasksByEmployee')
    DROP PROCEDURE GetTasksByEmployee;
GO

CREATE PROCEDURE GetTasksByEmployee
    @EmployeeName NVARCHAR(100)
AS
BEGIN
    SELECT 
        t.TaskId,
        e.Name as EmployeeName,
        e.Designation,
        e.Email,
        t.Description,
        t.Priority,
        t.Status,
        t.TaskType,
        t.Department,
        COALESCE(l.LocationName, t.CustomLocation, 'No Location') as Location,
        COALESCE(l.State, 'N/A') as State,
        t.EstimatedHours,
        t.Deadline,
        assignedBy.Username as AssignedByUser,
        t.CreatedAt
    FROM Tasks t
    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
    LEFT JOIN Locations l ON t.LocationId = l.LocationId
    INNER JOIN Users assignedBy ON t.AssignedByUserId = assignedBy.UserId
    WHERE e.Name = @EmployeeName
    ORDER BY t.Priority DESC, t.Deadline;
END
GO

-- 3. Get Employee Summary with Task Counts
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetEmployeeSummary')
    DROP PROCEDURE GetEmployeeSummary;
GO

CREATE PROCEDURE GetEmployeeSummary
AS
BEGIN
    SELECT 
        e.Name as EmployeeName,
        e.Designation,
        e.Email,
        COUNT(t.TaskId) as TotalTasks,
        SUM(t.EstimatedHours) as TotalEstimatedHours,
        COUNT(CASE WHEN t.Status = 'Not Started' THEN 1 END) as NotStarted,
        COUNT(CASE WHEN t.Status = 'In Progress' THEN 1 END) as InProgress,
        COUNT(CASE WHEN t.Status = 'Completed' THEN 1 END) as Completed,
        COUNT(CASE WHEN t.Status = 'Postponed' THEN 1 END) as Postponed,
        COUNT(CASE WHEN t.Priority = 'High' THEN 1 END) as HighPriorityTasks,
        COUNT(CASE WHEN t.Deadline < GETDATE() AND t.Status != 'Completed' THEN 1 END) as OverdueTasks
    FROM Employees e
    LEFT JOIN Tasks t ON e.EmployeeId = t.EmployeeId
    GROUP BY e.EmployeeId, e.Name, e.Designation, e.Email
    ORDER BY TotalTasks DESC, e.Name;
END
GO

-- 4. Get Tasks by Department
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetTasksByDepartment')
    DROP PROCEDURE GetTasksByDepartment;
GO

CREATE PROCEDURE GetTasksByDepartment
    @Department NVARCHAR(100)
AS
BEGIN
    SELECT 
        t.TaskId,
        e.Name as EmployeeName,
        e.Designation,
        t.Description,
        t.Priority,
        t.Status,
        t.TaskType,
        t.Department,
        t.EstimatedHours,
        t.Deadline,
        assignedBy.Username as AssignedByUser
    FROM Tasks t
    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
    INNER JOIN Users assignedBy ON t.AssignedByUserId = assignedBy.UserId
    WHERE t.Department = @Department
    ORDER BY t.Priority DESC, t.Deadline, e.Name;
END
GO

-- 5. Get High Priority Tasks
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetHighPriorityTasks')
    DROP PROCEDURE GetHighPriorityTasks;
GO

CREATE PROCEDURE GetHighPriorityTasks
AS
BEGIN
    SELECT 
        t.TaskId,
        e.Name as AssignedTo,
        e.Designation,
        e.Email as EmployeeEmail,
        t.Description,
        t.TaskType,
        t.Department,
        COALESCE(l.LocationName + ', ' + l.State, t.CustomLocation, 'No Location') as Location,
        t.EstimatedHours,
        t.Deadline,
        t.Status,
        assignedBy.Username as AssignedBy,
        CASE 
            WHEN t.Deadline < GETDATE() AND t.Status != 'Completed' THEN 'OVERDUE'
            WHEN t.Deadline <= DATEADD(day, 3, GETDATE()) AND t.Status != 'Completed' THEN 'DUE SOON'
            ELSE 'ON TRACK'
        END as UrgencyStatus,
        t.CreatedAt
    FROM Tasks t
    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
    LEFT JOIN Locations l ON t.LocationId = l.LocationId
    INNER JOIN Users assignedBy ON t.AssignedByUserId = assignedBy.UserId
    WHERE t.Priority = 'High'
    ORDER BY 
        CASE 
            WHEN t.Deadline < GETDATE() AND t.Status != 'Completed' THEN 1
            WHEN t.Deadline <= DATEADD(day, 3, GETDATE()) AND t.Status != 'Completed' THEN 2
            ELSE 3
        END,
        t.Deadline, e.Name;
END
GO

PRINT 'Stored procedures created successfully!';
PRINT '';
PRINT '=============================================';
PRINT 'TESTING STORED PROCEDURES';
PRINT '=============================================';

-- Test the stored procedures
PRINT '1. Testing GetTaskStatusHistoryByEmployee for Dr. Arjun Mehta:';
EXEC GetTaskStatusHistoryByEmployee 'Dr. Arjun Mehta';

PRINT '';
PRINT '2. Testing GetTasksByEmployee for Ananya Joshi:';
EXEC GetTasksByEmployee 'Ananya Joshi';

PRINT '';
PRINT '3. Testing GetTasksByDepartment for Marketing:';
EXEC GetTasksByDepartment 'Marketing';

PRINT '';
PRINT '4. Testing GetHighPriorityTasks:';
EXEC GetHighPriorityTasks;

PRINT '';
PRINT '5. Testing GetEmployeeSummary:';
EXEC GetEmployeeSummary;

PRINT '';
PRINT '=============================================';
PRINT 'STORED PROCEDURES USAGE EXAMPLES:';
PRINT '=============================================';
PRINT '';
PRINT 'EXEC GetTaskStatusHistoryByEmployee ''Dr. Arjun Mehta'';';
PRINT 'EXEC GetTasksByEmployee ''Kavya Sharma'';';
PRINT 'EXEC GetTasksByDepartment ''Marketing'';';
PRINT 'EXEC GetHighPriorityTasks;';
PRINT 'EXEC GetEmployeeSummary;';
PRINT '';
PRINT '=============================================';
PRINT 'STORED PROCEDURES CREATED SUCCESSFULLY!';
PRINT '=============================================';