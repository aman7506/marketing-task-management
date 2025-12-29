-- =============================================
-- CREATE MISSING TABLES: States, Areas, Pincodes
-- =============================================

USE marketing_db;
GO

-- Create States table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'States')
BEGIN
    CREATE TABLE States (
        StateId INT PRIMARY KEY IDENTITY(1,1),
        StateName NVARCHAR(100) NOT NULL,
        StateCode NVARCHAR(10) NOT NULL,
        IsActive BIT DEFAULT 1
    );
    PRINT 'Created States table';
END

-- Create Areas table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Areas')
BEGIN
    CREATE TABLE Areas (
        AreaId INT PRIMARY KEY IDENTITY(1,1),
        AreaName NVARCHAR(100) NOT NULL,
        StateId INT NOT NULL,
        IsActive BIT DEFAULT 1,
        FOREIGN KEY (StateId) REFERENCES States(StateId)
    );
    PRINT 'Created Areas table';
END

-- Create Pincodes table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pincodes')
BEGIN
    CREATE TABLE Pincodes (
        PincodeId INT PRIMARY KEY IDENTITY(1,1),
        Pincode NVARCHAR(10) NOT NULL,
        AreaId INT NOT NULL,
        LocalityName NVARCHAR(200),
        IsActive BIT DEFAULT 1,
        FOREIGN KEY (AreaId) REFERENCES Areas(AreaId)
    );
    PRINT 'Created Pincodes table';
END

GO
