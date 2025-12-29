USE marketing_db;
GO

-- =============================================
-- ADD SAMPLE TASKS FOR NEW EMPLOYEES
-- This script creates diverse tasks for the newly added employees
-- =============================================

PRINT '=============================================';
PRINT 'ADDING SAMPLE TASKS FOR NEW EMPLOYEES';
PRINT '=============================================';

-- Insert comprehensive tasks for different employees and designations
INSERT INTO Tasks (
    AssignedByUserId, EmployeeId, LocationId, CustomLocation, Description, Priority, 
    TaskDate, Deadline, Status, TaskType, Department, ClientName, ProjectCode, 
    EstimatedHours, ActualHours, TaskCategory, AdditionalNotes, IsUrgent, 
    CreatedAt, UpdatedAt
) VALUES

-- Tasks for Dr. Arjun Mehta (Chief Marketing Officer)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'arjun.mehta@actionmedical.com'), NULL, NULL, 
'Develop comprehensive Q4 marketing strategy for Action Medical Institute. Include budget allocation, campaign planning, and performance metrics.', 'High', 
'2024-08-20', '2024-08-30', 'Not Started', 'Strategic Planning', 'Marketing', 'Action Medical Institute', 'AMI-2024-011', 
40.0, NULL, 'Strategic Planning', 'Board presentation required. Include competitive analysis and ROI projections.', 1, 
GETDATE(), GETDATE()),

-- Tasks for Kavya Sharma (Marketing Director)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'kavya.sharma@actionmedical.com'), 1, NULL, 
'Coordinate multi-channel marketing campaign launch for new cardiology services at Connaught Place branch.', 'High', 
'2024-08-21', '2024-08-28', 'Not Started', 'Campaign Management', 'Marketing', 'Action Medical Institute', 'AMI-2024-012', 
32.0, NULL, 'Campaign Management', 'Coordinate with digital, print, and outdoor advertising teams. Budget: 5 lakhs.', 1, 
GETDATE(), GETDATE()),

-- Tasks for Rohit Agarwal (Business Development Manager)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'rohit.agarwal@actionmedical.com'), NULL, 'Corporate Hub, Cyber City, Gurgaon', 
'Negotiate corporate health package deals with 5 major IT companies in Gurgaon. Target 1000+ employee companies.', 'Medium', 
'2024-08-22', '2024-09-05', 'Not Started', 'Business Development', 'Business Development', 'Multiple Corporate Clients', 'AMI-2024-013', 
60.0, NULL, 'Client Acquisition', 'Prepare customized proposals for each company. Focus on preventive health packages.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Ananya Joshi (Digital Marketing Manager)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'ananya.joshi@actionmedical.com'), NULL, NULL, 
'Launch and manage Google Ads and Facebook advertising campaigns for diabetes awareness program.', 'Medium', 
'2024-08-23', '2024-09-10', 'Not Started', 'Digital Marketing', 'Marketing', 'Action Medical Institute', 'AMI-2024-014', 
25.0, NULL, 'Digital Marketing', 'Target audience: 35-65 age group in Delhi NCR. Budget: 2 lakhs for 3 weeks.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Siddharth Rao (Content Marketing Specialist)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'siddharth.rao@actionmedical.com'), NULL, NULL, 
'Create comprehensive content calendar for Q4 including blog posts, social media content, and email newsletters.', 'Medium', 
'2024-08-24', '2024-09-01', 'Not Started', 'Content Creation', 'Marketing', 'Action Medical Institute', 'AMI-2024-015', 
20.0, NULL, 'Content Development', 'Focus on health awareness topics, patient success stories, and medical breakthroughs.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Meera Nair (Social Media Manager)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'meera.nair@actionmedical.com'), NULL, NULL, 
'Manage social media presence across all platforms and increase follower engagement by 25%.', 'Medium', 
'2024-08-25', '2024-09-15', 'Not Started', 'Social Media Management', 'Marketing', 'Action Medical Institute', 'AMI-2024-016', 
30.0, NULL, 'Social Media', 'Post daily content, respond to queries, and run engagement campaigns.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Karan Singh (SEO Specialist)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'karan.singh@actionmedical.com'), NULL, NULL, 
'Optimize website SEO to improve organic search rankings for healthcare-related keywords.', 'Low', 
'2024-08-26', '2024-09-20', 'Not Started', 'SEO Optimization', 'Marketing', 'Action Medical Institute', 'AMI-2024-017', 
35.0, NULL, 'Digital Marketing', 'Target keywords: cardiology Delhi, best hospital Gurgaon, health checkup packages.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Deepika Verma (Field Operations Manager)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'deepika.verma@actionmedical.com'), 5, NULL, 
'Supervise and coordinate field marketing activities across all Dwarka region locations.', 'High', 
'2024-08-27', '2024-09-10', 'Not Started', 'Field Operations', 'Operations', 'Action Medical Institute', 'AMI-2024-018', 
45.0, NULL, 'Field Management', 'Ensure all field executives meet their monthly targets and maintain quality standards.', 1, 
GETDATE(), GETDATE()),

-- Tasks for Varun Khanna (Regional Sales Executive)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'varun.khanna@actionmedical.com'), 11, NULL, 
'Conduct door-to-door marketing campaign in Gurgaon residential areas for health checkup packages.', 'Medium', 
'2024-08-28', '2024-09-12', 'Not Started', 'Sales Campaign', 'Sales', 'Action Medical Institute', 'AMI-2024-019', 
50.0, NULL, 'Field Sales', 'Target 500 households, focus on families with senior citizens and young professionals.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Pooja Malhotra (Customer Relationship Executive)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'pooja.malhotra@actionmedical.com'), NULL, NULL, 
'Follow up with existing patients for feedback and referral program enrollment.', 'Medium', 
'2024-08-29', '2024-09-15', 'Not Started', 'Customer Relations', 'Customer Service', 'Action Medical Institute', 'AMI-2024-020', 
40.0, NULL, 'Customer Engagement', 'Contact 200 patients, collect feedback, and promote referral rewards program.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Abhishek Gupta (Market Research Analyst)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'abhishek.gupta@actionmedical.com'), NULL, NULL, 
'Conduct comprehensive market research on healthcare trends in Delhi NCR region.', 'Low', 
'2024-08-30', '2024-09-20', 'Not Started', 'Market Research', 'Research', 'Action Medical Institute', 'AMI-2024-021', 
60.0, NULL, 'Research & Analysis', 'Analyze competitor pricing, service offerings, and customer satisfaction levels.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Riya Bansal (Data Analytics Specialist)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'riya.bansal@actionmedical.com'), NULL, NULL, 
'Analyze patient data and marketing campaign performance to generate insights report.', 'Medium', 
'2024-08-31', '2024-09-14', 'Not Started', 'Data Analysis', 'Analytics', 'Action Medical Institute', 'AMI-2024-022', 
28.0, NULL, 'Data Analytics', 'Use advanced analytics tools to identify trends and optimization opportunities.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Nikhil Pandey (Project Coordinator)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'nikhil.pandey@actionmedical.com'), 8, NULL, 
'Coordinate health awareness camp setup at Janakpuri location including logistics and volunteer management.', 'High', 
'2024-09-01', '2024-09-05', 'Not Started', 'Event Coordination', 'Operations', 'Action Medical Institute', 'AMI-2024-023', 
35.0, NULL, 'Event Management', 'Arrange medical equipment, registration setup, promotional materials, and refreshments.', 1, 
GETDATE(), GETDATE()),

-- Tasks for Shreya Kapoor (Administrative Assistant)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'shreya.kapoor@actionmedical.com'), NULL, NULL, 
'Organize and digitize marketing department files and create monthly activity reports.', 'Low', 
'2024-09-02', '2024-09-16', 'Not Started', 'Administrative', 'Administration', 'Action Medical Institute', 'AMI-2024-024', 
15.0, NULL, 'Administrative', 'Ensure all documents are properly filed and create digital backup system.', 0, 
GETDATE(), GETDATE()),

-- Tasks for Manish Kumar (Training & Development Executive)
(2, (SELECT EmployeeId FROM Employees WHERE Email = 'manish.kumar@actionmedical.com'), 15, NULL, 
'Conduct customer service training workshop for all front desk staff at Sector 29 branch.', 'Medium', 
'2024-09-03', '2024-09-07', 'Not Started', 'Training', 'Human Resources', 'Action Medical Institute', 'AMI-2024-025', 
24.0, NULL, 'Training & Development', 'Cover communication skills, patient handling, complaint resolution, and emergency procedures.', 0, 
GETDATE(), GETDATE());

PRINT 'Sample tasks for new employees inserted successfully!';

-- Verify the inserted tasks
PRINT 'Verifying inserted tasks by employee:';
SELECT 
    e.Name,
    e.Designation,
    t.Description,
    t.Priority,
    t.TaskType,
    t.Department,
    t.EstimatedHours,
    t.Deadline
FROM Tasks t
INNER JOIN Employees e ON t.EmployeeId = e.EmployeeId
WHERE t.TaskId > (SELECT MAX(TaskId) - 15 FROM Tasks)
ORDER BY e.Name, t.TaskId;

PRINT '=============================================';
PRINT 'TASK SUMMARY BY DEPARTMENT:';
SELECT 
    Department,
    COUNT(*) as TaskCount,
    AVG(EstimatedHours) as AvgEstimatedHours
FROM Tasks 
WHERE TaskId > (SELECT MAX(TaskId) - 15 FROM Tasks)
GROUP BY Department
ORDER BY TaskCount DESC;

PRINT '=============================================';
PRINT 'TASK SUMMARY BY PRIORITY:';
SELECT 
    Priority,
    COUNT(*) as TaskCount
FROM Tasks 
WHERE TaskId > (SELECT MAX(TaskId) - 15 FROM Tasks)
GROUP BY Priority
ORDER BY 
    CASE Priority 
        WHEN 'High' THEN 1 
        WHEN 'Medium' THEN 2 
        WHEN 'Low' THEN 3 
    END;

PRINT '=============================================';
PRINT 'SAMPLE TASKS FOR NEW EMPLOYEES ADDED SUCCESSFULLY!';
PRINT '=============================================';