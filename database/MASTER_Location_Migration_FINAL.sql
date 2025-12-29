-- =============================================
-- FINAL FIX: Location Hierarchy Migration
-- Handles all schema variations and constraints
-- =============================================

USE [marketing_db];
GO

PRINT '========================================';
PRINT 'STEP 1: Analyzing Current Schema';
PRINT '========================================';
GO

-- Check if Areas has StateId column
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Areas]') AND name = 'StateId')
BEGIN
    PRINT '! Warning: Areas table has StateId column';
    PRINT '  This column will be populated during insert';
END

PRINT '✓ Schema analysis complete';
GO

PRINT '========================================';
PRINT 'STEP 2: Disabling Foreign Key Constraints';
PRINT '========================================';
GO

-- Disable all foreign key constraints temporarily
ALTER TABLE [dbo].[Locations] NOCHECK CONSTRAINT ALL;
ALTER TABLE [dbo].[Pincodes] NOCHECK CONSTRAINT ALL;
ALTER TABLE [dbo].[Areas] NOCHECK CONSTRAINT ALL;
ALTER TABLE [dbo].[Cities] NOCHECK CONSTRAINT ALL;
ALTER TABLE [dbo].[Tasks] NOCHECK CONSTRAINT ALL;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND type in (N'U'))
    ALTER TABLE [dbo].[MarketingCampaigns] NOCHECK CONSTRAINT ALL;

PRINT '✓ Foreign key constraints disabled';
GO

PRINT '========================================';
PRINT 'STEP 3: Clearing Existing Location Data';
PRINT '========================================';
GO

-- Clear existing data
DELETE FROM [dbo].[Pincodes];
DELETE FROM [dbo].[Areas];
DELETE FROM [dbo].[Cities];
DELETE FROM [dbo].[States];

PRINT '✓ Existing location data cleared';
GO

-- Reset identity seeds
DBCC CHECKIDENT ('[dbo].[Pincodes]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[Areas]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[Cities]', RESEED, 0);
DBCC CHECKIDENT ('[dbo].[States]', RESEED, 0);

PRINT '✓ Identity seeds reset';
GO

PRINT '========================================';
PRINT 'STEP 4: Inserting Delhi NCR Data';
PRINT '========================================';
GO

-- Insert States
INSERT INTO [dbo].[States] ([StateName], [StateCode], [IsActive], [CreatedAt])
VALUES 
    ('Delhi', 'DL', 1, GETUTCDATE()),
    ('Haryana', 'HR', 1, GETUTCDATE());

PRINT '✓ Inserted 2 states (Delhi, Haryana)';
GO

-- Insert Cities
INSERT INTO [dbo].[Cities] ([CityName], [StateId], [IsActive], [CreatedAt])
VALUES 
    ('Delhi', 1, 1, GETUTCDATE()),
    ('New Delhi', 1, 1, GETUTCDATE()),
    ('Delhi NCR', 1, 1, GETUTCDATE()),
    ('Gurugram', 2, 1, GETUTCDATE()),
    ('Gurgaon', 2, 1, GETUTCDATE());

PRINT '✓ Inserted 5 cities';
GO

-- Insert Localities (Areas) - WITH StateId if column exists
DECLARE @HasStateId BIT = 0;
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Areas]') AND name = 'StateId')
    SET @HasStateId = 1;

IF @HasStateId = 1
BEGIN
    -- Insert with StateId column
    INSERT INTO [dbo].[Areas] ([AreaName], [CityId], [StateId], [IsActive], [CreatedAt])
    SELECT 
        AreaName, CityId, 
        CASE 
            WHEN CityId IN (1, 2, 3) THEN 1  -- Delhi cities
            WHEN CityId IN (4, 5) THEN 2      -- Haryana cities
        END AS StateId,
        1 AS IsActive,
        GETUTCDATE() AS CreatedAt
    FROM (VALUES 
        ('Connaught Place', 1),
        ('Karol Bagh', 1),
        ('Rajouri Garden', 1),
        ('Dwarka', 1),
        ('Rohini', 1),
        ('Pitampura', 1),
        ('Saket', 1),
        ('Lajpat Nagar', 1),
        ('Nehru Place', 1),
        ('Janakpuri', 1),
        ('Chanakyapuri', 2),
        ('Barakhamba Road', 2),
        ('Kasturba Gandhi Marg', 2),
        ('Lodhi Road', 2),
        ('Defence Colony', 2),
        ('Noida', 3),
        ('Greater Noida', 3),
        ('Ghaziabad', 3),
        ('Faridabad', 3),
        ('Cyber City', 4),
        ('DLF Phase 1', 4),
        ('DLF Phase 2', 4),
        ('DLF Phase 3', 4),
        ('DLF Phase 4', 4),
        ('DLF Phase 5', 4),
        ('Sohna Road', 4),
        ('Golf Course Road', 4),
        ('MG Road', 4),
        ('Udyog Vihar', 4),
        ('Sector 14', 4),
        ('Cyber City', 5),
        ('DLF Phase 1', 5),
        ('DLF Phase 2', 5),
        ('DLF Phase 3', 5),
        ('Sohna Road', 5),
        ('Golf Course Road', 5),
        ('MG Road', 5)
    ) AS Source(AreaName, CityId);
END
ELSE
BEGIN
    -- Insert without StateId column
    INSERT INTO [dbo].[Areas] ([AreaName], [CityId], [IsActive], [CreatedAt])
    VALUES 
        ('Connaught Place', 1, 1, GETUTCDATE()),
        ('Karol Bagh', 1, 1, GETUTCDATE()),
        ('Rajouri Garden', 1, 1, GETUTCDATE()),
        ('Dwarka', 1, 1, GETUTCDATE()),
        ('Rohini', 1, 1, GETUTCDATE()),
        ('Pitampura', 1, 1, GETUTCDATE()),
        ('Saket', 1, 1, GETUTCDATE()),
        ('Lajpat Nagar', 1, 1, GETUTCDATE()),
        ('Nehru Place', 1, 1, GETUTCDATE()),
        ('Janakpuri', 1, 1, GETUTCDATE()),
        ('Chanakyapuri', 2, 1, GETUTCDATE()),
        ('Barakhamba Road', 2, 1, GETUTCDATE()),
        ('Kasturba Gandhi Marg', 2, 1, GETUTCDATE()),
        ('Lodhi Road', 2, 1, GETUTCDATE()),
        ('Defence Colony', 2, 1, GETUTCDATE()),
        ('Noida', 3, 1, GETUTCDATE()),
        ('Greater Noida', 3, 1, GETUTCDATE()),
        ('Ghaziabad', 3, 1, GETUTCDATE()),
        ('Faridabad', 3, 1, GETUTCDATE()),
        ('Cyber City', 4, 1, GETUTCDATE()),
        ('DLF Phase 1', 4, 1, GETUTCDATE()),
        ('DLF Phase 2', 4, 1, GETUTCDATE()),
        ('DLF Phase 3', 4, 1, GETUTCDATE()),
        ('DLF Phase 4', 4, 1, GETUTCDATE()),
        ('DLF Phase 5', 4, 1, GETUTCDATE()),
        ('Sohna Road', 4, 1, GETUTCDATE()),
        ('Golf Course Road', 4, 1, GETUTCDATE()),
        ('MG Road', 4, 1, GETUTCDATE()),
        ('Udyog Vihar', 4, 1, GETUTCDATE()),
        ('Sector 14', 4, 1, GETUTCDATE()),
        ('Cyber City', 5, 1, GETUTCDATE()),
        ('DLF Phase 1', 5, 1, GETUTCDATE()),
        ('DLF Phase 2', 5, 1, GETUTCDATE()),
        ('DLF Phase 3', 5, 1, GETUTCDATE()),
        ('Sohna Road', 5, 1, GETUTCDATE()),
        ('Golf Course Road', 5, 1, GETUTCDATE()),
        ('MG Road', 5, 1, GETUTCDATE());
END

PRINT '✓ Inserted 37 localities';
GO

-- Insert Pincodes
INSERT INTO [dbo].[Pincodes] ([Pincode], [LocalityName], [AreaId], [IsActive], [CreatedAt])
VALUES 
    ('110001', 'Connaught Place', 1, 1, GETUTCDATE()),
    ('110005', 'Karol Bagh', 2, 1, GETUTCDATE()),
    ('110027', 'Rajouri Garden', 3, 1, GETUTCDATE()),
    ('110075', 'Dwarka Sector 1', 4, 1, GETUTCDATE()),
    ('110077', 'Dwarka Sector 10', 4, 1, GETUTCDATE()),
    ('110078', 'Dwarka Sector 23', 4, 1, GETUTCDATE()),
    ('110085', 'Rohini Sector 3', 5, 1, GETUTCDATE()),
    ('110089', 'Rohini Sector 24', 5, 1, GETUTCDATE()),
    ('110034', 'Pitampura', 6, 1, GETUTCDATE()),
    ('110017', 'Saket', 7, 1, GETUTCDATE()),
    ('110024', 'Lajpat Nagar', 8, 1, GETUTCDATE()),
    ('110019', 'Nehru Place', 9, 1, GETUTCDATE()),
    ('110058', 'Janakpuri', 10, 1, GETUTCDATE()),
    ('110021', 'Chanakyapuri', 11, 1, GETUTCDATE()),
    ('110001', 'Barakhamba Road', 12, 1, GETUTCDATE()),
    ('110001', 'Kasturba Gandhi Marg', 13, 1, GETUTCDATE()),
    ('110003', 'Lodhi Road', 14, 1, GETUTCDATE()),
    ('110024', 'Defence Colony', 15, 1, GETUTCDATE()),
    ('201301', 'Noida Sector 1', 16, 1, GETUTCDATE()),
    ('201303', 'Noida Sector 18', 16, 1, GETUTCDATE()),
    ('201304', 'Noida Sector 62', 16, 1, GETUTCDATE()),
    ('201306', 'Greater Noida Alpha', 17, 1, GETUTCDATE()),
    ('201310', 'Greater Noida Pari Chowk', 17, 1, GETUTCDATE()),
    ('201001', 'Ghaziabad City', 18, 1, GETUTCDATE()),
    ('201002', 'Indirapuram', 18, 1, GETUTCDATE()),
    ('121001', 'Faridabad Sector 16', 19, 1, GETUTCDATE()),
    ('121002', 'Faridabad NIT', 19, 1, GETUTCDATE()),
    ('122002', 'Cyber City', 20, 1, GETUTCDATE()),
    ('122001', 'DLF Phase 1', 21, 1, GETUTCDATE()),
    ('122002', 'DLF Phase 2', 22, 1, GETUTCDATE()),
    ('122003', 'DLF Phase 3', 23, 1, GETUTCDATE()),
    ('122009', 'DLF Phase 4', 24, 1, GETUTCDATE()),
    ('122022', 'DLF Phase 5', 25, 1, GETUTCDATE()),
    ('122018', 'Sohna Road', 26, 1, GETUTCDATE()),
    ('122007', 'Golf Course Road', 27, 1, GETUTCDATE()),
    ('122001', 'MG Road', 28, 1, GETUTCDATE()),
    ('122016', 'Udyog Vihar', 29, 1, GETUTCDATE()),
    ('122001', 'Sector 14', 30, 1, GETUTCDATE()),
    ('122002', 'Cyber City', 31, 1, GETUTCDATE()),
    ('122001', 'DLF Phase 1', 32, 1, GETUTCDATE()),
    ('122002', 'DLF Phase 2', 33, 1, GETUTCDATE()),
    ('122003', 'DLF Phase 3', 34, 1, GETUTCDATE()),
    ('122018', 'Sohna Road', 35, 1, GETUTCDATE()),
    ('122007', 'Golf Course Road', 36, 1, GETUTCDATE()),
    ('122001', 'MG Road', 37, 1, GETUTCDATE());

PRINT '✓ Inserted 45 pincodes';
GO

PRINT '========================================';
PRINT 'STEP 5: Updating Tasks Table';
PRINT '========================================';
GO

-- Add location hierarchy columns to Tasks if they don't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'StateId')
    ALTER TABLE [dbo].[Tasks] ADD [StateId] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'CityId')
    ALTER TABLE [dbo].[Tasks] ADD [CityId] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'AreaId')
    ALTER TABLE [dbo].[Tasks] ADD [AreaId] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'PincodeId')
    ALTER TABLE [dbo].[Tasks] ADD [PincodeId] INT NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'StateName')
    ALTER TABLE [dbo].[Tasks] ADD [StateName] NVARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'CityName')
    ALTER TABLE [dbo].[Tasks] ADD [CityName] NVARCHAR(100) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'PincodeValue')
    ALTER TABLE [dbo].[Tasks] ADD [PincodeValue] NVARCHAR(10) NULL;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'LocalityName')
    ALTER TABLE [dbo].[Tasks] ADD [LocalityName] NVARCHAR(200) NULL;

PRINT '✓ Tasks table updated with location hierarchy columns';
GO

PRINT '========================================';
PRINT 'STEP 6: Cleaning Invalid Location References';
PRINT '========================================';
GO

-- Clear invalid StateId references in Locations table
UPDATE [dbo].[Locations] SET StateId = NULL WHERE StateId NOT IN (SELECT StateId FROM [dbo].[States]);
UPDATE [dbo].[Locations] SET CityId = NULL WHERE CityId NOT IN (SELECT CityId FROM [dbo].[Cities]);
UPDATE [dbo].[Locations] SET AreaId = NULL WHERE AreaId NOT IN (SELECT AreaId FROM [dbo].[Areas]);
UPDATE [dbo].[Locations] SET PincodeId = NULL WHERE PincodeId NOT IN (SELECT PincodeId FROM [dbo].[Pincodes]);

PRINT '✓ Invalid location references cleaned';
GO

PRINT '========================================';
PRINT 'STEP 7: Re-enabling Foreign Key Constraints';
PRINT '========================================';
GO

-- Re-enable foreign key constraints
ALTER TABLE [dbo].[Pincodes] WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE [dbo].[Areas] WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE [dbo].[Cities] WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE [dbo].[Tasks] WITH CHECK CHECK CONSTRAINT ALL;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND type in (N'U'))
    ALTER TABLE [dbo].[MarketingCampaigns] WITH CHECK CHECK CONSTRAINT ALL;

-- Re-enable Locations constraints last (after cleaning invalid references)
ALTER TABLE [dbo].[Locations] WITH CHECK CHECK CONSTRAINT ALL;

PRINT '✓ Foreign key constraints re-enabled';
GO

PRINT '========================================';
PRINT 'STEP 8: Verifying Data';
PRINT '========================================';
GO

DECLARE @StateCount INT, @CityCount INT, @AreaCount INT, @PincodeCount INT;

SELECT @StateCount = COUNT(*) FROM [dbo].[States];
SELECT @CityCount = COUNT(*) FROM [dbo].[Cities];
SELECT @AreaCount = COUNT(*) FROM [dbo].[Areas];
SELECT @PincodeCount = COUNT(*) FROM [dbo].[Pincodes];

PRINT '✓ States: ' + CAST(@StateCount AS VARCHAR(10));
PRINT '✓ Cities: ' + CAST(@CityCount AS VARCHAR(10));
PRINT '✓ Localities: ' + CAST(@AreaCount AS VARCHAR(10));
PRINT '✓ Pincodes: ' + CAST(@PincodeCount AS VARCHAR(10));

-- Verify hierarchical relationships
SELECT 
    s.StateName,
    COUNT(DISTINCT c.CityId) AS Cities,
    COUNT(DISTINCT a.AreaId) AS Localities,
    COUNT(DISTINCT p.PincodeId) AS Pincodes
FROM [dbo].[States] s
LEFT JOIN [dbo].[Cities] c ON s.StateId = c.StateId
LEFT JOIN [dbo].[Areas] a ON c.CityId = a.CityId
LEFT JOIN [dbo].[Pincodes] p ON a.AreaId = p.AreaId
GROUP BY s.StateName;

GO

PRINT '========================================';
PRINT '✅ MIGRATION COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'Data Summary:';
PRINT '- States: 2 (Delhi, Haryana)';
PRINT '- Cities: 5';
PRINT '- Localities: 37';
PRINT '- Pincodes: 45';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Test API: GET http://localhost:5000/api/states';
PRINT '2. Test API: GET http://localhost:5000/api/cities?stateId=1';
PRINT '3. Test API: GET http://localhost:5000/api/locations/localities?cityId=4';
PRINT '4. Test API: GET http://localhost:5000/api/locations/pincodes?localityId=20';
PRINT '';
PRINT '✅ Database is ready for production!';
GO
