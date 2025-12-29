-- =============================================
-- MASTER SCRIPT: Execute All Location Hierarchy Updates
-- Run this in SQL Server Management Studio
-- =============================================

USE [MarketingTaskDB];
GO

PRINT '========================================';
PRINT 'STEP 1: Creating Delhi NCR Location Schema';
PRINT '========================================';
GO

-- =============================================
-- Drop existing foreign keys if they exist
-- =============================================
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Cities_States')
    ALTER TABLE [dbo].[Cities] DROP CONSTRAINT [FK_Cities_States];
    
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Areas_Cities')
    ALTER TABLE [dbo].[Areas] DROP CONSTRAINT [FK_Areas_Cities];
    
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Pincodes_Areas')
    ALTER TABLE [dbo].[Pincodes] DROP CONSTRAINT [FK_Pincodes_Areas];

-- =============================================
-- 1. STATES TABLE
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[States]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[States] (
        [StateId] INT IDENTITY(1,1) PRIMARY KEY,
        [StateName] NVARCHAR(100) NOT NULL,
        [StateCode] NVARCHAR(10) NOT NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME NOT NULL DEFAULT GETUTCDATE()
    );
    PRINT '✓ States table created';
END
ELSE
BEGIN
    PRINT '✓ States table already exists';
END
GO

-- =============================================
-- 2. CITIES TABLE
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Cities]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Cities] (
        [CityId] INT IDENTITY(1,1) PRIMARY KEY,
        [CityName] NVARCHAR(100) NOT NULL,
        [StateId] INT NOT NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_Cities_States] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States]([StateId])
    );
    PRINT '✓ Cities table created';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Cities_States')
    BEGIN
        ALTER TABLE [dbo].[Cities] 
        ADD CONSTRAINT [FK_Cities_States] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States]([StateId]);
        PRINT '✓ Cities foreign key added';
    END
    PRINT '✓ Cities table already exists';
END
GO

-- =============================================
-- 3. AREAS TABLE (Localities)
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Areas]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Areas] (
        [AreaId] INT IDENTITY(1,1) PRIMARY KEY,
        [AreaName] NVARCHAR(200) NOT NULL,
        [CityId] INT NOT NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_Areas_Cities] FOREIGN KEY ([CityId]) REFERENCES [dbo].[Cities]([CityId])
    );
    PRINT '✓ Areas table created';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Areas_Cities')
    BEGIN
        ALTER TABLE [dbo].[Areas] 
        ADD CONSTRAINT [FK_Areas_Cities] FOREIGN KEY ([CityId]) REFERENCES [dbo].[Cities]([CityId]);
        PRINT '✓ Areas foreign key added';
    END
    PRINT '✓ Areas table already exists';
END
GO

-- =============================================
-- 4. PINCODES TABLE
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Pincodes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Pincodes] (
        [PincodeId] INT IDENTITY(1,1) PRIMARY KEY,
        [Pincode] NVARCHAR(10) NOT NULL,
        [LocalityName] NVARCHAR(200) NULL,
        [AreaId] INT NOT NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedAt] DATETIME NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT [FK_Pincodes_Areas] FOREIGN KEY ([AreaId]) REFERENCES [dbo].[Areas]([AreaId])
    );
    PRINT '✓ Pincodes table created';
END
ELSE
BEGIN
    -- Ensure Pincode column exists
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Pincodes]') AND name = 'Pincode')
    BEGIN
        IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Pincodes]') AND name = 'PincodeValue')
        BEGIN
            EXEC sp_rename '[dbo].[Pincodes].[PincodeValue]', 'Pincode', 'COLUMN';
            PRINT '✓ Renamed PincodeValue to Pincode';
        END
        ELSE
        BEGIN
            ALTER TABLE [dbo].[Pincodes] ADD [Pincode] NVARCHAR(10) NOT NULL DEFAULT '';
            PRINT '✓ Pincode column added';
        END
    END
    
    IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Pincodes_Areas')
    BEGIN
        ALTER TABLE [dbo].[Pincodes] 
        ADD CONSTRAINT [FK_Pincodes_Areas] FOREIGN KEY ([AreaId]) REFERENCES [dbo].[Areas]([AreaId]);
        PRINT '✓ Pincodes foreign key added';
    END
    PRINT '✓ Pincodes table already exists';
END
GO

PRINT '========================================';
PRINT 'STEP 2: Clearing Existing Data';
PRINT '========================================';
GO

DELETE FROM [dbo].[Pincodes];
DELETE FROM [dbo].[Areas];
DELETE FROM [dbo].[Cities];
DELETE FROM [dbo].[States];
PRINT '✓ Existing location data cleared';
GO

PRINT '========================================';
PRINT 'STEP 3: Inserting Delhi NCR Data';
PRINT '========================================';
GO

-- Insert States
SET IDENTITY_INSERT [dbo].[States] ON;
INSERT INTO [dbo].[States] ([StateId], [StateName], [StateCode], [IsActive], [CreatedAt])
VALUES 
    (1, 'Delhi', 'DL', 1, GETUTCDATE()),
    (2, 'Haryana', 'HR', 1, GETUTCDATE());
SET IDENTITY_INSERT [dbo].[States] OFF;
PRINT '✓ Inserted 2 states';
GO

-- Insert Cities
SET IDENTITY_INSERT [dbo].[Cities] ON;
INSERT INTO [dbo].[Cities] ([CityId], [CityName], [StateId], [IsActive], [CreatedAt])
VALUES 
    (1, 'Delhi', 1, 1, GETUTCDATE()),
    (2, 'New Delhi', 1, 1, GETUTCDATE()),
    (3, 'Delhi NCR', 1, 1, GETUTCDATE()),
    (4, 'Gurugram', 2, 1, GETUTCDATE()),
    (5, 'Gurgaon', 2, 1, GETUTCDATE());
SET IDENTITY_INSERT [dbo].[Cities] OFF;
PRINT '✓ Inserted 5 cities';
GO

-- Insert Localities (Areas) - Truncated for brevity, showing pattern
SET IDENTITY_INSERT [dbo].[Areas] ON;
INSERT INTO [dbo].[Areas] ([AreaId], [AreaName], [CityId], [IsActive], [CreatedAt])
VALUES 
    -- Delhi Localities
    (1, 'Connaught Place', 1, 1, GETUTCDATE()),
    (2, 'Karol Bagh', 1, 1, GETUTCDATE()),
    (3, 'Rajouri Garden', 1, 1, GETUTCDATE()),
    (4, 'Dwarka', 1, 1, GETUTCDATE()),
    (5, 'Rohini', 1, 1, GETUTCDATE()),
    (6, 'Pitampura', 1, 1, GETUTCDATE()),
    (7, 'Saket', 1, 1, GETUTCDATE()),
    (8, 'Lajpat Nagar', 1, 1, GETUTCDATE()),
    (9, 'Nehru Place', 1, 1, GETUTCDATE()),
    (10, 'Janakpuri', 1, 1, GETUTCDATE()),
    -- New Delhi Localities
    (11, 'Chanakyapuri', 2, 1, GETUTCDATE()),
    (12, 'Barakhamba Road', 2, 1, GETUTCDATE()),
    (13, 'Kasturba Gandhi Marg', 2, 1, GETUTCDATE()),
    (14, 'Lodhi Road', 2, 1, GETUTCDATE()),
    (15, 'Defence Colony', 2, 1, GETUTCDATE()),
    -- Delhi NCR Localities
    (16, 'Noida', 3, 1, GETUTCDATE()),
    (17, 'Greater Noida', 3, 1, GETUTCDATE()),
    (18, 'Ghaziabad', 3, 1, GETUTCDATE()),
    (19, 'Faridabad', 3, 1, GETUTCDATE()),
    -- Gurugram Localities
    (20, 'Cyber City', 4, 1, GETUTCDATE()),
    (21, 'DLF Phase 1', 4, 1, GETUTCDATE()),
    (22, 'DLF Phase 2', 4, 1, GETUTCDATE()),
    (23, 'DLF Phase 3', 4, 1, GETUTCDATE()),
    (24, 'DLF Phase 4', 4, 1, GETUTCDATE()),
    (25, 'DLF Phase 5', 4, 1, GETUTCDATE()),
    (26, 'Sohna Road', 4, 1, GETUTCDATE()),
    (27, 'Golf Course Road', 4, 1, GETUTCDATE()),
    (28, 'MG Road', 4, 1, GETUTCDATE()),
    (29, 'Udyog Vihar', 4, 1, GETUTCDATE()),
    (30, 'Sector 14', 4, 1, GETUTCDATE()),
    -- Gurgaon (alternate spelling)
    (31, 'Cyber City', 5, 1, GETUTCDATE()),
    (32, 'DLF Phase 1', 5, 1, GETUTCDATE()),
    (33, 'DLF Phase 2', 5, 1, GETUTCDATE()),
    (34, 'DLF Phase 3', 5, 1, GETUTCDATE()),
    (35, 'Sohna Road', 5, 1, GETUTCDATE()),
    (36, 'Golf Course Road', 5, 1, GETUTCDATE()),
    (37, 'MG Road', 5, 1, GETUTCDATE());
SET IDENTITY_INSERT [dbo].[Areas] OFF;
PRINT '✓ Inserted 37 localities';
GO

-- Insert Pincodes -truncated for brevity
SET IDENTITY_INSERT [dbo].[Pincodes] ON;
INSERT INTO [dbo].[Pincodes] ([PincodeId], [Pincode], [LocalityName], [AreaId], [IsActive], [CreatedAt])
VALUES 
    (1, '110001', 'Connaught Place', 1, 1, GETUTCDATE()),
    (2, '110005', 'Karol Bagh', 2, 1, GETUTCDATE()),
    (3, '110027', 'Rajouri Garden', 3, 1, GETUTCDATE()),
    (4, '110075', 'Dwarka Sector 1', 4, 1, GETUTCDATE()),
    (5, '110077', 'Dwarka Sector 10', 4, 1, GETUTCDATE()),
    (28, '122002', 'Cyber City', 20, 1, GETUTCDATE()),
    (29, '122001', 'DLF Phase 1', 21, 1, GETUTCDATE()),
    (30, '122002', 'DLF Phase 2', 22, 1, GETUTCDATE()),
    (31, '122003', 'DLF Phase 3', 23, 1, GETUTCDATE()),
    (35, '122007', 'Golf Course Road', 27, 1, GETUTCDATE());
-- Add more as needed...
SET IDENTITY_INSERT [dbo].[Pincodes] OFF;
PRINT '✓ Inserted pincodes (sample shown)';
GO

PRINT '========================================';
PRINT 'STEP 4: Updating Tasks Table';
PRINT '========================================';
GO

-- Add location hierarchy columns to Tasks
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
PRINT 'COMPLETITION SUMMARY';
PRINT '========================================';
PRINT '✓ Location hierarchy schema created';
PRINT '✓ Delhi NCR data inserted';
PRINT '✓ Tasks table updated';
PRINT '';
PRINT 'Data Summary:';
PRINT '- States: 2 (Delhi, Haryana)';
PRINT '- Cities: 5';
PRINT '- Localities: 37';
PRINT '- Pincodes: Sample data inserted';
PRINT '';
PRINT '✅ Database migration complete!';
PRINT 'Next: Test APIs at /api/states, /api/cities, /api/locations/localities, /api/locations/pincodes';
GO
