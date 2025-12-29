USE marketing_db;
GO

-- =============================================
-- ADD TASK STATUS HISTORY AND DEMONSTRATE TABLE JOINS
-- This script creates sample task status history and shows proper join queries
-- =============================================

PRINT '=============================================';
PRINT 'ADDING TASK STATUS HISTORY WITH TABLE JOINS';
PRINT '=============================================';

-- First, let's add some task status history records
PRINT 'Adding sample task status history records...';

-- Get some task IDs and user IDs for our sample data
DECLARE @TaskId1 INT = (SELECT TOP 1 TaskId FROM Tasks WHERE EmployeeId = (SELECT EmployeeId FROM Employees WHERE Name = 'Dr. Arjun Mehta'));
DECLARE @TaskId2 INT = (SELECT TOP 1 TaskId FROM Tasks WHERE EmployeeId = (SELECT EmployeeId FROM Employees WHERE Name = 'Kavya Sharma'));
DECLARE @TaskId3 INT = (SELECT TOP 1 TaskId FROM Tasks WHERE EmployeeId = (SELECT EmployeeId FROM Employees WHERE Name = 'Ananya Joshi'));
DECLARE @TaskId4 INT = (SELECT TOP 1 TaskId FROM Tasks WHERE EmployeeId = (SELECT EmployeeId FROM Employees WHERE Name = 'Deepika Verma'));
DECLARE @TaskId5 INT = (SELECT TOP 1 TaskId FROM Tasks WHERE EmployeeId = (SELECT EmployeeId FROM Employees WHERE Name = 'Riya Bansal'));

DECLARE @AdminUserId INT = (SELECT UserId FROM Users WHERE Role = 'Admin');
DECLARE @ArjunUserId INT = (SELECT UserId FROM Users WHERE Username = 'arjun.mehta@actionmedical.com');
DECLARE @KavyaUserId INT = (SELECT UserId FROM Users WHERE Username = 'kavya.sharma@actionmedical.com');
DECLARE @AnanyaUserId INT = (SELECT UserId FROM Users WHERE Username = 'ananya.joshi@actionmedical.com');
DECLARE @DeepikaUserId INT = (SELECT UserId FROM Users WHERE Username = 'deepika.verma@actionmedical.com');
DECLARE @RiyaUserId INT = (SELECT UserId FROM Users WHERE Username = 'riya.bansal@actionmedical.com');

-- Insert sample task status history
INSERT INTO TaskStatusHistory (TaskId, Status, Remarks, ChangedByUserId, ChangedAt) VALUES
-- Dr. Arjun Mehta's task progression
(@TaskId1, 'Not Started', 'Task assigned to Dr. Arjun Mehta for Q4 marketing strategy development', @AdminUserId, DATEADD(day, -5, GETDATE())),
(@TaskId1, 'In Progress', 'Started working on market analysis and budget allocation', @ArjunUserId, DATEADD(day, -3, GETDATE())),
(@TaskId1, 'In Progress', 'Completed competitive analysis, working on ROI projections', @ArjunUserId, DATEADD(day, -1, GETDATE())),

-- Kavya Sharma's task progression
(@TaskId2, 'Not Started', 'Multi-channel campaign task assigned to Kavya Sharma', @AdminUserId, DATEADD(day, -4, GETDATE())),
(@TaskId2, 'In Progress', 'Coordinating with digital and print advertising teams', @KavyaUserId, DATEADD(day, -2, GETDATE())),

-- Ananya Joshi's task progression
(@TaskId3, 'Not Started', 'Google Ads and Facebook campaign task assigned', @AdminUserId, DATEADD(day, -6, GETDATE())),
(@TaskId3, 'In Progress', 'Set up Google Ads account and created initial campaigns', @AnanyaUserId, DATEADD(day, -4, GETDATE())),
(@TaskId3, 'In Progress', 'Facebook campaigns launched, monitoring performance', @AnanyaUserId, DATEADD(day, -2, GETDATE())),
(@TaskId3, 'Completed', 'All campaigns are live and performing well. Initial results are promising.', @AnanyaUserId, DATEADD(hour, -6, GETDATE())),

-- Deepika Verma's task progression
(@TaskId4, 'Not Started', 'Field operations supervision task assigned', @AdminUserId, DATEADD(day, -3, GETDATE())),
(@TaskId4, 'In Progress', 'Started coordinating with field teams in Dwarka region', @DeepikaUserId, DATEADD(day, -1, GETDATE())),

-- Riya Bansal's task progression
(@TaskId5, 'Not Started', 'Data analysis task assigned for patient data and campaign performance', @AdminUserId, DATEADD(day, -7, GETDATE())),
(@TaskId5, 'In Progress', 'Collected data from various sources, starting analysis', @RiyaUserId, DATEADD(day, -5, GETDATE())),
(@TaskId5, 'In Progress', 'Identified key trends, preparing insights report', @RiyaUserId, DATEADD(day, -2, GETDATE()));

PRINT 'Task status history records added successfully!';

PRINT '';
PRINT '=============================================';
PRINT 'DEMONSTRATING TABLE JOINS';
PRINT '=============================================';

-- 1. Query TaskStatusHistory by Employee Name (what you requested)
PRINT '1. TASK STATUS HISTORY FOR DR. ARJUN MEHTA:';
PRINT '--------------------------------------------';
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
WHERE e.Name = 'Dr. Arjun Mehta'
ORDER BY tsh.ChangedAt;

PRINT '';
PRINT '2. TASK STATUS HISTORY FOR ALL EMPLOYEES:';
PRINT '------------------------------------------';
SELECT 
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
ORDER BY e.Name, tsh.ChangedAt;

PRINT '';
PRINT '3. CURRENT TASK STATUS SUMMARY BY EMPLOYEE:';
PRINT '--------------------------------------------';
SELECT 
    e.Name as EmployeeName,
    e.Designation,
    COUNT(CASE WHEN t.Status = 'Not Started' THEN 1 END) as NotStarted,
    COUNT(CASE WHEN t.Status = 'In Progress' THEN 1 END) as InProgress,
    COUNT(CASE WHEN t.Status = 'Completed' THEN 1 END) as Completed,
    COUNT(CASE WHEN t.Status = 'Postponed' THEN 1 END) as Postponed,
    COUNT(t.TaskId) as TotalTasks
FROM Employees e
LEFT JOIN Tasks t ON e.EmployeeId = t.EmployeeId
GROUP BY e.EmployeeId, e.Name, e.Designation
HAVING COUNT(t.TaskId) > 0
ORDER BY TotalTasks DESC, e.Name;

PRINT '';
PRINT '4. DETAILED TASK INFORMATION WITH EMPLOYEE DETAILS:';
PRINT '----------------------------------------------------';
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
    l.LocationName,
    l.State,
    t.EstimatedHours,
    t.Deadline,
    assignedBy.Username as AssignedByUser
FROM Tasks t
INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
LEFT JOIN Locations l ON t.LocationId = l.LocationId
INNER JOIN Users assignedBy ON t.AssignedByUserId = assignedBy.UserId
ORDER BY e.Name, t.Priority DESC;

PRINT '';
PRINT '5. EMPLOYEES WITH THEIR LATEST TASK STATUS CHANGES:';
PRINT '----------------------------------------------------';
WITH LatestStatusChange AS (
    SELECT 
        t.EmployeeId,
        MAX(tsh.ChangedAt) as LatestChange
    FROM TaskStatusHistory tsh
    INNER JOIN Tasks t ON tsh.TaskId = t.TaskId
    GROUP BY t.EmployeeId
)
SELECT 
    e.Name as EmployeeName,
    e.Designation,
    tsh.Status as LatestStatus,
    tsh.Remarks as LatestRemarks,
    tsh.ChangedAt as LastUpdated,
    changedBy.Username as LastUpdatedBy
FROM LatestStatusChange lsc
INNER JOIN Employees e ON lsc.EmployeeId = e.EmployeeId
INNER JOIN Tasks t ON e.EmployeeId = t.EmployeeId
INNER JOIN TaskStatusHistory tsh ON t.TaskId = tsh.TaskId AND tsh.ChangedAt = lsc.LatestChange
INNER JOIN Users changedBy ON tsh.ChangedByUserId = changedBy.UserId
ORDER BY tsh.ChangedAt DESC;

PRINT '';
PRINT '=============================================';
PRINT 'USEFUL JOIN QUERY EXAMPLES FOR YOUR REFERENCE:';
PRINT '=============================================';

PRINT '';
PRINT 'QUERY 1: Find all task status history for a specific employee';
PRINT 'SELECT * FROM TaskStatusHistory tsh';
PRINT 'INNER JOIN Tasks t ON tsh.TaskId = t.TaskId';
PRINT 'INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId';
PRINT 'WHERE e.Name = ''Dr. Arjun Mehta'';';

PRINT '';
PRINT 'QUERY 2: Find all employees with their current task counts';
PRINT 'SELECT e.Name, COUNT(t.TaskId) as TaskCount';
PRINT 'FROM Employees e';
PRINT 'LEFT JOIN Tasks t ON e.EmployeeId = t.EmployeeId';
PRINT 'GROUP BY e.EmployeeId, e.Name;';

PRINT '';
PRINT 'QUERY 3: Find all tasks with employee and location details';
PRINT 'SELECT t.*, e.Name, e.Designation, l.LocationName';
PRINT 'FROM Tasks t';
PRINT 'INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId';
PRINT 'LEFT JOIN Locations l ON t.LocationId = l.LocationId;';

PRINT '';
PRINT '=============================================';
PRINT 'TABLE RELATIONSHIPS ESTABLISHED SUCCESSFULLY!';
PRINT 'You can now query across all tables using proper JOINs';
PRINT '=============================================';