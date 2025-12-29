USE marketing_db;
GO

-- =============================================
-- HIERARCHICAL LOCATION SYSTEM IMPLEMENTATION
-- This script creates a comprehensive hierarchical location system
-- State → Area → Pincode structure for all India locations
-- =============================================

PRINT '=============================================';
PRINT 'IMPLEMENTING HIERARCHICAL LOCATION SYSTEM';
PRINT '=============================================';

-- 1. Create States table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'States')
BEGIN
    CREATE TABLE States (
        StateId INT PRIMARY KEY IDENTITY(1,1),
        StateName NVARCHAR(100) NOT NULL UNIQUE,
        StateCode NVARCHAR(10) NOT NULL UNIQUE,
        IsActive BIT DEFAULT 1,
        CreatedAt DATETIME DEFAULT GETDATE()
    );
    PRINT 'States table created successfully!';
END
ELSE
BEGIN
    PRINT 'States table already exists.';
END

-- 2. Create Areas table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Areas')
BEGIN
    CREATE TABLE Areas (
        AreaId INT PRIMARY KEY IDENTITY(1,1),
        AreaName NVARCHAR(100) NOT NULL,
        StateId INT NOT NULL,
        IsActive BIT DEFAULT 1,
        CreatedAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (StateId) REFERENCES States(StateId),
        UNIQUE(AreaName, StateId)
    );
    PRINT 'Areas table created successfully!';
END
ELSE
BEGIN
    PRINT 'Areas table already exists.';
END

-- 3. Create Pincodes table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Pincodes')
BEGIN
    CREATE TABLE Pincodes (
        PincodeId INT PRIMARY KEY IDENTITY(1,1),
        Pincode NVARCHAR(10) NOT NULL,
        AreaId INT NOT NULL,
        LocalityName NVARCHAR(200) NULL,
        IsActive BIT DEFAULT 1,
        CreatedAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (AreaId) REFERENCES Areas(AreaId),
        UNIQUE(Pincode, AreaId)
    );
    PRINT 'Pincodes table created successfully!';
END
ELSE
BEGIN
    PRINT 'Pincodes table already exists.';
END

-- 4. Update Locations table to support hierarchical structure
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Locations' AND COLUMN_NAME = 'StateId')
BEGIN
    ALTER TABLE Locations ADD StateId INT NULL;
    ALTER TABLE Locations ADD AreaId INT NULL;
    ALTER TABLE Locations ADD PincodeId INT NULL;
    ALTER TABLE Locations ADD CONSTRAINT FK_Locations_States FOREIGN KEY (StateId) REFERENCES States(StateId);
    ALTER TABLE Locations ADD CONSTRAINT FK_Locations_Areas FOREIGN KEY (AreaId) REFERENCES Areas(AreaId);
    ALTER TABLE Locations ADD CONSTRAINT FK_Locations_Pincodes FOREIGN KEY (PincodeId) REFERENCES Pincodes(PincodeId);
    PRINT 'Hierarchical columns added to Locations table!';
END
ELSE
BEGIN
    PRINT 'Hierarchical columns already exist in Locations table.';
END

-- 5. Insert Indian States data
IF NOT EXISTS (SELECT * FROM States WHERE StateName = 'Delhi')
BEGIN
    INSERT INTO States (StateName, StateCode) VALUES
    ('Andhra Pradesh', 'AP'),
    ('Arunachal Pradesh', 'AR'),
    ('Assam', 'AS'),
    ('Bihar', 'BR'),
    ('Chhattisgarh', 'CG'),
    ('Goa', 'GA'),
    ('Gujarat', 'GJ'),
    ('Haryana', 'HR'),
    ('Himachal Pradesh', 'HP'),
    ('Jharkhand', 'JH'),
    ('Karnataka', 'KA'),
    ('Kerala', 'KL'),
    ('Madhya Pradesh', 'MP'),
    ('Maharashtra', 'MH'),
    ('Manipur', 'MN'),
    ('Meghalaya', 'ML'),
    ('Mizoram', 'MZ'),
    ('Nagaland', 'NL'),
    ('Odisha', 'OR'),
    ('Punjab', 'PB'),
    ('Rajasthan', 'RJ'),
    ('Sikkim', 'SK'),
    ('Tamil Nadu', 'TN'),
    ('Telangana', 'TG'),
    ('Tripura', 'TR'),
    ('Uttar Pradesh', 'UP'),
    ('Uttarakhand', 'UK'),
    ('West Bengal', 'WB'),
    ('Delhi', 'DL'),
    ('Jammu and Kashmir', 'JK'),
    ('Ladakh', 'LA'),
    ('Chandigarh', 'CH'),
    ('Dadra and Nagar Haveli and Daman and Diu', 'DN'),
    ('Lakshadweep', 'LD'),
    ('Puducherry', 'PY'),
    ('Andaman and Nicobar Islands', 'AN');
    
    PRINT 'Indian States data inserted successfully!';
END
ELSE
BEGIN
    PRINT 'States data already exists.';
END

-- 6. Insert Delhi Areas (as default selection)
DECLARE @DelhiStateId INT = (SELECT StateId FROM States WHERE StateName = 'Delhi');

IF @DelhiStateId IS NOT NULL AND NOT EXISTS (SELECT * FROM Areas WHERE StateId = @DelhiStateId)
BEGIN
    INSERT INTO Areas (AreaName, StateId) VALUES
    ('Central Delhi', @DelhiStateId),
    ('North Delhi', @DelhiStateId),
    ('South Delhi', @DelhiStateId),
    ('East Delhi', @DelhiStateId),
    ('West Delhi', @DelhiStateId),
    ('North East Delhi', @DelhiStateId),
    ('North West Delhi', @DelhiStateId),
    ('South East Delhi', @DelhiStateId),
    ('South West Delhi', @DelhiStateId),
    ('New Delhi', @DelhiStateId),
    ('Shahdara', @DelhiStateId);
    
    PRINT 'Delhi Areas inserted successfully!';
END

-- 7. Insert sample areas for major states
DECLARE @MaharashtraStateId INT = (SELECT StateId FROM States WHERE StateName = 'Maharashtra');
DECLARE @KarnatakaStateId INT = (SELECT StateId FROM States WHERE StateName = 'Karnataka');
DECLARE @UPStateId INT = (SELECT StateId FROM States WHERE StateName = 'Uttar Pradesh');

-- Maharashtra Areas
IF @MaharashtraStateId IS NOT NULL AND NOT EXISTS (SELECT * FROM Areas WHERE StateId = @MaharashtraStateId)
BEGIN
    INSERT INTO Areas (AreaName, StateId) VALUES
    ('Mumbai City', @MaharashtraStateId),
    ('Mumbai Suburban', @MaharashtraStateId),
    ('Pune', @MaharashtraStateId),
    ('Nagpur', @MaharashtraStateId),
    ('Thane', @MaharashtraStateId),
    ('Nashik', @MaharashtraStateId),
    ('Aurangabad', @MaharashtraStateId),
    ('Solapur', @MaharashtraStateId),
    ('Kolhapur', @MaharashtraStateId),
    ('Sangli', @MaharashtraStateId);
    
    PRINT 'Maharashtra Areas inserted successfully!';
END

-- Karnataka Areas
IF @KarnatakaStateId IS NOT NULL AND NOT EXISTS (SELECT * FROM Areas WHERE StateId = @KarnatakaStateId)
BEGIN
    INSERT INTO Areas (AreaName, StateId) VALUES
    ('Bangalore Urban', @KarnatakaStateId),
    ('Bangalore Rural', @KarnatakaStateId),
    ('Mysore', @KarnatakaStateId),
    ('Hubli-Dharwad', @KarnatakaStateId),
    ('Mangalore', @KarnatakaStateId),
    ('Belgaum', @KarnatakaStateId),
    ('Gulbarga', @KarnatakaStateId),
    ('Davangere', @KarnatakaStateId),
    ('Bellary', @KarnatakaStateId),
    ('Bijapur', @KarnatakaStateId);
    
    PRINT 'Karnataka Areas inserted successfully!';
END

-- Uttar Pradesh Areas
IF @UPStateId IS NOT NULL AND NOT EXISTS (SELECT * FROM Areas WHERE StateId = @UPStateId)
BEGIN
    INSERT INTO Areas (AreaName, StateId) VALUES
    ('Lucknow', @UPStateId),
    ('Kanpur', @UPStateId),
    ('Ghaziabad', @UPStateId),
    ('Agra', @UPStateId),
    ('Meerut', @UPStateId),
    ('Varanasi', @UPStateId),
    ('Allahabad', @UPStateId),
    ('Bareilly', @UPStateId),
    ('Aligarh', @UPStateId),
    ('Moradabad', @UPStateId);
    
    PRINT 'Uttar Pradesh Areas inserted successfully!';
END

-- 8. Insert sample pincodes for Delhi areas
DECLARE @CentralDelhiAreaId INT = (SELECT AreaId FROM Areas WHERE AreaName = 'Central Delhi' AND StateId = @DelhiStateId);
DECLARE @SouthDelhiAreaId INT = (SELECT AreaId FROM Areas WHERE AreaName = 'South Delhi' AND StateId = @DelhiStateId);
DECLARE @NewDelhiAreaId INT = (SELECT AreaId FROM Areas WHERE AreaName = 'New Delhi' AND StateId = @DelhiStateId);

-- Central Delhi Pincodes
IF @CentralDelhiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @CentralDelhiAreaId)
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName) VALUES
    ('110001', @CentralDelhiAreaId, 'Connaught Place'),
    ('110002', @CentralDelhiAreaId, 'Darya Ganj'),
    ('110003', @CentralDelhiAreaId, 'Kashmere Gate'),
    ('110006', @CentralDelhiAreaId, 'Red Fort'),
    ('110055', @CentralDelhiAreaId, 'Civil Lines');
    
    PRINT 'Central Delhi Pincodes inserted successfully!';
END

-- South Delhi Pincodes
IF @SouthDelhiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @SouthDelhiAreaId)
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName) VALUES
    ('110016', @SouthDelhiAreaId, 'Lajpat Nagar'),
    ('110017', @SouthDelhiAreaId, 'Defence Colony'),
    ('110019', @SouthDelhiAreaId, 'Greater Kailash'),
    ('110024', @SouthDelhiAreaId, 'Hauz Khas'),
    ('110025', @SouthDelhiAreaId, 'Karol Bagh'),
    ('110048', @SouthDelhiAreaId, 'Saket'),
    ('110049', @SouthDelhiAreaId, 'Nehru Place'),
    ('110062', @SouthDelhiAreaId, 'Vasant Vihar');
    
    PRINT 'South Delhi Pincodes inserted successfully!';
END

-- New Delhi Pincodes
IF @NewDelhiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @NewDelhiAreaId)
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName) VALUES
    ('110001', @NewDelhiAreaId, 'Parliament Street'),
    ('110011', @NewDelhiAreaId, 'India Gate'),
    ('110021', @NewDelhiAreaId, 'Rajpath'),
    ('110023', @NewDelhiAreaId, 'Lodhi Road');
    
    PRINT 'New Delhi Pincodes inserted successfully!';
END

-- 9. Create TaskReschedule table for rescheduling functionality
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TaskReschedule')
BEGIN
    CREATE TABLE TaskReschedule (
        RescheduleId INT PRIMARY KEY IDENTITY(1,1),
        TaskId INT NOT NULL,
        OriginalTaskDate DATETIME NOT NULL,
        OriginalDeadline DATETIME NOT NULL,
        NewTaskDate DATETIME NOT NULL,
        NewDeadline DATETIME NOT NULL,
        RescheduleReason NVARCHAR(500) NULL,
        RescheduledByUserId INT NOT NULL,
        RescheduledAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (TaskId) REFERENCES Tasks(TaskId),
        FOREIGN KEY (RescheduledByUserId) REFERENCES Users(UserId)
    );
    PRINT 'TaskReschedule table created successfully!';
END
ELSE
BEGIN
    PRINT 'TaskReschedule table already exists.';
END

-- 10. Create indexes for better performance
CREATE NONCLUSTERED INDEX IX_Areas_StateId ON Areas(StateId);
CREATE NONCLUSTERED INDEX IX_Pincodes_AreaId ON Pincodes(AreaId);
CREATE NONCLUSTERED INDEX IX_Locations_StateId ON Locations(StateId);
CREATE NONCLUSTERED INDEX IX_Locations_AreaId ON Locations(AreaId);
CREATE NONCLUSTERED INDEX IX_Locations_PincodeId ON Locations(PincodeId);
CREATE NONCLUSTERED INDEX IX_TaskReschedule_TaskId ON TaskReschedule(TaskId);

PRINT 'Performance indexes created!';

-- 11. Create view for hierarchical location data
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_HierarchicalLocations')
BEGIN
    DROP VIEW vw_HierarchicalLocations;
END
GO

CREATE VIEW vw_HierarchicalLocations AS
SELECT 
    l.LocationId,
    l.LocationName,
    s.StateId,
    s.StateName,
    s.StateCode,
    a.AreaId,
    a.AreaName,
    p.PincodeId,
    p.Pincode,
    p.LocalityName,
    l.IsActive,
    l.CreatedAt
FROM Locations l
LEFT JOIN States s ON l.StateId = s.StateId
LEFT JOIN Areas a ON l.AreaId = a.AreaId
LEFT JOIN Pincodes p ON l.PincodeId = p.PincodeId
WHERE l.IsActive = 1;
GO

PRINT 'Hierarchical locations view created!';

-- 12. Verify the new structure
PRINT 'Verifying hierarchical location structure:';

SELECT 'States Count' as Info, COUNT(*) as Count FROM States;
SELECT 'Areas Count' as Info, COUNT(*) as Count FROM Areas;
SELECT 'Pincodes Count' as Info, COUNT(*) as Count FROM Pincodes;

SELECT TOP 5 
    s.StateName,
    a.AreaName,
    p.Pincode,
    p.LocalityName
FROM States s
INNER JOIN Areas a ON s.StateId = a.StateId
INNER JOIN Pincodes p ON a.AreaId = p.AreaId
ORDER BY s.StateName, a.AreaName, p.Pincode;

PRINT '=============================================';
PRINT 'HIERARCHICAL LOCATION SYSTEM IMPLEMENTED!';
PRINT '=============================================';