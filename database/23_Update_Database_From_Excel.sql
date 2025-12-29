-- =============================================
-- UPDATE DATABASE FROM EXCEL DATA
-- This script will update the database with the data from the Excel file
-- =============================================

USE marketing_db;
GO

PRINT '=============================================';
PRINT 'UPDATING DATABASE FROM EXCEL DATA';
PRINT '=============================================';

-- 1. Update Employees table schema if needed
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Employees' AND COLUMN_NAME = 'Email' AND CHARACTER_MAXIMUM_LENGTH = 200)
BEGIN
    ALTER TABLE Employees ALTER COLUMN Email NVARCHAR(200) NULL;
    PRINT 'Updated Employees.Email column to NVARCHAR(200) NULL';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Employees' AND COLUMN_NAME = 'Contact' AND IS_NULLABLE = 'YES')
BEGIN
    ALTER TABLE Employees ALTER COLUMN Contact NVARCHAR(50) NULL;
    PRINT 'Updated Employees.Contact column to allow NULL';
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Employees' AND COLUMN_NAME = 'Designation' AND CHARACTER_MAXIMUM_LENGTH = 100)
BEGIN
    ALTER TABLE Employees ALTER COLUMN Designation NVARCHAR(100) NULL;
    PRINT 'Updated Employees.Designation column to NVARCHAR(100) NULL';
END

-- 2. Update Users table schema if needed
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'Username' AND CHARACTER_MAXIMUM_LENGTH = 100)
BEGIN
    ALTER TABLE Users ALTER COLUMN Username NVARCHAR(100) NOT NULL;
    PRINT 'Updated Users.Username column to NVARCHAR(100)';
END

-- 3. Update Locations table schema if needed
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Locations' AND COLUMN_NAME = 'LocationName' AND CHARACTER_MAXIMUM_LENGTH = 200)
BEGIN
    ALTER TABLE Locations ALTER COLUMN LocationName NVARCHAR(200) NOT NULL;
    PRINT 'Updated Locations.LocationName column to NVARCHAR(200)';
END

-- 4. Add missing columns to Tasks table if needed
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'TaskType')
BEGIN
    ALTER TABLE Tasks ADD 
        TaskType NVARCHAR(50) NULL DEFAULT 'General',
        Department NVARCHAR(100) NULL DEFAULT 'Marketing',
        ClientName NVARCHAR(200) NULL,
        ProjectCode NVARCHAR(100) NULL,
        EmployeeIdNumber NVARCHAR(50) NULL,
        EstimatedHours DECIMAL(5,2) NULL,
        ActualHours DECIMAL(5,2) NULL,
        TaskCategory NVARCHAR(50) NULL DEFAULT 'Field Work',
        AdditionalNotes NVARCHAR(1000) NULL,
        IsUrgent BIT NOT NULL DEFAULT 0;
    
    PRINT 'Added comprehensive task fields to Tasks table';
END

-- 5. Add hierarchical location fields to Tasks table if needed
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Tasks' AND COLUMN_NAME = 'StateId')
BEGIN
    ALTER TABLE Tasks ADD 
        StateId INT NULL,
        StateName NVARCHAR(100) NULL,
        AreaIds NVARCHAR(500) NULL,
        AreaNames NVARCHAR(1000) NULL,
        PincodeId INT NULL,
        PincodeValue NVARCHAR(10) NULL,
        LocalityName NVARCHAR(200) NULL;
    
    PRINT 'Added hierarchical location fields to Tasks table';
END

-- 6. Update or Insert Employees from Excel data
PRINT 'Updating Employees from Excel data...';

-- Check if Test Employee exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Test Employee')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Test Employee', '1234567890', 'Test Position', 'test@example.com', GETDATE(), 1);
    PRINT 'Inserted Test Employee';
END

-- Check if Rahul Sharma exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Rahul Sharma')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Rahul Sharma', '9876543215', 'Marketing Executive', 'rahul.sharma@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Rahul Sharma';
END

-- Check if Dr. Arjun Mehta exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Dr. Arjun Mehta')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Dr. Arjun Mehta', '9876543220', 'Chief Marketing Officer', 'arjun.mehta@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Dr. Arjun Mehta';
END

-- Check if Kavya Sharma exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Kavya Sharma')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Kavya Sharma', '9876543221', 'Marketing Director', 'kavya.sharma@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Kavya Sharma';
END

-- Check if Rohit Agarwal exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Rohit Agarwal')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Rohit Agarwal', '9876543222', 'Business Development Manager', 'rohit.agarwal@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Rohit Agarwal';
END

-- Check if Ananya Joshi exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Ananya Joshi')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Ananya Joshi', '9876543223', 'Digital Marketing Manager', 'ananya.joshi@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Ananya Joshi';
END

-- Check if Siddharth Rao exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Siddharth Rao')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Siddharth Rao', '9876543224', 'Content Marketing Specialist', 'siddharth.rao@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Siddharth Rao';
END

-- Check if Meera Nair exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Meera Nair')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Meera Nair', '9876543225', 'Social Media Manager', 'meera.nair@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Meera Nair';
END

-- Check if Karan Singh exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Karan Singh')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Karan Singh', '9876543226', 'SEO Specialist', 'karan.singh@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Karan Singh';
END

-- Check if Deepika Verma exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Deepika Verma')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Deepika Verma', '9876543227', 'Field Operations Manager', 'deepika.verma@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Deepika Verma';
END

-- Check if Varun Khanna exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Varun Khanna')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Varun Khanna', '9876543228', 'Regional Sales Executive', 'varun.khanna@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Varun Khanna';
END

-- Check if Pooja Malhotra exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Pooja Malhotra')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Pooja Malhotra', '9876543229', 'Customer Relationship Executive', 'pooja.malhotra@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Pooja Malhotra';
END

-- Check if Abhishek Gupta exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Abhishek Gupta')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Abhishek Gupta', '9876543230', 'Market Research Analyst', 'abhishek.gupta@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Abhishek Gupta';
END

-- Check if Riya Bansal exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Riya Bansal')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Riya Bansal', '9876543231', 'Data Analytics Specialist', 'riya.bansal@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Riya Bansal';
END

-- Check if Nikhil Pandey exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Nikhil Pandey')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Nikhil Pandey', '9876543232', 'Project Coordinator', 'nikhil.pandey@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Nikhil Pandey';
END

-- Check if Shreya Kapoor exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Shreya Kapoor')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Shreya Kapoor', '9876543233', 'Administrative Assistant', 'shreya.kapoor@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Shreya Kapoor';
END

-- Check if Manish Kumar exists
IF NOT EXISTS (SELECT 1 FROM Employees WHERE Name = 'Manish Kumar')
BEGIN
    INSERT INTO Employees (Name, Contact, Designation, Email, CreatedAt, IsActive)
    VALUES ('Manish Kumar', '9876543234', 'Training & Development Executive', 'manish.kumar@actionmedical.com', GETDATE(), 1);
    PRINT 'Inserted Manish Kumar';
END

-- 7. Update or Insert Users from Excel data
PRINT 'Updating Users from Excel data...';

-- Check if admin user exists
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'admin@actionmedical.com')
BEGIN
    INSERT INTO Users (Username, PasswordHash, Role, EmployeeId, CreatedAt, IsActive)
    VALUES ('admin@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Admin', NULL, GETDATE(), 1);
    PRINT 'Inserted admin user';
END

-- Check if Rahul Sharma user exists
DECLARE @RahulEmployeeId INT = (SELECT EmployeeId FROM Employees WHERE Name = 'Rahul Sharma');
IF @RahulEmployeeId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'rahul.sharma@actionmedical.com')
BEGIN
    INSERT INTO Users (Username, PasswordHash, Role, EmployeeId, CreatedAt, IsActive)
    VALUES ('rahul.sharma@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', @RahulEmployeeId, GETDATE(), 1);
    PRINT 'Inserted Rahul Sharma user';
END

-- Check if Dr. Arjun Mehta user exists
DECLARE @ArjunEmployeeId INT = (SELECT EmployeeId FROM Employees WHERE Name = 'Dr. Arjun Mehta');
IF @ArjunEmployeeId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'arjun.mehta@actionmedical.com')
BEGIN
    INSERT INTO Users (Username, PasswordHash, Role, EmployeeId, CreatedAt, IsActive)
    VALUES ('arjun.mehta@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', @ArjunEmployeeId, GETDATE(), 1);
    PRINT 'Inserted Dr. Arjun Mehta user';
END

-- Insert remaining users for all employees
DECLARE @EmployeeId INT, @Email NVARCHAR(200), @Name NVARCHAR(100);

DECLARE employee_cursor CURSOR FOR 
SELECT EmployeeId, Email, Name FROM Employees 
WHERE Email NOT IN (SELECT Username FROM Users) AND Email IS NOT NULL;

OPEN employee_cursor;
FETCH NEXT FROM employee_cursor INTO @EmployeeId, @Email, @Name;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO Users (Username, PasswordHash, Role, EmployeeId, CreatedAt, IsActive)
    VALUES (@Email, 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', @EmployeeId, GETDATE(), 1);
    PRINT 'Inserted user for ' + @Name;
    
    FETCH NEXT FROM employee_cursor INTO @EmployeeId, @Email, @Name;
END

CLOSE employee_cursor;
DEALLOCATE employee_cursor;

-- 8. Update or Insert Locations from Excel data
PRINT 'Updating Locations from Excel data...';

-- Check if Test Location exists
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Test Location')
BEGIN
    INSERT INTO Locations (LocationName, State, CreatedAt, IsActive)
    VALUES ('Test Location', 'Test State', GETDATE(), 1);
    PRINT 'Inserted Test Location';
END

-- Check if Connaught Place exists
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Connaught Place')
BEGIN
    INSERT INTO Locations (LocationName, State, CreatedAt, IsActive)
    VALUES ('Connaught Place', 'Delhi', GETDATE(), 1);
    PRINT 'Inserted Connaught Place';
END

-- Check if Khan Market exists
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Khan Market')
BEGIN
    INSERT INTO Locations (LocationName, State, CreatedAt, IsActive)
    VALUES ('Khan Market', 'Delhi', GETDATE(), 1);
    PRINT 'Inserted Khan Market';
END

-- Check if Lajpat Nagar exists
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Lajpat Nagar')
BEGIN
    INSERT INTO Locations (LocationName, State, CreatedAt, IsActive)
    VALUES ('Lajpat Nagar', 'Delhi', GETDATE(), 1);
    PRINT 'Inserted Lajpat Nagar';
END

-- Check if Saket exists
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Saket')
BEGIN
    INSERT INTO Locations (LocationName, State, CreatedAt, IsActive)
    VALUES ('Saket', 'Delhi', GETDATE(), 1);
    PRINT 'Inserted Saket';
END

-- Check if Dwarka exists
IF NOT EXISTS (SELECT 1 FROM Locations WHERE LocationName = 'Dwarka')
BEGIN
    INSERT INTO Locations (LocationName, State, CreatedAt, IsActive)
    VALUES ('Dwarka', 'Delhi', GETDATE(), 1);
    PRINT 'Inserted Dwarka';
END

-- 9. Update Locations with StateId, AreaId, and PincodeId
PRINT 'Updating Locations with hierarchical data...';

-- Get Delhi StateId
DECLARE @DelhiStateId INT = (SELECT StateId FROM States WHERE StateName = 'Delhi');
DECLARE @HaryanaStateId INT = (SELECT StateId FROM States WHERE StateName = 'Haryana');

-- Get Area IDs
DECLARE @CentralDelhiAreaId INT = (SELECT AreaId FROM Areas WHERE AreaName = 'Central Delhi' AND StateId = @DelhiStateId);
DECLARE @SouthDelhiAreaId INT = (SELECT AreaId FROM Areas WHERE AreaName = 'South Delhi' AND StateId = @DelhiStateId);
DECLARE @GurgaonAreaId INT = (SELECT AreaId FROM Areas WHERE AreaName = 'Gurgaon' AND StateId = @HaryanaStateId);

-- Get Pincode IDs
DECLARE @CPPincodeId INT = (SELECT PincodeId FROM Pincodes WHERE LocalityName = 'Connaught Place' AND AreaId = @CentralDelhiAreaId);
DECLARE @LajpatNagarPincodeId INT = (SELECT PincodeId FROM Pincodes WHERE LocalityName = 'Lajpat Nagar' AND AreaId = @SouthDelhiAreaId);
DECLARE @HauzKhasPincodeId INT = (SELECT PincodeId FROM Pincodes WHERE LocalityName = 'Hauz Khas' AND AreaId = @SouthDelhiAreaId);
DECLARE @SaketPincodeId INT = (SELECT PincodeId FROM Pincodes WHERE LocalityName = 'Saket' AND AreaId = @SouthDelhiAreaId);

-- Update Connaught Place
IF @DelhiStateId IS NOT NULL AND @CentralDelhiAreaId IS NOT NULL AND @CPPincodeId IS NOT NULL
BEGIN
    UPDATE Locations 
    SET StateId = @DelhiStateId, AreaId = @CentralDelhiAreaId, PincodeId = @CPPincodeId
    WHERE LocationName = 'Connaught Place' AND State = 'Delhi';
    PRINT 'Updated Connaught Place with hierarchical data';
END

-- Update Lajpat Nagar
IF @DelhiStateId IS NOT NULL AND @SouthDelhiAreaId IS NOT NULL AND @LajpatNagarPincodeId IS NOT NULL
BEGIN
    UPDATE Locations 
    SET StateId = @DelhiStateId, AreaId = @SouthDelhiAreaId, PincodeId = @LajpatNagarPincodeId
    WHERE LocationName = 'Lajpat Nagar' AND State = 'Delhi';
    PRINT 'Updated Lajpat Nagar with hierarchical data';
END

-- Update Hauz Khas
IF @DelhiStateId IS NOT NULL AND @SouthDelhiAreaId IS NOT NULL AND @HauzKhasPincodeId IS NOT NULL
BEGIN
    UPDATE Locations 
    SET StateId = @DelhiStateId, AreaId = @SouthDelhiAreaId, PincodeId = @HauzKhasPincodeId
    WHERE LocationName = 'Hauz Khas' AND State = 'Delhi';
    PRINT 'Updated Hauz Khas with hierarchical data';
END

-- Update Saket
IF @DelhiStateId IS NOT NULL AND @SouthDelhiAreaId IS NOT NULL AND @SaketPincodeId IS NOT NULL
BEGIN
    UPDATE Locations 
    SET StateId = @DelhiStateId, AreaId = @SouthDelhiAreaId, PincodeId = @SaketPincodeId
    WHERE LocationName = 'Saket' AND State = 'Delhi';
    PRINT 'Updated Saket with hierarchical data';
END

-- Update all Delhi locations with StateId
IF @DelhiStateId IS NOT NULL
BEGIN
    UPDATE Locations 
    SET StateId = @DelhiStateId
    WHERE State = 'Delhi' AND StateId IS NULL;
    PRINT 'Updated all Delhi locations with StateId';
END

-- Update all Haryana locations with StateId
IF @HaryanaStateId IS NOT NULL
BEGIN
    UPDATE Locations 
    SET StateId = @HaryanaStateId
    WHERE State = 'Haryana' AND StateId IS NULL;
    PRINT 'Updated all Haryana locations with StateId';
END

-- 10. Update or Insert Tasks from Excel data
PRINT 'Updating Tasks from Excel data...';

-- Get User IDs and Employee IDs
DECLARE @AdminUserId INT = (SELECT UserId FROM Users WHERE Username = 'admin@actionmedical.com');
DECLARE @RahulUserId INT = (SELECT UserId FROM Users WHERE Username = 'rahul.sharma@actionmedical.com');
DECLARE @RahulEmpId INT = (SELECT EmployeeId FROM Employees WHERE Name = 'Rahul Sharma');

-- Get Location IDs
DECLARE @CPLocationId INT = (SELECT LocationId FROM Locations WHERE LocationName = 'Connaught Place');
DECLARE @KhanMarketLocationId INT = (SELECT LocationId FROM Locations WHERE LocationName = 'Khan Market');
DECLARE @DwarkaLocationId INT = (SELECT LocationId FROM Locations WHERE LocationName = 'Dwarka');
DECLARE @Sector29LocationId INT = (SELECT LocationId FROM Locations WHERE LocationName = 'Sector 29');

-- Check if Tasks table is empty or has sample data
IF NOT EXISTS (SELECT 1 FROM Tasks WHERE TaskId = 2)
BEGIN
    -- Insert Task 2
    INSERT INTO Tasks (
        TaskId, AssignedByUserId, EmployeeId, LocationId, CustomLocation, 
        Description, Priority, TaskDate, Deadline, Status, 
        CreatedAt, UpdatedAt, TaskType, Department, ClientName, 
        ProjectCode, EstimatedHours, ActualHours, TaskCategory, AdditionalNotes, IsUrgent
    )
    VALUES (
        2, @AdminUserId, @RahulEmpId, NULL, 'Piragadi Hospital',
        'Marketing', 'Low', '2025-08-08', '2025-09-08', 'Completed',
        GETDATE(), GETDATE(), 'General', 'Marketing', NULL,
        NULL, NULL, NULL, 'Field Work', NULL, 0
    );
    PRINT 'Inserted Task 2';
    
    -- Insert Task 6
    INSERT INTO Tasks (
        TaskId, AssignedByUserId, EmployeeId, LocationId, CustomLocation, 
        Description, Priority, TaskDate, Deadline, Status, 
        CreatedAt, UpdatedAt, TaskType, Department, ClientName, 
        ProjectCode, EstimatedHours, ActualHours, TaskCategory, AdditionalNotes, IsUrgent
    )
    VALUES (
        6, @AdminUserId, @RahulEmpId, @CPLocationId, NULL,
        'Conduct market research and analysis for new healthcare services in Connaught Place area. Survey potential customers and analyze competitor pricing strategies.', 
        'High', '2024-08-08', '2024-08-15', 'Not Started',
        GETDATE(), GETDATE(), 'Marketing Campaign', 'Marketing', 'Action Medical Institute',
        'AMI-2024-001', 16, NULL, 'Field Work', 'Please coordinate with local healthcare providers and ensure all survey forms are completed accurately. Priority focus on age group 25-55.', 1
    );
    PRINT 'Inserted Task 6';
    
    -- Insert Task 7
    INSERT INTO Tasks (
        TaskId, AssignedByUserId, EmployeeId, LocationId, CustomLocation, 
        Description, Priority, TaskDate, Deadline, Status, 
        CreatedAt, UpdatedAt, TaskType, Department, ClientName, 
        ProjectCode, EstimatedHours, ActualHours, TaskCategory, AdditionalNotes, IsUrgent
    )
    VALUES (
        7, @AdminUserId, @RahulEmpId, NULL, 'Corporate Office, Sector 18, Noida',
        'Meet with potential corporate client to discuss employee health checkup packages. Present our comprehensive healthcare solutions and pricing models.', 
        'Medium', '2024-08-10', '2024-08-12', 'In Progress',
        GETDATE(), GETDATE(), 'Client Meeting', 'Business Development', 'TechCorp Solutions Pvt Ltd',
        'AMI-2024-002', 4, NULL, 'Client Work', 'Bring presentation materials, brochures, and pricing sheets. Meeting scheduled at 2:00 PM with HR Director.', 0
    );
    PRINT 'Inserted Task 7';
    
    -- Insert Task 8
    INSERT INTO Tasks (
        TaskId, AssignedByUserId, EmployeeId, LocationId, CustomLocation, 
        Description, Priority, TaskDate, Deadline, Status, 
        CreatedAt, UpdatedAt, TaskType, Department, ClientName, 
        ProjectCode, EstimatedHours, ActualHours, TaskCategory, AdditionalNotes, IsUrgent
    )
    VALUES (
        8, @AdminUserId, @RahulEmpId, @DwarkaLocationId, NULL,
        'Collect patient feedback data from Dwarka branch and compile monthly satisfaction report. Interview at least 50 patients across different departments.', 
        'Medium', '2024-08-09', '2024-08-14', 'Not Started',
        GETDATE(), GETDATE(), 'Data Collection', 'Operations', 'Action Medical Institute',
        'AMI-2024-003', 12, NULL, 'Field Work', 'Focus on cardiology, orthopedics, and general medicine departments. Use standardized feedback forms and ensure patient privacy.', 0
    );
    PRINT 'Inserted Task 8';
    
    -- Insert Task 9
    INSERT INTO Tasks (
        TaskId, AssignedByUserId, EmployeeId, LocationId, CustomLocation, 
        Description, Priority, TaskDate, Deadline, Status, 
        CreatedAt, UpdatedAt, TaskType, Department, ClientName, 
        ProjectCode, EstimatedHours, ActualHours, TaskCategory, AdditionalNotes, IsUrgent
    )
    VALUES (
        9, @AdminUserId, @RahulEmpId, NULL, NULL,
        'Prepare comprehensive monthly marketing performance report including campaign effectiveness, lead generation metrics, and ROI analysis.', 
        'Low', '2024-08-11', '2024-08-18', 'Not Started',
        GETDATE(), GETDATE(), 'Report Generation', 'Marketing', 'Action Medical Institute',
        'AMI-2024-004', 8, NULL, 'Office Work', 'Include charts, graphs, and actionable recommendations. Submit in both PDF and PowerPoint formats.', 0
    );
    PRINT 'Inserted Task 9';
    
    -- Insert Task 10
    INSERT INTO Tasks (
        TaskId, AssignedByUserId, EmployeeId, LocationId, CustomLocation, 
        Description, Priority, TaskDate, Deadline, Status, 
        CreatedAt, UpdatedAt, TaskType, Department, ClientName, 
        ProjectCode, EstimatedHours, ActualHours, TaskCategory, AdditionalNotes, IsUrgent
    )
    VALUES (
        10, @AdminUserId, @RahulEmpId, @Sector29LocationId, NULL,
        'Conduct customer service training session for front desk staff at Sector 29 branch. Cover communication skills, patient handling, and complaint resolution.', 
        'High', '2024-08-12', '2024-08-13', 'In Progress',
        GETDATE(), GETDATE(), 'Training', 'Customer Service', 'Action Medical Institute',
        'AMI-2024-005', 6, NULL, 'Administrative', 'Prepare training materials, handouts, and assessment forms. Session duration: 3 hours with break.', 1
    );
    PRINT 'Inserted Task 10';
    
    -- Insert Task 11
    INSERT INTO Tasks (
        TaskId, AssignedByUserId, EmployeeId, LocationId, CustomLocation, 
        Description, Priority, TaskDate, Deadline, Status, 
        CreatedAt, UpdatedAt, TaskType, Department, ClientName, 
        ProjectCode, EstimatedHours, ActualHours, TaskCategory, AdditionalNotes, IsUrgent
    )
    VALUES (
        11, @AdminUserId, @RahulEmpId, @KhanMarketLocationId, NULL,
        'Organize health awareness camp at Khan Market focusing on diabetes and hypertension screening. Coordinate with medical team and arrange logistics.', 
        'High', '2024-08-15', '2024-08-16', 'Not Started',
        GETDATE(), GETDATE(), 'Event Management', 'Marketing', 'Action Medical Institute',
        'AMI-2024-006', 20, NULL, 'Field Work', NULL, 0
    );
    PRINT 'Inserted Task 11';
    
    -- Insert Task Status History
    INSERT INTO TaskStatusHistory (TaskId, Status, Remarks, ChangedByUserId, ChangedAt)
    VALUES
    (2, 'Not Started', 'Task created', @AdminUserId, DATEADD(DAY, -30, GETDATE())),
    (2, 'In Progress', 'Work started', @AdminUserId, DATEADD(DAY, -25, GETDATE())),
    (2, 'Completed', 'Task completed successfully', @AdminUserId, DATEADD(DAY, -20, GETDATE())),
    (6, 'Not Started', 'Task created', @AdminUserId, GETDATE()),
    (7, 'Not Started', 'Task created', @AdminUserId, DATEADD(DAY, -5, GETDATE())),
    (7, 'In Progress', 'Started preparation for meeting', @AdminUserId, DATEADD(DAY, -2, GETDATE())),
    (8, 'Not Started', 'Task created', @AdminUserId, GETDATE()),
    (9, 'Not Started', 'Task created', @AdminUserId, GETDATE()),
    (10, 'Not Started', 'Task created', @AdminUserId, DATEADD(DAY, -3, GETDATE())),
    (10, 'In Progress', 'Training materials prepared', @AdminUserId, DATEADD(DAY, -1, GETDATE())),
    (11, 'Not Started', 'Task created', @AdminUserId, GETDATE());
    
    PRINT 'Inserted Task Status History';
END

-- 11. Update sp_GetTasks stored procedure to include all fields
PRINT 'Updating sp_GetTasks stored procedure...';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetTasks')
BEGIN
    DROP PROCEDURE sp_GetTasks;
END
GO

CREATE PROCEDURE sp_GetTasks
    @EmployeeId INT = NULL,
    @Status NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        t.TaskId,
        t.AssignedByUserId,
        u.Username AS AssignedByUsername,
        t.EmployeeId,
        e.Name AS EmployeeName,
        e.Contact AS EmployeeContact,
        e.Designation AS EmployeeDesignation,
        e.Email AS EmployeeEmail,
        t.LocationId,
        l.LocationName,
        l.State,
        t.CustomLocation,
        t.Description,
        t.Priority,
        t.TaskDate,
        t.Deadline,
        t.Status,
        t.TaskType,
        t.Department,
        t.ClientName,
        t.ProjectCode,
        t.EmployeeIdNumber,
        t.EstimatedHours,
        t.ActualHours,
        t.TaskCategory,
        t.AdditionalNotes,
        t.IsUrgent,
        t.CreatedAt,
        t.UpdatedAt
    FROM Tasks t
    INNER JOIN Users u ON t.AssignedByUserId = u.UserId
    INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
    LEFT JOIN Locations l ON t.LocationId = l.LocationId
    WHERE 
        (@EmployeeId IS NULL OR t.EmployeeId = @EmployeeId)
        AND (@Status IS NULL OR t.Status = @Status)
    ORDER BY t.CreatedAt DESC;
END
GO

PRINT 'sp_GetTasks stored procedure updated successfully!';

-- 12. Update sp_InsertTask stored procedure to include all fields
PRINT 'Updating sp_InsertTask stored procedure...';

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_InsertTask')
BEGIN
    DROP PROCEDURE sp_InsertTask;
END
GO

CREATE PROCEDURE sp_InsertTask
    @AssignedByUserId INT,
    @EmployeeId INT,
    @LocationId INT = NULL,
    @CustomLocation NVARCHAR(100) = NULL,
    @Description NVARCHAR(500),
    @Priority NVARCHAR(10),
    @TaskDate DATE,
    @Deadline DATE,
    @Status NVARCHAR(20) = 'Not Started',
    @TaskType NVARCHAR(50) = 'General',
    @Department NVARCHAR(100) = 'Marketing',
    @ClientName NVARCHAR(200) = NULL,
    @ProjectCode NVARCHAR(100) = NULL,
    @EstimatedHours DECIMAL(5,2) = NULL,
    @TaskCategory NVARCHAR(50) = 'Field Work',
    @AdditionalNotes NVARCHAR(1000) = NULL,
    @IsUrgent BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TaskId INT;
    
    INSERT INTO Tasks (
        AssignedByUserId,
        EmployeeId,
        LocationId,
        CustomLocation,
        Description,
        Priority,
        TaskDate,
        Deadline,
        Status,
        TaskType,
        Department,
        ClientName,
        ProjectCode,
        EstimatedHours,
        TaskCategory,
        AdditionalNotes,
        IsUrgent,
        CreatedAt,
        UpdatedAt
    )
    VALUES (
        @AssignedByUserId,
        @EmployeeId,
        @LocationId,
        @CustomLocation,
        @Description,
        @Priority,
        @TaskDate,
        @Deadline,
        @Status,
        @TaskType,
        @Department,
        @ClientName,
        @ProjectCode,
        @EstimatedHours,
        @TaskCategory,
        @AdditionalNotes,
        @IsUrgent,
        GETDATE(),
        GETDATE()
    );
    
    SET @TaskId = SCOPE_IDENTITY();
    
    -- Insert initial status history
    INSERT INTO TaskStatusHistory (
        TaskId,
        Status,
        Remarks,
        ChangedByUserId,
        ChangedAt
    )
    VALUES (
        @TaskId,
        @Status,
        'Task created',
        @AssignedByUserId,
        GETDATE()
    );
    
    SELECT @TaskId AS TaskId;
END
GO

PRINT 'sp_InsertTask stored procedure updated successfully!';

-- 13. Create stored procedures for hierarchical location data if they don't exist
PRINT 'Creating hierarchical location stored procedures...';

-- Get States
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetStates')
BEGIN
    EXEC('
    CREATE PROCEDURE sp_GetStates
    AS
    BEGIN
      SET NOCOUNT ON;
      SELECT StateId, StateName, StateCode, IsActive 
      FROM States 
      WHERE IsActive = 1 
      ORDER BY StateName;
    END
    ');
    PRINT 'sp_GetStates created successfully!';
END

-- Get Cities By State
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetCitiesByState')
BEGIN
    EXEC('
    CREATE PROCEDURE sp_GetCitiesByState
      @StateId INT
    AS
    BEGIN
      SET NOCOUNT ON;
      SELECT AreaId as CityId, AreaName as CityName 
      FROM Areas 
      WHERE StateId = @StateId AND IsActive = 1 
      ORDER BY AreaName;
    END
    ');
    PRINT 'sp_GetCitiesByState created successfully!';
END

-- Get Pincodes By Area
IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetPincodesByArea')
BEGIN
    EXEC('
    CREATE PROCEDURE sp_GetPincodesByArea
      @AreaId INT
    AS
    BEGIN
      SET NOCOUNT ON;
      SELECT PincodeId, Pincode as PincodeValue, AreaId, LocalityName, IsActive
      FROM Pincodes 
      WHERE AreaId = @AreaId AND IsActive = 1 
      ORDER BY Pincode;
    END
    ');
    PRINT 'sp_GetPincodesByArea created successfully!';
END

-- 14. Verify database setup
PRINT 'Verifying database setup...';

-- Verify tables and columns
SELECT 'Employees Count' as Info, COUNT(*) as Count FROM Employees;
SELECT 'Users Count' as Info, COUNT(*) as Count FROM Users;
SELECT 'Locations Count' as Info, COUNT(*) as Count FROM Locations;
SELECT 'Tasks Count' as Info, COUNT(*) as Count FROM Tasks;
SELECT 'TaskStatusHistory Count' as Info, COUNT(*) as Count FROM TaskStatusHistory;
SELECT 'States Count' as Info, COUNT(*) as Count FROM States;
SELECT 'Areas Count' as Info, COUNT(*) as Count FROM Areas;
SELECT 'Pincodes Count' as Info, COUNT(*) as Count FROM Pincodes;

-- Verify stored procedures
SELECT 'Stored Procedures Count' as Info, COUNT(*) as Count 
FROM sys.objects 
WHERE type = 'P' AND name LIKE 'sp_%';

PRINT '=============================================';
PRINT 'DATABASE UPDATE FROM EXCEL DATA COMPLETED SUCCESSFULLY!';
PRINT '=============================================';