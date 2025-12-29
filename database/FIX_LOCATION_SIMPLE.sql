-- =============================================
-- COMPLETE DELHI NCR LOCATION FIX
-- Run this ENTIRE script in SSMS
-- =============================================

USE [marketing_db];
GO

PRINT '========================================';
PRINT ' STEP 1: Verify Current Data';
PRINT '========================================';

-- Show current states
SELECT StateId, StateName FROM States WHERE IsActive = 1;

-- Show current cities
SELECT CityId, CityName, StateId FROM Cities WHERE IsActive = 1;

PRINT '';
PRINT '========================================';
PRINT ' STEP 2: Ensure States Exist';
PRINT '========================================';

-- Ensure Delhi state exists
IF NOT EXISTS (SELECT * FROM States WHERE StateName = 'Delhi')
BEGIN
    INSERT INTO States (StateName, StateCode, IsActive, CreatedAt)
    VALUES ('Delhi', 'DL', 1, GETUTCDATE());
    PRINT '✓ Inserted Delhi state';
END
ELSE
    PRINT '✓ Delhi state exists';

-- Ensure Haryana state exists
IF NOT EXISTS (SELECT * FROM States WHERE StateName = 'Haryana')
BEGIN
    INSERT INTO States (StateName, StateCode, IsActive, CreatedAt)
    VALUES ('Haryana', 'HR', 1, GETUTCDATE());
    PRINT '✓ Inserted Haryana state';
END
ELSE
    PRINT '✓ Haryana state exists';

-- Get state IDs
DECLARE @DelhiStateId INT = (SELECT StateId FROM States WHERE StateName = 'Delhi');
DECLARE @HaryanaStateId INT = (SELECT StateId FROM States WHERE StateName = 'Haryana');

PRINT 'Delhi StateId: ' + CAST(@DelhiStateId AS VARCHAR(10));
PRINT 'Haryana StateId: ' + CAST(@HaryanaStateId AS VARCHAR(10));

PRINT '';
PRINT '========================================';
PRINT ' STEP 3: Fix Cities';
PRINT '========================================';

-- Delhi cities
IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'Delhi' AND StateId = @DelhiStateId)
BEGIN
    IF EXISTS (SELECT * FROM Cities WHERE CityName = 'Delhi')
        UPDATE Cities SET StateId = @DelhiStateId WHERE CityName = 'Delhi';
    ELSE
        INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt) VALUES ('Delhi', @DelhiStateId, 1, GETUTCDATE());
    PRINT '✓ Delhi city fixed';
END

IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'New Delhi' AND StateId = @DelhiStateId)
BEGIN
    IF EXISTS (SELECT * FROM Cities WHERE CityName = 'New Delhi')
        UPDATE Cities SET StateId = @DelhiStateId WHERE CityName = 'New Delhi';
    ELSE
        INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt) VALUES ('New Delhi', @DelhiStateId, 1, GETUTCDATE());
    PRINT '✓ New Delhi city fixed';
END

IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'Delhi NCR' AND StateId = @DelhiStateId)
BEGIN
    IF EXISTS (SELECT * FROM Cities WHERE CityName = 'Delhi NCR')
        UPDATE Cities SET StateId = @DelhiStateId WHERE CityName = 'Delhi NCR';
    ELSE
        INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt) VALUES ('Delhi NCR', @DelhiStateId, 1, GETUTCDATE());
    PRINT '✓ Delhi NCR city fixed';
END

-- Haryana cities
IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'Gurugram' AND StateId = @HaryanaStateId)
BEGIN
    IF EXISTS (SELECT * FROM Cities WHERE CityName = 'Gurugram')
        UPDATE Cities SET StateId = @HaryanaStateId WHERE CityName = 'Gurugram';
    ELSE
        INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt) VALUES ('Gurugram', @HaryanaStateId, 1, GETUTCDATE());
    PRINT '✓ Gurugram city fixed';
END

IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'Gurgaon' AND StateId = @HaryanaStateId)
BEGIN
    IF EXISTS (SELECT * FROM Cities WHERE CityName = 'Gurgaon')
        UPDATE Cities SET StateId = @HaryanaStateId WHERE CityName = 'Gurgaon';
    ELSE
        INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt) VALUES ('Gurgaon', @HaryanaStateId, 1, GETUTCDATE());
    PRINT '✓ Gurgaon city fixed';
END

PRINT '';
PRINT '========================================';
PRINT ' FINAL RESULT';
PRINT '========================================';

-- Show final hierarchy
SELECT 
    s.StateName,
    c.CityName,
    COUNT(a.AreaId) AS LocalityCount
FROM States s
LEFT JOIN Cities c ON s.StateId = c.StateId AND c.IsActive = 1
LEFT JOIN Areas a ON c.CityId = a.CityId AND a.IsActive = 1
WHERE s.IsActive = 1
GROUP BY s.StateName, c.CityName
ORDER BY s.StateName, c.CityName;

PRINT '';
PRINT '✅ DATABASE READY!';
PRINT 'Next: Test APIs in browser';

GO
