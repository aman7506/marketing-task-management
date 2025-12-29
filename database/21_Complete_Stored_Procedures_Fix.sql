-- Complete fix for all missing stored procedures
USE [marketing_db]
GO

PRINT '============================================='
PRINT 'FIXING MISSING STORED PROCEDURES'
PRINT '============================================='

-- 1. Create sp_GetStates stored procedure
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetStates')
    DROP PROCEDURE [dbo].[sp_GetStates]
GO

CREATE PROCEDURE [dbo].[sp_GetStates]
AS
BEGIN
  SET NOCOUNT ON;
  SELECT StateId, StateName, StateCode, IsActive 
  FROM States 
  WHERE IsActive = 1 
  ORDER BY StateName;
END
GO

PRINT 'sp_GetStates created successfully!'

-- 2. Create sp_GetCitiesByState stored procedure (using Areas table)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetCitiesByState')
    DROP PROCEDURE [dbo].[sp_GetCitiesByState]
GO

CREATE PROCEDURE [dbo].[sp_GetCitiesByState]
  @StateId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT AreaId as CityId, AreaName as CityName 
  FROM Areas 
  WHERE StateId = @StateId AND IsActive = 1 
  ORDER BY AreaName;
END
GO

PRINT 'sp_GetCitiesByState created successfully!'

-- 3. Create sp_GetPincodesByArea stored procedure
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetPincodesByArea')
    DROP PROCEDURE [dbo].[sp_GetPincodesByArea]
GO

CREATE PROCEDURE [dbo].[sp_GetPincodesByArea]
  @AreaId INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT PincodeId, Pincode as PincodeValue, AreaId, LocalityName, IsActive
  FROM Pincodes 
  WHERE AreaId = @AreaId AND IsActive = 1 
  ORDER BY Pincode;
END
GO

PRINT 'sp_GetPincodesByArea created successfully!'

-- 4. Verify all required stored procedures exist
PRINT ''
PRINT 'Verifying stored procedures...'

-- Check if all required procedures exist
DECLARE @MissingProcs TABLE (ProcName NVARCHAR(100))
INSERT INTO @MissingProcs (ProcName)
SELECT 'sp_GetEmployees' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetEmployees')
UNION ALL
SELECT 'sp_GetStates' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetStates')
UNION ALL
SELECT 'sp_GetCitiesByState' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetCitiesByState')
UNION ALL
SELECT 'sp_GetLocations' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetLocations')
UNION ALL
SELECT 'sp_GetTasks' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetTasks')
UNION ALL
SELECT 'sp_GetUsers' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUsers')
UNION ALL
SELECT 'sp_GetUserByUsername' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetUserByUsername')
UNION ALL
SELECT 'GetEmployeeSummary' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetEmployeeSummary')
UNION ALL
SELECT 'GetHighPriorityTasks' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetHighPriorityTasks')
UNION ALL
SELECT 'GetTasksByDepartment' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetTasksByDepartment')
UNION ALL
SELECT 'GetTasksByEmployee' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetTasksByEmployee')
UNION ALL
SELECT 'GetTaskStatusHistoryByEmployee' WHERE NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'GetTaskStatusHistoryByEmployee');

IF (SELECT COUNT(*) FROM @MissingProcs) > 0
BEGIN
    PRINT 'Missing stored procedures:'
    SELECT ProcName FROM @MissingProcs
END
ELSE
BEGIN
    PRINT 'All required stored procedures are present!'
END

PRINT ''
PRINT '============================================='
PRINT 'STORED PROCEDURES FIX COMPLETE!'
PRINT '============================================='
