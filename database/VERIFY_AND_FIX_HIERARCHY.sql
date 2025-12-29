-- =============================================
-- LOCATION HIERARCHY VERIFICATION & FIX
-- Execute this in SSMS to diagnose and fix all issues
-- =============================================

USE [marketing_db];
GO

PRINT '========================================';
PRINT ' STEP 1: CURRENT STATE VERIFICATION';
PRINT '========================================';
PRINT '';

-- Check States
PRINT '--- STATES ---';
SELECT StateId, StateName, StateCode, IsActive FROM States;
PRINT '';

-- Check Cities with State mapping
PRINT '--- CITIES (with State mapping) ---';
SELECT 
    c.CityId,
    c.CityName,
    c.StateId,
    s.StateName AS BelongsTo,
    c.IsActive
FROM Cities c
LEFT JOIN States s ON c.StateId = s.StateId
ORDER BY c.StateId, c.CityName;
PRINT '';

-- Check for orphaned cities
PRINT '--- ORPHANED CITIES (StateId = NULL) ---';
SELECT CityId, CityName,  'NEEDS FIX!' AS Status
FROM Cities 
WHERE StateId IS NULL;
PRINT '';

-- Check Areas/Localities with City mapping
PRINT '--- LOCALITIES (first 20) ---';
SELECT TOP 20
    a.AreaId,
    a.AreaName,
    a.CityId,
    c.CityName AS BelongsTo,
    a.IsActive
FROM Areas a
LEFT JOIN Cities c ON a.CityId = c.CityId
ORDER BY a.CityId, a.AreaName;
PRINT '';

-- Check for orphaned localities
PRINT '--- ORPHANED LOCALITIES (CityId = NULL) ---';
SELECT AreaId, AreaName, 'NEEDS FIX!' AS Status
FROM Areas 
WHERE CityId IS NULL;
PRINT '';

PRINT '========================================';
PRINT ' STEP 2: ENSURE REQUIRED DATA EXISTS';
PRINT '========================================';
PRINT '';

-- Ensure States exist
IF NOT EXISTS (SELECT * FROM States WHERE StateName = 'Delhi')
BEGIN
    INSERT INTO States (StateName, StateCode, IsActive, CreatedAt)
    VALUES ('Delhi', 'DL', 1, GETUTCDATE());
    PRINT '✓ Inserted Delhi state';
END
ELSE
    PRINT '✓ Delhi state already exists';

IF NOT EXISTS (SELECT * FROM States WHERE StateName = 'Haryana')
BEGIN
    INSERT INTO States (StateName, StateCode, IsActive, CreatedAt)
    VALUES ('Haryana', 'HR', 1, GETUTCDATE());
    PRINT '✓ Inserted Haryana state';
END
ELSE
    PRINT '✓ Haryana state already exists';

PRINT '';

-- Get State IDs
DECLARE @DelhiId INT = (SELECT StateId FROM States WHERE StateName = 'Delhi');
DECLARE @HaryanaId INT = (SELECT StateId FROM States WHERE StateName = 'Haryana');

PRINT 'State IDs: Delhi = ' + CAST(@DelhiId AS VARCHAR(10)) + ', Haryana = ' + CAST(@HaryanaId AS VARCHAR(10));
PRINT '';

-- Ensure Delhi cities exist
IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'Delhi')
BEGIN
    INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt)
    VALUES ('Delhi', @DelhiId, 1, GETUTCDATE());
    PRINT '✓ Inserted Delhi city';
END
ELSE
BEGIN
    UPDATE Cities SET StateId = @DelhiId WHERE CityName = 'Delhi' AND (StateId IS NULL OR StateId != @DelhiId);
    PRINT '✓ Delhi city exists (updated StateId if needed)';
END

IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'New Delhi')
BEGIN
    INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt)
    VALUES ('New Delhi', @DelhiId, 1, GETUTCDATE());
    PRINT '✓ Inserted New Delhi city';
END
ELSE
BEGIN
    UPDATE Cities SET StateId = @DelhiId WHERE CityName = 'New Delhi' AND (StateId IS NULL OR StateId != @DelhiId);
    PRINT '✓ New Delhi city exists (updated StateId if needed)';
END

IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'Delhi NCR')
BEGIN
    INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt)
    VALUES ('Delhi NCR', @DelhiId, 1, GETUTCDATE());
    PRINT '✓ Inserted Delhi NCR city';
END
ELSE
BEGIN
    UPDATE Cities SET StateId = @DelhiId WHERE CityName = 'Delhi NCR' AND (StateId IS NULL OR StateId != @DelhiId);
    PRINT '✓ Delhi NCR city exists (updated StateId if needed)';
END

-- Ensure Haryana cities exist  
IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'Gurugram')
BEGIN
    INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt)
    VALUES ('Gurugram', @HaryanaId, 1, GETUTCDATE());
    PRINT '✓ Inserted Gurugram city';
END
ELSE
BEGIN
    UPDATE Cities SET StateId = @HaryanaId WHERE CityName = 'Gurugram' AND (StateId IS NULL OR StateId != @HaryanaId);
    PRINT '✓ Gurugram city exists (updated StateId if needed)';
END

IF NOT EXISTS (SELECT * FROM Cities WHERE CityName = 'Gurgaon')
BEGIN
    INSERT INTO Cities (CityName, StateId, IsActive, CreatedAt)
    VALUES ('Gurgaon', @HaryanaId, 1, GETUTCDATE());
    PRINT '✓ Inserted Gurgaon city';
END
ELSE
BEGIN
    UPDATE Cities SET StateId = @HaryanaId WHERE CityName = 'Gurgaon' AND (StateId IS NULL OR StateId != @HaryanaId);
    PRINT '✓ Gurgaon city exists (updated StateId if needed)';
END

PRINT '';

PRINT '========================================';
PRINT ' STEP 3: VERIFICATION AFTER FIX';
PRINT '========================================';
PRINT '';

-- Final state check
SELECT 
    s.StateName,
    COUNT(DISTINCT c.CityId) AS CityCount,
    STRING_AGG(c.CityName, ', ') WITHIN GROUP (ORDER BY c.CityName) AS Cities
FROM States s
LEFT JOIN Cities c ON s.StateId = c.StateId AND c.IsActive = 1
WHERE s.IsActive = 1
GROUP BY s.StateName;

PRINT '';
PRINT '========================================';
PRINT ' ✅ FIX COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'Expected Results:';
PRINT '  Delhi    → 3 cities: Delhi, Delhi NCR, New Delhi';
PRINT '  Haryana  → 2 cities: Gurgaon, Gurugram';
PRINT '';
PRINT 'Next: Test APIs and frontend dropdowns!';
PRINT '';

GO
