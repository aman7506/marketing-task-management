USE marketing_db;
GO

-- =============================================
-- INSERT SAMPLE TEST DATA
-- This script adds comprehensive sample data for testing
-- =============================================

PRINT '=============================================';
PRINT 'INSERTING SAMPLE TEST DATA';
PRINT '=============================================';

-- Insert sample tasks with comprehensive data
INSERT INTO Tasks (
    AssignedByUserId, EmployeeId, CityId, CustomLocation, Description, Priority,
    TaskDate, Deadline, Status, TaskType, Department, ClientName, ProjectCode,
    EstimatedHours, ActualHours, TaskCategory, AdditionalNotes, IsUrgent,
    CreatedAt, UpdatedAt
) VALUES
-- Task 1: Marketing Campaign
(1, 2, 1, NULL, 'Conduct market research and analysis for new healthcare services in Connaught Place area. Survey potential customers and analyze competitor pricing strategies.', 'High',
'2024-08-08', '2024-08-15', 'Not Started', 'Marketing Campaign', 'Marketing', 'Action Medical Institute', 'AMI-2024-001',
16.0, NULL, 'Field Work', 'Please coordinate with local healthcare providers and ensure all survey forms are completed accurately. Priority focus on age group 25-55.', 1,
GETDATE(), GETDATE()),

-- Task 2: Client Meeting
(1, 2, NULL, 'Corporate Office, Sector 18, Noida', 'Meet with potential corporate client to discuss employee health checkup packages. Present our comprehensive healthcare solutions and pricing models.', 'Medium',
'2024-08-10', '2024-08-12', 'Not Started', 'Client Meeting', 'Business Development', 'TechCorp Solutions Pvt Ltd', 'AMI-2024-002',
4.0, NULL, 'Client Work', 'Bring presentation materials, brochures, and pricing sheets. Meeting scheduled at 2:00 PM with HR Director.', 0,
GETDATE(), GETDATE()),

-- Task 3: Data Collection
(1, 2, 5, NULL, 'Collect patient feedback data from Dwarka branch and compile monthly satisfaction report. Interview at least 50 patients across different departments.', 'Medium',
'2024-08-09', '2024-08-14', 'Not Started', 'Data Collection', 'Operations', 'Action Medical Institute', 'AMI-2024-003',
12.0, NULL, 'Field Work', 'Focus on cardiology, orthopedics, and general medicine departments. Use standardized feedback forms and ensure patient privacy.', 0,
GETDATE(), GETDATE()),

-- Task 4: Report Generation
(1, 2, NULL, NULL, 'Prepare comprehensive monthly marketing performance report including campaign effectiveness, lead generation metrics, and ROI analysis.', 'Low',
'2024-08-11', '2024-08-18', 'Not Started', 'Report Generation', 'Marketing', 'Action Medical Institute', 'AMI-2024-004',
8.0, NULL, 'Office Work', 'Include charts, graphs, and actionable recommendations. Submit in both PDF and PowerPoint formats.', 0,
GETDATE(), GETDATE()),

-- Task 5: Training Session
(1, 2, 15, NULL, 'Conduct customer service training session for front desk staff at Sector 29 branch. Cover communication skills, patient handling, and complaint resolution.', 'High',
'2024-08-12', '2024-08-13', 'Not Started', 'Training', 'Customer Service', 'Action Medical Institute', 'AMI-2024-005',
6.0, NULL, 'Administrative', 'Prepare training materials, handouts, and assessment forms. Session duration: 3 hours with break.', 1,
GETDATE(), GETDATE()),

-- Task 6: Event Management
(1, 2, 2, NULL, 'Organize health awareness camp at Khan Market focusing on diabetes and hypertension screening. Coordinate with medical team and arrange logistics.', 'High',
'2024-08-15', '2024-08-16', 'Not Started', 'Event Management', 'Marketing', 'Action Medical Institute', 'AMI-2024-006',
20.0, NULL, 'Field Work', 'Arrange medical equipment, registration desk, promotional materials, and refreshments. Expected 200+ participants.', 1,
GETDATE(), GETDATE()),

-- Task 7: Field Survey
(1, 2, NULL, 'Industrial Area, Faridabad', 'Survey industrial workers for occupational health program requirements. Assess workplace health risks and employee health needs.', 'Medium',
'2024-08-13', '2024-08-20', 'Not Started', 'Field Survey', 'Research', 'Faridabad Industries Association', 'AMI-2024-007',
14.0, NULL, 'Field Work', 'Visit 5 major industrial units. Coordinate with safety officers and HR departments. Use safety protocols.', 0,
GETDATE(), GETDATE()),

-- Task 8: Documentation
(1, 2, NULL, NULL, 'Update and digitize patient registration forms and create online portal user guide. Ensure compliance with healthcare data protection regulations.', 'Low',
'2024-08-14', '2024-08-25', 'Not Started', 'Documentation', 'Operations', 'Action Medical Institute', 'AMI-2024-008',
10.0, NULL, 'Office Work', 'Review legal compliance requirements and coordinate with IT team for portal integration.', 0,
GETDATE(), GETDATE()),

-- Task 9: Coordination
(1, 2, 8, NULL, 'Coordinate with Janakpuri branch for joint marketing campaign launch. Align promotional activities and resource allocation.', 'Medium',
'2024-08-16', '2024-08-22', 'Not Started', 'Coordination', 'Marketing', 'Action Medical Institute', 'AMI-2024-009',
5.0, NULL, 'Coordination', 'Schedule meetings with branch manager and marketing team. Prepare campaign timeline and budget allocation.', 0,
GETDATE(), GETDATE()),

-- Task 10: Research & Analysis
(1, 2, NULL, NULL, 'Research emerging healthcare technologies and analyze their potential implementation in our facilities. Focus on telemedicine and AI diagnostics.', 'Low',
'2024-08-17', '2024-08-30', 'Not Started', 'Research & Analysis', 'Research', 'Action Medical Institute', 'AMI-2024-010',
15.0, NULL, 'Research & Analysis', 'Prepare detailed feasibility report with cost-benefit analysis and implementation roadmap.', 0,
GETDATE(), GETDATE());

PRINT 'Sample tasks inserted successfully!';

-- Verify the inserted data
PRINT 'Verifying inserted sample data:';
SELECT 
    TaskId,
    Description,
    Priority,
    TaskType,
    Department,
    ClientName,
    ProjectCode,
    EstimatedHours,
    TaskCategory,
    IsUrgent
FROM Tasks 
WHERE TaskId > (SELECT MAX(TaskId) - 10 FROM Tasks)
ORDER BY TaskId;

PRINT '=============================================';
PRINT 'SAMPLE TEST DATA INSERTED SUCCESSFULLY!';
PRINT 'Total tasks in database:';
SELECT COUNT(*) as TotalTasks FROM Tasks;
PRINT '=============================================';