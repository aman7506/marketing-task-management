USE marketing_db;
GO

-- =============================================
-- ADD SAMPLE LOCATIONS FOR TESTING
-- This script adds sample locations for the tasks
-- =============================================

PRINT '=============================================';
PRINT 'ADDING SAMPLE LOCATIONS FOR TESTING';
PRINT '=============================================';

-- Insert sample locations
INSERT INTO Locations (LocationName, State, CreatedAt, IsActive) VALUES
('Connaught Place', 'Delhi', GETDATE(), 1),
('Khan Market', 'Delhi', GETDATE(), 1),
('Dwarka', 'Delhi', GETDATE(), 1),
('Janakpuri', 'Delhi', GETDATE(), 1),
('Sector 29', 'Delhi', GETDATE(), 1),
('Lajpat Nagar', 'Delhi', GETDATE(), 1),
('Karol Bagh', 'Delhi', GETDATE(), 1),
('Rajouri Garden', 'Delhi', GETDATE(), 1),
('Malviya Nagar', 'Delhi', GETDATE(), 1),
('Vasant Kunj', 'Delhi', GETDATE(), 1),
('Greater Kailash', 'Delhi', GETDATE(), 1),
('Defence Colony', 'Delhi', GETDATE(), 1),
('Saket', 'Delhi', GETDATE(), 1),
('Nehru Place', 'Delhi', GETDATE(), 1),
('Green Park', 'Delhi', GETDATE(), 1);

PRINT 'Sample locations inserted successfully!';

-- Verify the inserted data
PRINT 'Verifying inserted location data:';
SELECT
    LocationId,
    LocationName,
    State,
    IsActive
FROM Locations
WHERE LocationId > (SELECT MAX(LocationId) - 15 FROM Locations)
ORDER BY LocationId;

PRINT '=============================================';
PRINT 'TOTAL LOCATIONS:';
SELECT COUNT(*) as TotalLocations FROM Locations;
PRINT '=============================================';
PRINT 'SAMPLE LOCATIONS ADDED SUCCESSFULLY!';
PRINT '=============================================';
