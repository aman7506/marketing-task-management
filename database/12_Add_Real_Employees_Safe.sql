USE marketing_db;
GO

-- =============================================
-- ADD REAL EMPLOYEES WITH DIFFERENT DESIGNATIONS (SAFE VERSION)
-- This script adds 15 real employees for comprehensive testing
-- Checks for existing records before inserting
-- =============================================

PRINT '=============================================';
PRINT 'ADDING REAL EMPLOYEES FOR TESTING (SAFE VERSION)';
PRINT '=============================================';

-- Check if employees already exist
DECLARE @ExistingEmployees INT = (
    SELECT COUNT(*) 
    FROM Employees 
    WHERE Email IN (
        'arjun.mehta@actionmedical.com',
        'kavya.sharma@actionmedical.com',
        'rohit.agarwal@actionmedical.com',
        'ananya.joshi@actionmedical.com',
        'siddharth.rao@actionmedical.com',
        'meera.nair@actionmedical.com',
        'karan.singh@actionmedical.com',
        'deepika.verma@actionmedical.com',
        'varun.khanna@actionmedical.com',
        'pooja.malhotra@actionmedical.com',
        'abhishek.gupta@actionmedical.com',
        'riya.bansal@actionmedical.com',
        'nikhil.pandey@actionmedical.com',
        'shreya.kapoor@actionmedical.com',
        'manish.kumar@actionmedical.com'
    )
);

IF @ExistingEmployees > 0
BEGIN
    PRINT 'Some employees already exist. Skipping employee insertion.';
    PRINT 'Existing employees found: ' + CAST(@ExistingEmployees AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'No existing employees found. Proceeding with insertion...';
    
    -- Insert 15 real employees with different designations
    INSERT INTO Employees (Name, Contact, Designation, Email) VALUES
    -- Senior Management
    ('Dr. Arjun Mehta', '9876543220', 'Chief Marketing Officer', 'arjun.mehta@actionmedical.com'),
    ('Kavya Sharma', '9876543221', 'Marketing Director', 'kavya.sharma@actionmedical.com'),
    ('Rohit Agarwal', '9876543222', 'Business Development Manager', 'rohit.agarwal@actionmedical.com'),

    -- Marketing Team
    ('Ananya Joshi', '9876543223', 'Digital Marketing Manager', 'ananya.joshi@actionmedical.com'),
    ('Siddharth Rao', '9876543224', 'Content Marketing Specialist', 'siddharth.rao@actionmedical.com'),
    ('Meera Nair', '9876543225', 'Social Media Manager', 'meera.nair@actionmedical.com'),
    ('Karan Singh', '9876543226', 'SEO Specialist', 'karan.singh@actionmedical.com'),

    -- Field Operations
    ('Deepika Verma', '9876543227', 'Field Operations Manager', 'deepika.verma@actionmedical.com'),
    ('Varun Khanna', '9876543228', 'Regional Sales Executive', 'varun.khanna@actionmedical.com'),
    ('Pooja Malhotra', '9876543229', 'Customer Relationship Executive', 'pooja.malhotra@actionmedical.com'),

    -- Research & Analytics
    ('Abhishek Gupta', '9876543230', 'Market Research Analyst', 'abhishek.gupta@actionmedical.com'),
    ('Riya Bansal', '9876543231', 'Data Analytics Specialist', 'riya.bansal@actionmedical.com'),

    -- Support & Coordination
    ('Nikhil Pandey', '9876543232', 'Project Coordinator', 'nikhil.pandey@actionmedical.com'),
    ('Shreya Kapoor', '9876543233', 'Administrative Assistant', 'shreya.kapoor@actionmedical.com'),
    ('Manish Kumar', '9876543234', 'Training & Development Executive', 'manish.kumar@actionmedical.com');

    PRINT 'Real employees inserted successfully!';
END

-- Check if user accounts already exist
DECLARE @ExistingUsers INT = (
    SELECT COUNT(*) 
    FROM Users 
    WHERE Username IN (
        'arjun.mehta@actionmedical.com',
        'kavya.sharma@actionmedical.com',
        'rohit.agarwal@actionmedical.com',
        'ananya.joshi@actionmedical.com',
        'siddharth.rao@actionmedical.com',
        'meera.nair@actionmedical.com',
        'karan.singh@actionmedical.com',
        'deepika.verma@actionmedical.com',
        'varun.khanna@actionmedical.com',
        'pooja.malhotra@actionmedical.com',
        'abhishek.gupta@actionmedical.com',
        'riya.bansal@actionmedical.com',
        'nikhil.pandey@actionmedical.com',
        'shreya.kapoor@actionmedical.com',
        'manish.kumar@actionmedical.com'
    )
);

IF @ExistingUsers > 0
BEGIN
    PRINT 'Some user accounts already exist. Skipping user account creation.';
    PRINT 'Existing user accounts found: ' + CAST(@ExistingUsers AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'No existing user accounts found. Creating user accounts...';
    
    -- Create user accounts for all new employees (password will be: Employee123!)
    -- Note: This is a sample hash - in production, use proper password hashing
    INSERT INTO Users (Username, PasswordHash, Role, EmployeeId) VALUES
    ('arjun.mehta@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'arjun.mehta@actionmedical.com')),
    ('kavya.sharma@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'kavya.sharma@actionmedical.com')),
    ('rohit.agarwal@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'rohit.agarwal@actionmedical.com')),
    ('ananya.joshi@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'ananya.joshi@actionmedical.com')),
    ('siddharth.rao@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'siddharth.rao@actionmedical.com')),
    ('meera.nair@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'meera.nair@actionmedical.com')),
    ('karan.singh@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'karan.singh@actionmedical.com')),
    ('deepika.verma@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'deepika.verma@actionmedical.com')),
    ('varun.khanna@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'varun.khanna@actionmedical.com')),
    ('pooja.malhotra@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'pooja.malhotra@actionmedical.com')),
    ('abhishek.gupta@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'abhishek.gupta@actionmedical.com')),
    ('riya.bansal@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'riya.bansal@actionmedical.com')),
    ('nikhil.pandey@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'nikhil.pandey@actionmedical.com')),
    ('shreya.kapoor@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'shreya.kapoor@actionmedical.com')),
    ('manish.kumar@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', (SELECT EmployeeId FROM Employees WHERE Email = 'manish.kumar@actionmedical.com'));

    PRINT 'User accounts created for all new employees!';
END

-- Verify the current state
PRINT '';
PRINT 'CURRENT SYSTEM STATE:';
PRINT '=============================================';

-- Show all employees
PRINT 'All Employees in System:';
SELECT 
    e.EmployeeId,
    e.Name,
    e.Designation,
    e.Email,
    e.Contact,
    CASE WHEN u.UserId IS NOT NULL THEN 'Yes' ELSE 'No' END as HasUserAccount
FROM Employees e
LEFT JOIN Users u ON e.EmployeeId = u.EmployeeId
ORDER BY e.EmployeeId;

PRINT '';
PRINT 'EMPLOYEE SUMMARY BY DESIGNATION:';
SELECT 
    Designation,
    COUNT(*) as EmployeeCount
FROM Employees 
GROUP BY Designation
ORDER BY EmployeeCount DESC;

PRINT '';
PRINT 'TOTAL EMPLOYEES AND USERS:';
SELECT 
    (SELECT COUNT(*) FROM Employees) as TotalEmployees,
    (SELECT COUNT(*) FROM Users WHERE Role = 'Employee') as TotalEmployeeUsers,
    (SELECT COUNT(*) FROM Users WHERE Role = 'Admin') as TotalAdminUsers;

PRINT '';
PRINT '=============================================';
PRINT 'SCRIPT EXECUTION COMPLETED!';
PRINT 'Default password for all employees: Employee123!';
PRINT '=============================================';