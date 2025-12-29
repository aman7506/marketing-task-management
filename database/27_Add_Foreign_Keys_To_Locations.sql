-- =============================================
-- ADD MISSING COLUMNS AND FOREIGN KEY CONSTRAINTS TO Locations TABLE
-- =============================================

USE marketing_db;
GO

-- Add missing foreign key columns to Locations table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Locations' AND COLUMN_NAME = 'StateId')
BEGIN
    ALTER TABLE Locations ADD StateId INT NULL;
    PRINT 'Added StateId column to Locations table';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Locations' AND COLUMN_NAME = 'AreaId')
BEGIN
    ALTER TABLE Locations ADD AreaId INT NULL;
    PRINT 'Added AreaId column to Locations table';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Locations' AND COLUMN_NAME = 'PincodeId')
BEGIN
    ALTER TABLE Locations ADD PincodeId INT NULL;
    PRINT 'Added PincodeId column to Locations table';
END

-- Add foreign key constraint for StateId
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Locations_States')
BEGIN
    ALTER TABLE Locations ADD CONSTRAINT FK_Locations_States FOREIGN KEY (StateId) REFERENCES States(StateId);
    PRINT 'Added FK_Locations_States constraint';
END

-- Add foreign key constraint for AreaId
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Locations_Areas')
BEGIN
    ALTER TABLE Locations ADD CONSTRAINT FK_Locations_Areas FOREIGN KEY (AreaId) REFERENCES Areas(AreaId);
    PRINT 'Added FK_Locations_Areas constraint';
END

-- Add foreign key constraint for PincodeId
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Locations_Pincodes')
BEGIN
    ALTER TABLE Locations ADD CONSTRAINT FK_Locations_Pincodes FOREIGN KEY (PincodeId) REFERENCES Pincodes(PincodeId);
    PRINT 'Added FK_Locations_Pincodes constraint';
END

GO
