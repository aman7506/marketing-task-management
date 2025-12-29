-- Fix the sp_GetCitiesByState stored procedure to use Areas table instead of Cities
USE [marketing_db]
GO

-- Drop the existing procedure if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetCitiesByState')
BEGIN
    DROP PROCEDURE [dbo].[sp_GetCitiesByState]
END
GO

-- Create the corrected stored procedure using Areas table
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

PRINT 'sp_GetCitiesByState stored procedure fixed to use Areas table!'
