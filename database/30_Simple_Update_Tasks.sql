-- Simple update to populate missing task data
USE marketing_db;
GO

-- Update basic location data
UPDATE Tasks 
SET 
    StateId = 1,
    CityId = 1,
    AreaId = 1,
    StateName = 'Delhi',
    CityName = 'Delhi',
    LocalityName = 'Connaught Place',
    PincodeValue = '110001'
WHERE StateId IS NULL;

-- Update EmployeeIdNumber
UPDATE Tasks 
SET EmployeeIdNumber = 'EMP' + RIGHT('000' + CAST(EmployeeId AS VARCHAR), 3)
WHERE EmployeeIdNumber IS NULL;

-- Update ClientName
UPDATE Tasks 
SET ClientName = 'Action Medical Institute'
WHERE ClientName IS NULL;

-- Update ProjectCode
UPDATE Tasks 
SET ProjectCode = 'AMI-2024-' + RIGHT('000' + CAST(TaskId AS VARCHAR), 3)
WHERE ProjectCode IS NULL;

-- Update EstimatedHours
UPDATE Tasks 
SET EstimatedHours = 8.00
WHERE EstimatedHours IS NULL;

-- Update UserId
UPDATE Tasks 
SET UserId = 2
WHERE UserId IS NULL;

-- Update ConsultantFeedback
UPDATE Tasks 
SET ConsultantFeedback = 'Task completed successfully.'
WHERE ConsultantFeedback IS NULL;

PRINT 'Task data updated successfully!';
