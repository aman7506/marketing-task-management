/*
    Script: create_location_logs.sql
    Purpose: Persist real-time employee locations for tracking module.
    Notes:
        - Compatible with SQL Server 2019+
        - Ensure the MarketingTask database context is aware of this table.
*/

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LocationLogs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[LocationLogs]
    (
        [LogId]        BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [EmployeeId]   INT NOT NULL,
        [Latitude]     DECIMAL(9,6) NOT NULL,
        [Longitude]    DECIMAL(9,6) NOT NULL,
        [Timestamp]    DATETIME2(3) NOT NULL CONSTRAINT DF_LocationLogs_Timestamp DEFAULT (SYSUTCDATETIME())
    );

    CREATE NONCLUSTERED INDEX IX_LocationLogs_Employee_Timestamp
        ON [dbo].[LocationLogs]([EmployeeId], [Timestamp] DESC);
END
GO

