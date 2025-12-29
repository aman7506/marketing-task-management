-- Comprehensive update to populate missing task data based on actual descriptions
USE marketing_db;
GO

-- Update location data based on CustomLocation field
UPDATE Tasks 
SET 
    StateId = CASE 
        WHEN CustomLocation LIKE '%Delhi%' OR CustomLocation LIKE '%Connaught%' OR CustomLocation LIKE '%Khan Market%' THEN 1
        WHEN CustomLocation LIKE '%Gurgaon%' OR CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Cyber City%' THEN 2
        WHEN CustomLocation LIKE '%Noida%' OR CustomLocation LIKE '%Sector 18%' THEN 3
        WHEN CustomLocation LIKE '%Faridabad%' OR CustomLocation LIKE '%Industrial%' THEN 4
        ELSE 1
    END,
    CityId = CASE 
        WHEN CustomLocation LIKE '%Delhi%' OR CustomLocation LIKE '%Connaught%' OR CustomLocation LIKE '%Khan Market%' THEN 1
        WHEN CustomLocation LIKE '%Gurgaon%' OR CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Cyber City%' THEN 2
        WHEN CustomLocation LIKE '%Noida%' OR CustomLocation LIKE '%Sector 18%' THEN 3
        WHEN CustomLocation LIKE '%Faridabad%' OR CustomLocation LIKE '%Industrial%' THEN 4
        ELSE 1
    END,
    AreaId = CASE 
        WHEN CustomLocation LIKE '%Connaught%' THEN 1
        WHEN CustomLocation LIKE '%Khan Market%' THEN 2
        WHEN CustomLocation LIKE '%Dwarka%' THEN 3
        WHEN CustomLocation LIKE '%Janakpuri%' THEN 4
        WHEN CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Gurgaon%' THEN 5
        WHEN CustomLocation LIKE '%Cyber City%' THEN 6
        WHEN CustomLocation LIKE '%Sector 18%' OR CustomLocation LIKE '%Noida%' THEN 7
        WHEN CustomLocation LIKE '%Industrial%' OR CustomLocation LIKE '%Faridabad%' THEN 8
        ELSE 1
    END,
    StateName = CASE 
        WHEN CustomLocation LIKE '%Delhi%' OR CustomLocation LIKE '%Connaught%' OR CustomLocation LIKE '%Khan Market%' THEN 'Delhi'
        WHEN CustomLocation LIKE '%Gurgaon%' OR CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Cyber City%' THEN 'Haryana'
        WHEN CustomLocation LIKE '%Noida%' OR CustomLocation LIKE '%Sector 18%' THEN 'Uttar Pradesh'
        WHEN CustomLocation LIKE '%Faridabad%' OR CustomLocation LIKE '%Industrial%' THEN 'Haryana'
        ELSE 'Delhi'
    END,
    CityName = CASE 
        WHEN CustomLocation LIKE '%Delhi%' OR CustomLocation LIKE '%Connaught%' OR CustomLocation LIKE '%Khan Market%' THEN 'Delhi'
        WHEN CustomLocation LIKE '%Gurgaon%' OR CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Cyber City%' THEN 'Gurgaon'
        WHEN CustomLocation LIKE '%Noida%' OR CustomLocation LIKE '%Sector 18%' THEN 'Noida'
        WHEN CustomLocation LIKE '%Faridabad%' OR CustomLocation LIKE '%Industrial%' THEN 'Faridabad'
        ELSE 'Delhi'
    END,
    LocalityName = CASE 
        WHEN CustomLocation LIKE '%Connaught%' THEN 'Connaught Place'
        WHEN CustomLocation LIKE '%Khan Market%' THEN 'Khan Market'
        WHEN CustomLocation LIKE '%Dwarka%' THEN 'Dwarka'
        WHEN CustomLocation LIKE '%Janakpuri%' THEN 'Janakpuri'
        WHEN CustomLocation LIKE '%Sector 29%' THEN 'Sector 29'
        WHEN CustomLocation LIKE '%Cyber City%' THEN 'Cyber City'
        WHEN CustomLocation LIKE '%Sector 18%' THEN 'Sector 18'
        WHEN CustomLocation LIKE '%Industrial%' THEN 'Industrial Area'
        ELSE ISNULL(CustomLocation, 'Connaught Place')
    END,
    PincodeValue = CASE 
        WHEN CustomLocation LIKE '%Connaught%' THEN '110001'
        WHEN CustomLocation LIKE '%Khan Market%' THEN '110003'
        WHEN CustomLocation LIKE '%Dwarka%' THEN '110075'
        WHEN CustomLocation LIKE '%Janakpuri%' THEN '110058'
        WHEN CustomLocation LIKE '%Sector 29%' THEN '122001'
        WHEN CustomLocation LIKE '%Cyber City%' THEN '122002'
        WHEN CustomLocation LIKE '%Sector 18%' THEN '201301'
        WHEN CustomLocation LIKE '%Industrial%' THEN '121001'
        ELSE '110001'
    END
WHERE StateId IS NULL OR CityId IS NULL OR AreaId IS NULL;

-- Update ClientName based on Description
UPDATE Tasks 
SET ClientName = CASE 
    WHEN Description LIKE '%Action Medical%' THEN 'Action Medical Institute'
    WHEN Description LIKE '%TechCorp%' THEN 'TechCorp Solutions Pvt Ltd'
    WHEN Description LIKE '%Faridabad Industries%' THEN 'Faridabad Industries Association'
    WHEN Description LIKE '%Corporate%' THEN 'Corporate Client'
    WHEN Description LIKE '%Pooja%' THEN 'Pooja Paswan'
    WHEN Description LIKE '%Dr. Ajay%' THEN 'Dr. Ajay Kumar'
    ELSE 'Action Medical Institute'
END
WHERE ClientName IS NULL;

-- Update ProjectCode
UPDATE Tasks 
SET ProjectCode = 'AMI-2024-' + RIGHT('000' + CAST(TaskId AS VARCHAR), 3)
WHERE ProjectCode IS NULL;

-- Update EstimatedHours based on Description
UPDATE Tasks 
SET EstimatedHours = CASE 
    WHEN Description LIKE '%market research%' OR Description LIKE '%comprehensive%' THEN 16.00
    WHEN Description LIKE '%client meeting%' OR Description LIKE '%corporate%' THEN 4.00
    WHEN Description LIKE '%patient feedback%' OR Description LIKE '%data collection%' THEN 12.00
    WHEN Description LIKE '%report%' OR Description LIKE '%documentation%' THEN 8.00
    WHEN Description LIKE '%training%' THEN 6.00
    WHEN Description LIKE '%awareness camp%' OR Description LIKE '%event%' THEN 20.00
    WHEN Description LIKE '%field survey%' OR Description LIKE '%industrial%' THEN 14.00
    WHEN Description LIKE '%research%' OR Description LIKE '%analysis%' THEN 15.00
    WHEN Description LIKE '%strategic planning%' THEN 40.00
    WHEN Description LIKE '%campaign management%' THEN 32.00
    WHEN Description LIKE '%business development%' THEN 60.00
    WHEN Description LIKE '%digital marketing%' THEN 25.00
    WHEN Description LIKE '%content creation%' THEN 20.00
    WHEN Description LIKE '%social media%' THEN 30.00
    WHEN Description LIKE '%SEO%' OR Description LIKE '%optimization%' THEN 35.00
    WHEN Description LIKE '%field operations%' THEN 45.00
    WHEN Description LIKE '%sales campaign%' THEN 50.00
    WHEN Description LIKE '%customer relations%' THEN 40.00
    WHEN Description LIKE '%event coordination%' THEN 35.00
    WHEN Description LIKE '%administrative%' THEN 15.00
    WHEN Description LIKE '%training workshop%' THEN 24.00
    WHEN Description LIKE '%meeting%' AND EstimatedHours IS NULL THEN 2.00
    WHEN Description LIKE '%marketing%' AND EstimatedHours IS NULL THEN 3.00
    ELSE 8.00
END
WHERE EstimatedHours IS NULL;

-- Update EmployeeIdNumber
UPDATE Tasks 
SET EmployeeIdNumber = 'EMP' + RIGHT('000' + CAST(EmployeeId AS VARCHAR), 3)
WHERE EmployeeIdNumber IS NULL;

-- Update UserId
UPDATE Tasks 
SET UserId = 2
WHERE UserId IS NULL;

-- Update ConsultantFeedback
UPDATE Tasks 
SET ConsultantFeedback = CASE 
    WHEN Status = 'Completed' THEN 'Task completed successfully. All objectives met within the specified timeframe.'
    WHEN Status = 'In Progress' THEN 'Task is currently in progress. Regular updates will be provided.'
    WHEN Status = 'Not Started' THEN 'Task is scheduled and ready to begin as per the timeline.'
    WHEN Status = 'Postponed' THEN 'Task has been postponed due to external factors. Will be rescheduled soon.'
    WHEN Status = 'Partial Close' THEN 'Task partially completed. Remaining work will be completed in the next phase.'
    ELSE 'Task status updated. Regular monitoring in progress.'
END
WHERE ConsultantFeedback IS NULL;

PRINT 'Comprehensive task data update completed successfully!';
