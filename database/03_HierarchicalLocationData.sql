-- Hierarchical Location Data for India
-- This script populates States, Areas, and Pincodes for major Indian locations

USE marketing_db;
GO

-- Insert States
INSERT INTO States (StateName, StateCode, IsActive, CreatedAt) VALUES
('Delhi', 'DL', 1, GETDATE()),
('Maharashtra', 'MH', 1, GETDATE()),
('Karnataka', 'KA', 1, GETDATE()),
('Tamil Nadu', 'TN', 1, GETDATE()),
('Gujarat', 'GJ', 1, GETDATE()),
('Rajasthan', 'RJ', 1, GETDATE()),
('West Bengal', 'WB', 1, GETDATE()),
('Madhya Pradesh', 'MP', 1, GETDATE()),
('Uttar Pradesh', 'UP', 1, GETDATE()),
('Andhra Pradesh', 'AP', 1, GETDATE()),
('Telangana', 'TG', 1, GETDATE()),
('Bihar', 'BR', 1, GETDATE()),
('Odisha', 'OR', 1, GETDATE()),
('Assam', 'AS', 1, GETDATE()),
('Punjab', 'PB', 1, GETDATE()),
('Haryana', 'HR', 1, GETDATE()),
('Jharkhand', 'JH', 1, GETDATE()),
('Himachal Pradesh', 'HP', 1, GETDATE()),
('Uttarakhand', 'UK', 1, GETDATE()),
('Chhattisgarh', 'CG', 1, GETDATE()),
('Goa', 'GA', 1, GETDATE()),
('Kerala', 'KL', 1, GETDATE()),
('Manipur', 'MN', 1, GETDATE()),
('Meghalaya', 'ML', 1, GETDATE()),
('Mizoram', 'MZ', 1, GETDATE()),
('Nagaland', 'NL', 1, GETDATE()),
('Sikkim', 'SK', 1, GETDATE()),
('Tripura', 'TR', 1, GETDATE()),
('Arunachal Pradesh', 'AR', 1, GETDATE()),
('Jammu and Kashmir', 'JK', 1, GETDATE()),
('Ladakh', 'LA', 1, GETDATE()),
('Andaman and Nicobar Islands', 'AN', 1, GETDATE()),
('Chandigarh', 'CH', 1, GETDATE()),
('Dadra and Nagar Haveli and Daman and Diu', 'DN', 1, GETDATE()),
('Lakshadweep', 'LD', 1, GETDATE()),
('Puducherry', 'PY', 1, GETDATE());

-- Insert Areas for Delhi (StateId = 1)
INSERT INTO Areas (AreaName, StateId, IsActive, CreatedAt) VALUES
('Central Delhi', 1, 1, GETDATE()),
('North Delhi', 1, 1, GETDATE()),
('South Delhi', 1, 1, GETDATE()),
('East Delhi', 1, 1, GETDATE()),
('West Delhi', 1, 1, GETDATE()),
('New Delhi', 1, 1, GETDATE()),
('North East Delhi', 1, 1, GETDATE()),
('North West Delhi', 1, 1, GETDATE()),
('South East Delhi', 1, 1, GETDATE()),
('South West Delhi', 1, 1, GETDATE()),
('Shahdara', 1, 1, GETDATE());

-- Insert Areas for Maharashtra (StateId = 2)
INSERT INTO Areas (AreaName, StateId, IsActive, CreatedAt) VALUES
('Mumbai City', 2, 1, GETDATE()),
('Mumbai Suburban', 2, 1, GETDATE()),
('Pune', 2, 1, GETDATE()),
('Nagpur', 2, 1, GETDATE()),
('Thane', 2, 1, GETDATE()),
('Nashik', 2, 1, GETDATE()),
('Aurangabad', 2, 1, GETDATE()),
('Solapur', 2, 1, GETDATE()),
('Kolhapur', 2, 1, GETDATE()),
('Sangli', 2, 1, GETDATE());

-- Insert Areas for Karnataka (StateId = 3)
INSERT INTO Areas (AreaName, StateId, IsActive, CreatedAt) VALUES
('Bangalore Urban', 3, 1, GETDATE()),
('Mysore', 3, 1, GETDATE()),
('Hubli-Dharwad', 3, 1, GETDATE()),
('Mangalore', 3, 1, GETDATE()),
('Belgaum', 3, 1, GETDATE()),
('Gulbarga', 3, 1, GETDATE()),
('Davanagere', 3, 1, GETDATE()),
('Bellary', 3, 1, GETDATE()),
('Bijapur', 3, 1, GETDATE()),
('Shimoga', 3, 1, GETDATE());



-- Get StateIds dynamically
DECLARE @TamilNaduStateId INT = (SELECT StateId FROM States WHERE StateName = 'Tamil Nadu');
DECLARE @GujaratStateId INT = (SELECT StateId FROM States WHERE StateName = 'Gujarat');

-- Insert Areas for Gujarat
IF @GujaratStateId IS NOT NULL AND NOT EXISTS (SELECT * FROM Areas WHERE StateId = @GujaratStateId AND AreaName = 'Ahmedabad')
BEGIN
    INSERT INTO Areas (AreaName, StateId, IsActive, CreatedAt) VALUES
    ('Ahmedabad', @GujaratStateId, 1, GETDATE()),
    ('Surat', @GujaratStateId, 1, GETDATE()),
    ('Vadodara', @GujaratStateId, 1, GETDATE()),
    ('Rajkot', @GujaratStateId, 1, GETDATE()),
    ('Bhavnagar', @GujaratStateId, 1, GETDATE()),
    ('Jamnagar', @GujaratStateId, 1, GETDATE()),
    ('Junagadh', @GujaratStateId, 1, GETDATE()),
    ('Gandhinagar', @GujaratStateId, 1, GETDATE()),
    ('Anand', @GujaratStateId, 1, GETDATE()),
    ('Mehsana', @GujaratStateId, 1, GETDATE());
END

-- Insert Areas for Tamil Nadu
IF @TamilNaduStateId IS NOT NULL AND NOT EXISTS (SELECT * FROM Areas WHERE StateId = @TamilNaduStateId AND AreaName = 'Chennai')
BEGIN
    INSERT INTO Areas (AreaName, StateId, IsActive, CreatedAt) VALUES
    ('Chennai', @TamilNaduStateId, 1, GETDATE()),
    ('Coimbatore', @TamilNaduStateId, 1, GETDATE()),
    ('Madurai', @TamilNaduStateId, 1, GETDATE()),
    ('Tiruchirappalli', @TamilNaduStateId, 1, GETDATE()),
    ('Salem', @TamilNaduStateId, 1, GETDATE()),
    ('Tirunelveli', @TamilNaduStateId, 1, GETDATE()),
    ('Erode', @TamilNaduStateId, 1, GETDATE()),
    ('Vellore', @TamilNaduStateId, 1, GETDATE()),
    ('Thoothukudi', @TamilNaduStateId, 1, GETDATE()),
    ('Dindigul', @TamilNaduStateId, 1, GETDATE());
END

-- Insert Pincodes for Delhi Areas
-- Get AreaIds dynamically
DECLARE @CentralDelhiAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Delhi' AND a.AreaName = 'Central Delhi');
DECLARE @NewDelhiAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Delhi' AND a.AreaName = 'New Delhi');
DECLARE @SouthDelhiAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Delhi' AND a.AreaName = 'South Delhi');
DECLARE @NorthDelhiAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Delhi' AND a.AreaName = 'North Delhi');
DECLARE @WestDelhiAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Delhi' AND a.AreaName = 'West Delhi');
DECLARE @EastDelhiAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Delhi' AND a.AreaName = 'East Delhi');

-- Central Delhi Pincodes
IF @CentralDelhiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @CentralDelhiAreaId AND Pincode = '110001')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('110001', @CentralDelhiAreaId, 'Connaught Place', 1, GETDATE()),
    ('110002', @CentralDelhiAreaId, 'Darya Ganj', 1, GETDATE()),
    ('110003', @CentralDelhiAreaId, 'Kashmere Gate', 1, GETDATE()),
    ('110006', @CentralDelhiAreaId, 'Red Fort', 1, GETDATE()),
    ('110055', @CentralDelhiAreaId, 'India Gate', 1, GETDATE());
END

-- New Delhi Pincodes
IF @NewDelhiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @NewDelhiAreaId AND Pincode = '110011')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('110011', @NewDelhiAreaId, 'Central Secretariat', 1, GETDATE()),
    ('110021', @NewDelhiAreaId, 'President Estate', 1, GETDATE()),
    ('110023', @NewDelhiAreaId, 'Raj Ghat', 1, GETDATE()),
    ('110012', @NewDelhiAreaId, 'Parliament House', 1, GETDATE());
END

-- South Delhi Pincodes
IF @SouthDelhiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @SouthDelhiAreaId AND Pincode = '110016')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('110016', @SouthDelhiAreaId, 'Lajpat Nagar', 1, GETDATE()),
    ('110017', @SouthDelhiAreaId, 'Defence Colony', 1, GETDATE()),
    ('110019', @SouthDelhiAreaId, 'Greater Kailash', 1, GETDATE()),
    ('110024', @SouthDelhiAreaId, 'Green Park', 1, GETDATE()),
    ('110025', @SouthDelhiAreaId, 'Hauz Khas', 1, GETDATE()),
    ('110029', @SouthDelhiAreaId, 'Malviya Nagar', 1, GETDATE()),
    ('110048', @SouthDelhiAreaId, 'Saket', 1, GETDATE()),
    ('110049', @SouthDelhiAreaId, 'Nehru Place', 1, GETDATE()),
    ('110062', @SouthDelhiAreaId, 'Vasant Kunj', 1, GETDATE()),
    ('110070', @SouthDelhiAreaId, 'Vasant Vihar', 1, GETDATE());
END

-- North Delhi Pincodes
IF @NorthDelhiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @NorthDelhiAreaId AND Pincode = '110007')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('110007', @NorthDelhiAreaId, 'Civil Lines', 1, GETDATE()),
    ('110009', @NorthDelhiAreaId, 'Kamla Nagar', 1, GETDATE()),
    ('110033', @NorthDelhiAreaId, 'Kingsway Camp', 1, GETDATE()),
    ('110035', @NorthDelhiAreaId, 'Gtb Nagar', 1, GETDATE()),
    ('110054', @NorthDelhiAreaId, 'Model Town', 1, GETDATE());
END

-- West Delhi Pincodes
IF @WestDelhiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @WestDelhiAreaId AND Pincode = '110015')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('110015', @WestDelhiAreaId, 'Karol Bagh', 1, GETDATE()),
    ('110018', @WestDelhiAreaId, 'Rajouri Garden', 1, GETDATE()),
    ('110026', @WestDelhiAreaId, 'Naraina', 1, GETDATE()),
    ('110027', @WestDelhiAreaId, 'Patel Nagar', 1, GETDATE()),
    ('110058', @WestDelhiAreaId, 'Janakpuri', 1, GETDATE()),
    ('110059', @WestDelhiAreaId, 'Tilak Nagar', 1, GETDATE()),
    ('110063', @WestDelhiAreaId, 'Vikaspuri', 1, GETDATE());
END

-- East Delhi Pincodes
IF @EastDelhiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @EastDelhiAreaId AND Pincode = '110031')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('110031', @EastDelhiAreaId, 'Laxmi Nagar', 1, GETDATE()),
    ('110032', @EastDelhiAreaId, 'Preet Vihar', 1, GETDATE()),
    ('110051', @EastDelhiAreaId, 'I P Extension', 1, GETDATE()),
    ('110092', @EastDelhiAreaId, 'Mayur Vihar', 1, GETDATE()),
    ('110096', @EastDelhiAreaId, 'Patparganj', 1, GETDATE());
END

-- Get AreaIds for other cities dynamically
DECLARE @MumbaiCityAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Maharashtra' AND a.AreaName = 'Mumbai City');
DECLARE @BangaloreUrbanAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Karnataka' AND a.AreaName = 'Bangalore Urban');
DECLARE @ChennaiAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Tamil Nadu' AND a.AreaName = 'Chennai');
DECLARE @AhmedabadAreaId INT = (SELECT AreaId FROM Areas a INNER JOIN States s ON a.StateId = s.StateId WHERE s.StateName = 'Gujarat' AND a.AreaName = 'Ahmedabad');

-- Insert Pincodes for Mumbai City
IF @MumbaiCityAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @MumbaiCityAreaId AND Pincode = '400001')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('400001', @MumbaiCityAreaId, 'Fort', 1, GETDATE()),
    ('400002', @MumbaiCityAreaId, 'Kalbadevi', 1, GETDATE()),
    ('400003', @MumbaiCityAreaId, 'Masjid Bunder', 1, GETDATE()),
    ('400004', @MumbaiCityAreaId, 'Girgaon', 1, GETDATE()),
    ('400005', @MumbaiCityAreaId, 'Colaba', 1, GETDATE()),
    ('400006', @MumbaiCityAreaId, 'Malabar Hill', 1, GETDATE()),
    ('400007', @MumbaiCityAreaId, 'Grant Road', 1, GETDATE()),
    ('400008', @MumbaiCityAreaId, 'Mumbai Central', 1, GETDATE()),
    ('400009', @MumbaiCityAreaId, 'Mazgaon', 1, GETDATE()),
    ('400010', @MumbaiCityAreaId, 'Tardeo', 1, GETDATE()),
    ('400011', @MumbaiCityAreaId, 'Jacob Circle', 1, GETDATE()),
    ('400012', @MumbaiCityAreaId, 'Lalbaug', 1, GETDATE()),
    ('400013', @MumbaiCityAreaId, 'Dadar East', 1, GETDATE()),
    ('400014', @MumbaiCityAreaId, 'Dadar West', 1, GETDATE()),
    ('400016', @MumbaiCityAreaId, 'Mahim', 1, GETDATE()),
    ('400018', @MumbaiCityAreaId, 'Worli', 1, GETDATE()),
    ('400020', @MumbaiCityAreaId, 'Churchgate', 1, GETDATE()),
    ('400021', @MumbaiCityAreaId, 'Nariman Point', 1, GETDATE()),
    ('400025', @MumbaiCityAreaId, 'Prabhadevi', 1, GETDATE()),
    ('400026', @MumbaiCityAreaId, 'Cumballa Hill', 1, GETDATE());
END

-- Insert Pincodes for Bangalore Urban
IF @BangaloreUrbanAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @BangaloreUrbanAreaId AND Pincode = '560001')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('560001', @BangaloreUrbanAreaId, 'Bangalore City', 1, GETDATE()),
    ('560002', @BangaloreUrbanAreaId, 'Bangalore Cantonment', 1, GETDATE()),
    ('560003', @BangaloreUrbanAreaId, 'Malleshwaram', 1, GETDATE()),
    ('560004', @BangaloreUrbanAreaId, 'Rajajinagar', 1, GETDATE()),
    ('560005', @BangaloreUrbanAreaId, 'Seshadripuram', 1, GETDATE()),
    ('560006', @BangaloreUrbanAreaId, 'Chamrajpet', 1, GETDATE()),
    ('560007', @BangaloreUrbanAreaId, 'Chamarajpet', 1, GETDATE()),
    ('560008', @BangaloreUrbanAreaId, 'Chickpet', 1, GETDATE()),
    ('560009', @BangaloreUrbanAreaId, 'Balepet', 1, GETDATE()),
    ('560010', @BangaloreUrbanAreaId, 'Vyalikaval', 1, GETDATE()),
    ('560011', @BangaloreUrbanAreaId, 'Shivajinagar', 1, GETDATE()),
    ('560012', @BangaloreUrbanAreaId, 'Malleswaram', 1, GETDATE()),
    ('560013', @BangaloreUrbanAreaId, 'Sadashivanagar', 1, GETDATE()),
    ('560016', @BangaloreUrbanAreaId, 'Sanjaynagar', 1, GETDATE()),
    ('560017', @BangaloreUrbanAreaId, 'Rajajinagar', 1, GETDATE()),
    ('560018', @BangaloreUrbanAreaId, 'Vijayanagar', 1, GETDATE()),
    ('560019', @BangaloreUrbanAreaId, 'Nagarbhavi', 1, GETDATE()),
    ('560020', @BangaloreUrbanAreaId, 'Rajajinagar', 1, GETDATE()),
    ('560021', @BangaloreUrbanAreaId, 'Yeshwantpur', 1, GETDATE()),
    ('560022', @BangaloreUrbanAreaId, 'Mathikere', 1, GETDATE());
END

-- Insert Pincodes for Chennai
IF @ChennaiAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @ChennaiAreaId AND Pincode = '600001')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('600001', @ChennaiAreaId, 'Parrys Corner', 1, GETDATE()),
    ('600002', @ChennaiAreaId, 'Sowcarpet', 1, GETDATE()),
    ('600003', @ChennaiAreaId, 'Chintadripet', 1, GETDATE()),
    ('600004', @ChennaiAreaId, 'Mylapore', 1, GETDATE()),
    ('600005', @ChennaiAreaId, 'Triplicane', 1, GETDATE()),
    ('600006', @ChennaiAreaId, 'Chepauk', 1, GETDATE()),
    ('600007', @ChennaiAreaId, 'Vepery', 1, GETDATE()),
    ('600008', @ChennaiAreaId, 'Egmore', 1, GETDATE()),
    ('600009', @ChennaiAreaId, 'Purasawalkam', 1, GETDATE()),
    ('600010', @ChennaiAreaId, 'Kilpauk', 1, GETDATE()),
    ('600011', @ChennaiAreaId, 'Nungambakkam', 1, GETDATE()),
    ('600012', @ChennaiAreaId, 'Arumbakkam', 1, GETDATE()),
    ('600013', @ChennaiAreaId, 'T Nagar', 1, GETDATE()),
    ('600014', @ChennaiAreaId, 'Vadapalani', 1, GETDATE()),
    ('600015', @ChennaiAreaId, 'Kodambakkam', 1, GETDATE()),
    ('600016', @ChennaiAreaId, 'Saidapet', 1, GETDATE()),
    ('600017', @ChennaiAreaId, 'T Nagar', 1, GETDATE()),
    ('600018', @ChennaiAreaId, 'Ashok Nagar', 1, GETDATE()),
    ('600020', @ChennaiAreaId, 'Anna Nagar', 1, GETDATE()),
    ('600024', @ChennaiAreaId, 'Besant Nagar', 1, GETDATE());
END

-- Insert Pincodes for Ahmedabad
IF @AhmedabadAreaId IS NOT NULL AND NOT EXISTS (SELECT * FROM Pincodes WHERE AreaId = @AhmedabadAreaId AND Pincode = '380001')
BEGIN
    INSERT INTO Pincodes (Pincode, AreaId, LocalityName, IsActive, CreatedAt) VALUES
    ('380001', @AhmedabadAreaId, 'Lal Darwaja', 1, GETDATE()),
    ('380002', @AhmedabadAreaId, 'Kalupur', 1, GETDATE()),
    ('380003', @AhmedabadAreaId, 'Maninagar', 1, GETDATE()),
    ('380004', @AhmedabadAreaId, 'Navrangpura', 1, GETDATE()),
    ('380005', @AhmedabadAreaId, 'Kankaria', 1, GETDATE()),
    ('380006', @AhmedabadAreaId, 'Narol', 1, GETDATE()),
    ('380007', @AhmedabadAreaId, 'Sabarmati', 1, GETDATE()),
    ('380008', @AhmedabadAreaId, 'Vastrapur', 1, GETDATE()),
    ('380009', @AhmedabadAreaId, 'Ghatlodia', 1, GETDATE()),
    ('380013', @AhmedabadAreaId, 'Ambawadi', 1, GETDATE()),
    ('380014', @AhmedabadAreaId, 'Paldi', 1, GETDATE()),
    ('380015', @AhmedabadAreaId, 'Satellite', 1, GETDATE()),
    ('380016', @AhmedabadAreaId, 'Bopal', 1, GETDATE()),
    ('380018', @AhmedabadAreaId, 'Thaltej', 1, GETDATE()),
    ('380019', @AhmedabadAreaId, 'Gota', 1, GETDATE()),
    ('380050', @AhmedabadAreaId, 'Prahlad Nagar', 1, GETDATE()),
    ('380051', @AhmedabadAreaId, 'Jodhpur', 1, GETDATE()),
    ('380052', @AhmedabadAreaId, 'Vejalpur', 1, GETDATE()),
    ('380054', @AhmedabadAreaId, 'Makarba', 1, GETDATE()),
    ('380055', @AhmedabadAreaId, 'Science City', 1, GETDATE());
END

-- Update existing Location table to link with hierarchical data
-- First, let's add the hierarchical fields to existing locations if they don't exist
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Locations' AND COLUMN_NAME = 'StateId')
BEGIN
    ALTER TABLE Locations ADD StateId INT NULL;
    ALTER TABLE Locations ADD AreaId INT NULL;
    ALTER TABLE Locations ADD PincodeId INT NULL;
    
    -- Add foreign key constraints
    ALTER TABLE Locations ADD CONSTRAINT FK_Locations_States FOREIGN KEY (StateId) REFERENCES States(StateId);
    ALTER TABLE Locations ADD CONSTRAINT FK_Locations_Areas FOREIGN KEY (AreaId) REFERENCES Areas(AreaId);
    ALTER TABLE Locations ADD CONSTRAINT FK_Locations_Pincodes FOREIGN KEY (PincodeId) REFERENCES Pincodes(PincodeId);
END

-- Update existing locations with hierarchical data (example mappings)
UPDATE Locations SET StateId = 1, AreaId = 3, PincodeId = (SELECT TOP 1 PincodeId FROM Pincodes WHERE AreaId = 3) WHERE LocationName LIKE '%Delhi%' OR State = 'Delhi';
UPDATE Locations SET StateId = 2, AreaId = 12, PincodeId = (SELECT TOP 1 PincodeId FROM Pincodes WHERE AreaId = 12) WHERE LocationName LIKE '%Mumbai%' OR State = 'Maharashtra';
UPDATE Locations SET StateId = 3, AreaId = 22, PincodeId = (SELECT TOP 1 PincodeId FROM Pincodes WHERE AreaId = 22) WHERE LocationName LIKE '%Bangalore%' OR State = 'Karnataka';
UPDATE Locations SET StateId = 4, AreaId = 32, PincodeId = (SELECT TOP 1 PincodeId FROM Pincodes WHERE AreaId = 32) WHERE LocationName LIKE '%Chennai%' OR State = 'Tamil Nadu';
UPDATE Locations SET StateId = 5, AreaId = 42, PincodeId = (SELECT TOP 1 PincodeId FROM Pincodes WHERE AreaId = 42) WHERE LocationName LIKE '%Ahmedabad%' OR State = 'Gujarat';

PRINT 'Hierarchical location data inserted successfully!';
PRINT 'States: 36, Areas: 51, Pincodes: 100+ inserted';
PRINT 'Existing locations updated with hierarchical references';