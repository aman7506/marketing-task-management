-- =============================================
-- Delhi NCR Location Hierarchy Database Schema
-- State → City → Locality → Pincode
-- =============================================

USE [MarketingTaskDB];
GO

-- Drop existing foreign keys if they exist
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
END
ELSE
BEGIN
    -- Add foreign key if table exists but constraint doesn't
    IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Cities_States')
    BEGIN
        ALTER TABLE [dbo].[Cities] 
        ADD CONSTRAINT [FK_Cities_States] FOREIGN KEY ([StateId]) REFERENCES [dbo].[States]([StateId]);
    END
END
GO

-- =============================================
-- 3. LOCALITIES TABLE (renamed from Areas)
-- =============================================
-- For this schema, we'll use Areas table but consider it as Localities
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
END
ELSE
BEGIN
    -- Add foreign key if table exists but constraint doesn't
    IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Areas_Cities')
    BEGIN
        ALTER TABLE [dbo].[Areas] 
        ADD CONSTRAINT [FK_Areas_Cities] FOREIGN KEY ([CityId]) REFERENCES [dbo].[Cities]([CityId]);
    END
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
END
ELSE
BEGIN
    -- Ensure Pincode column exists
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Pincodes]') AND name = 'Pincode')
    BEGIN
        IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Pincodes]') AND name = 'PincodeValue')
        BEGIN
            EXEC sp_rename '[dbo].[Pincodes].[PincodeValue]', 'Pincode', 'COLUMN';
        END
        ELSE
        BEGIN
            ALTER TABLE [dbo].[Pincodes] ADD [Pincode] NVARCHAR(10) NOT NULL DEFAULT '';
        END
    END
    
    -- Add foreign key if table exists but constraint doesn't
    IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Pincodes_Areas')
    BEGIN
        ALTER TABLE [dbo].[Pincodes] 
        ADD CONSTRAINT [FK_Pincodes_Areas] FOREIGN KEY ([AreaId]) REFERENCES [dbo].[Areas]([AreaId]);
    END
END
GO

-- =============================================
-- 5. CLEAR EXISTING DATA (Delhi NCR only)
-- =============================================
DELETE FROM [dbo].[Pincodes];
DELETE FROM [dbo].[Areas];
DELETE FROM [dbo].[Cities];
DELETE FROM [dbo].[States];
GO

-- =============================================
-- 6. INSERT DELHI NCR DATA
-- =============================================

-- STATES
SET IDENTITY_INSERT [dbo].[States] ON;
INSERT INTO [dbo].[States] ([StateId], [StateName], [StateCode], [IsActive], [CreatedAt])
VALUES 
    (1, 'Delhi', 'DL', 1, GETUTCDATE()),
    (2, 'Haryana', 'HR', 1, GETUTCDATE());
SET IDENTITY_INSERT [dbo].[States] OFF;
GO

-- CITIES
SET IDENTITY_INSERT [dbo].[Cities] ON;
INSERT INTO [dbo].[Cities] ([CityId], [CityName], [StateId], [IsActive], [CreatedAt])
VALUES 
    -- Delhi Cities
    (1, 'Delhi', 1, 1, GETUTCDATE()),
    (2, 'New Delhi', 1, 1, GETUTCDATE()),
    (3, 'Delhi NCR', 1, 1, GETUTCDATE()),
    
    -- Haryana Cities
    (4, 'Gurugram', 2, 1, GETUTCDATE()),
    (5, 'Gurgaon', 2, 1, GETUTCDATE());
SET IDENTITY_INSERT [dbo].[Cities] OFF;
GO

-- LOCALITIES (Areas)
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
    
    -- Gurgaon Localities (same as Gurugram, alternate spelling)
    (31, 'Cyber City', 5, 1, GETUTCDATE()),
    (32, 'DLF Phase 1', 5, 1, GETUTCDATE()),
    (33, 'DLF Phase 2', 5, 1, GETUTCDATE()),
    (34, 'DLF Phase 3', 5, 1, GETUTCDATE()),
    (35, 'Sohna Road', 5, 1, GETUTCDATE()),
    (36, 'Golf Course Road', 5, 1, GETUTCDATE()),
    (37, 'MG Road', 5, 1, GETUTCDATE());
SET IDENTITY_INSERT [dbo].[Areas] OFF;
GO

-- PINCODES
SET IDENTITY_INSERT [dbo].[Pincodes] ON;
INSERT INTO [dbo].[Pincodes] ([PincodeId], [Pincode], [LocalityName], [AreaId], [IsActive], [CreatedAt])
VALUES 
    -- Connaught Place
    (1, '110001', 'Connaught Place', 1, 1, GETUTCDATE()),
    
    -- Karol Bagh
    (2, '110005', 'Karol Bagh', 2, 1, GETUTCDATE()),
    
    -- Rajouri Garden
    (3, '110027', 'Rajouri Garden', 3, 1, GETUTCDATE()),
    
    -- Dwarka
    (4, '110075', 'Dwarka Sector 1', 4, 1, GETUTCDATE()),
    (5, '110077', 'Dwarka Sector 10', 4, 1, GETUTCDATE()),
    (6, '110078', 'Dwarka Sector 23', 4, 1, GETUTCDATE()),
    
    -- Rohini
    (7, '110085', 'Rohini Sector 3', 5, 1, GETUTCDATE()),
    (8, '110089', 'Rohini Sector 24', 5, 1, GETUTCDATE()),
    
    -- Pitampura
    (9, '110034', 'Pitampura', 6, 1, GETUTCDATE()),
    
    -- Saket
    (10, '110017', 'Saket', 7, 1, GETUTCDATE()),
    
    -- Lajpat Nagar
    (11, '110024', 'Lajpat Nagar', 8, 1, GETUTCDATE()),
    
    -- Nehru Place
    (12, '110019', 'Nehru Place', 9, 1, GETUTCDATE()),
    
    -- Janakpuri
    (13, '110058', 'Janakpuri', 10, 1, GETUTCDATE()),
    
    -- Chanakyapuri
    (14, '110021', 'Chanakyapuri', 11, 1, GETUTCDATE()),
    
    -- Barakhamba Road
    (15, '110001', 'Barakhamba Road', 12, 1, GETUTCDATE()),
    
    -- Kasturba Gandhi Marg
    (16, '110001', 'Kasturba Gandhi Marg', 13, 1, GETUTCDATE()),
    
    -- Lodhi Road
    (17, '110003', 'Lodhi Road', 14, 1, GETUTCDATE()),
    
    -- Defence Colony
    (18, '110024', 'Defence Colony', 15, 1, GETUTCDATE()),
    
    -- Noida
    (19, '201301', 'Noida Sector 1', 16, 1, GETUTCDATE()),
    (20, '201303', 'Noida Sector 18', 16, 1, GETUTCDATE()),
    (21, '201304', 'Noida Sector 62', 16, 1, GETUTCDATE()),
    
    -- Greater Noida
    (22, '201306', 'Greater Noida Alpha', 17, 1, GETUTCDATE()),
    (23, '201310', 'Greater Noida Pari Chowk', 17, 1, GETUTCDATE()),
    
    -- Ghaziabad
    (24, '201001', 'Ghaziabad City', 18, 1, GETUTCDATE()),
    (25, '201002', 'Indirapuram', 18, 1, GETUTCDATE()),
    
    -- Faridabad
    (26, '121001', 'Faridabad Sector 16', 19, 1, GETUTCDATE()),
    (27, '121002', 'Faridabad NIT', 19, 1, GETUTCDATE()),
    
    -- Gurugram - Cyber City
    (28, '122002', 'Cyber City', 20, 1, GETUTCDATE()),
    
    -- Gurugram - DLF Phases
    (29, '122001', 'DLF Phase 1', 21, 1, GETUTCDATE()),
    (30, '122002', 'DLF Phase 2', 22, 1, GETUTCDATE()),
    (31, '122003', 'DLF Phase 3', 23, 1, GETUTCDATE()),
    (32, '122009', 'DLF Phase 4', 24, 1, GETUTCDATE()),
    (33, '122022', 'DLF Phase 5', 25, 1, GETUTCDATE()),
    
    -- Gurugram - Others
    (34, '122018', 'Sohna Road', 26, 1, GETUTCDATE()),
    (35, '122007', 'Golf Course Road', 27, 1, GETUTCDATE()),
    (36, '122001', 'MG Road', 28, 1, GETUTCDATE()),
    (37, '122016', 'Udyog Vihar', 29, 1, GETUTCDATE()),
    (38, '122001', 'Sector 14', 30, 1, GETUTCDATE()),
    
    -- Gurgaon (alternate spelling)
    (39, '122002', 'Cyber City', 31, 1, GETUTCDATE()),
    (40, '122001', 'DLF Phase 1', 32, 1, GETUTCDATE()),
    (41, '122002', 'DLF Phase 2', 33, 1, GETUTCDATE()),
    (42, '122003', 'DLF Phase 3', 34, 1, GETUTCDATE()),
    (43, '122018', 'Sohna Road', 35, 1, GETUTCDATE()),
    (44, '122007', 'Golf Course Road', 36, 1, GETUTCDATE()),
    (45, '122001', 'MG Road', 37, 1, GETUTCDATE());
SET IDENTITY_INSERT [dbo].[Pincodes] OFF;
GO

-- =============================================
-- 7. CREATE HIERARCHICAL DATA FETCH PROCEDURES
-- =============================================

-- Get all States
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetAllStates]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetAllStates];
GO

CREATE PROCEDURE [dbo].[sp_GetAllStates]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        StateId AS id,
        StateName AS name,
        StateCode AS code
    FROM [dbo].[States]
    WHERE IsActive = 1
    ORDER BY StateName;
END
GO

-- Get Cities by State
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetCitiesByState]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetCitiesByState];
GO

CREATE PROCEDURE [dbo].[sp_GetCitiesByState]
    @StateId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        CityId AS id,
        CityName AS name,
        StateId AS stateId
    FROM [dbo].[Cities]
    WHERE StateId = @StateId AND IsActive = 1
    ORDER BY CityName;
END
GO

-- Get Localities by City
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetLocalitiesByCity]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetLocalitiesByCity];
GO

CREATE PROCEDURE [dbo].[sp_GetLocalitiesByCity]
    @CityId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        AreaId AS id,
        AreaName AS name,
        CityId AS cityId
    FROM [dbo].[Areas]
    WHERE CityId = @CityId AND IsActive = 1
    ORDER BY AreaName;
END
GO

-- Get Pincodes by Locality
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetPincodesByLocality]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetPincodesByLocality];
GO

CREATE PROCEDURE [dbo].[sp_GetPincodesByLocality]
    @AreaId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        PincodeId AS id,
        Pincode AS value,
        LocalityName AS localityName,
        AreaId AS areaId
    FROM [dbo].[Pincodes]
    WHERE AreaId = @AreaId AND IsActive = 1
    ORDER BY Pincode;
END
GO

-- Get complete hierarchical location data
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetHierarchicalLocation]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetHierarchicalLocation];
GO

CREATE PROCEDURE [dbo].[sp_GetHierarchicalLocation]
    @PincodeId INT = NULL,
    @AreaId INT = NULL,
    @CityId INT = NULL,
    @StateId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        s.StateId,
        s.StateName,
        s.StateCode,
        c.CityId,
        c.CityName,
        a.AreaId,
        a.AreaName AS LocalityName,
        p.PincodeId,
        p.Pincode,
        p.LocalityName AS PincodeLocalityName
    FROM [dbo].[States] s
    LEFT JOIN [dbo].[Cities] c ON s.StateId = c.StateId
    LEFT JOIN [dbo].[Areas] a ON c.CityId = a.CityId
    LEFT JOIN [dbo].[Pincodes] p ON a.AreaId = p.AreaId
    WHERE 
        (@StateId IS NULL OR s.StateId = @StateId)
        AND (@CityId IS NULL OR c.CityId = @CityId)
        AND (@AreaId IS NULL OR a.AreaId = @AreaId)
        AND (@PincodeId IS NULL OR p.PincodeId = @PincodeId)
        AND s.IsActive = 1
        AND (c.CityId IS NULL OR c.IsActive = 1)
        AND (a.AreaId IS NULL OR a.IsActive = 1)
        AND (p.PincodeId IS NULL OR p.IsActive = 1)
    ORDER BY s.StateName, c.CityName, a.AreaName, p.Pincode;
END
GO

PRINT 'Delhi NCR Location Schema created successfully!';
PRINT 'Summary:';
PRINT '- States: 2 (Delhi, Haryana)';
PRINT '- Cities: 5 (Delhi, New Delhi, Delhi NCR, Gurugram, Gurgaon)';
PRINT '- Localities: 37';
PRINT '- Pincodes: 45';
GO
