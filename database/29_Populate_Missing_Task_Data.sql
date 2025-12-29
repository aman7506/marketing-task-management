-- Update Tasks with realistic data to replace NULL values
-- This script populates missing data in the Tasks table

-- Update tasks with missing location data
UPDATE Tasks 
SET 
    StateId = CASE 
        WHEN CustomLocation LIKE '%Delhi%' OR CustomLocation LIKE '%Connaught%' OR CustomLocation LIKE '%Khan Market%' THEN 1
        WHEN CustomLocation LIKE '%Gurgaon%' OR CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Cyber City%' THEN 2
        WHEN CustomLocation LIKE '%Noida%' OR CustomLocation LIKE '%Sector 18%' THEN 3
        WHEN CustomLocation LIKE '%Faridabad%' OR CustomLocation LIKE '%Industrial%' THEN 4
        WHEN CustomLocation LIKE '%Mumbai%' OR CustomLocation LIKE '%Fort%' OR CustomLocation LIKE '%Bandra%' THEN 5
        WHEN CustomLocation LIKE '%Bangalore%' OR CustomLocation LIKE '%Electronic City%' THEN 6
        WHEN CustomLocation LIKE '%Chennai%' OR CustomLocation LIKE '%T Nagar%' THEN 7
        WHEN CustomLocation LIKE '%Pune%' OR CustomLocation LIKE '%Koregaon%' THEN 8
        WHEN CustomLocation LIKE '%Ahmedabad%' OR CustomLocation LIKE '%Satellite%' THEN 9
        WHEN CustomLocation LIKE '%Ghaziabad%' OR CustomLocation LIKE '%Raj Nagar%' THEN 10
        ELSE 1 -- Default to Delhi
    END,
    CityId = CASE 
        WHEN CustomLocation LIKE '%Delhi%' OR CustomLocation LIKE '%Connaught%' OR CustomLocation LIKE '%Khan Market%' THEN 1
        WHEN CustomLocation LIKE '%Gurgaon%' OR CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Cyber City%' THEN 2
        WHEN CustomLocation LIKE '%Noida%' OR CustomLocation LIKE '%Sector 18%' THEN 3
        WHEN CustomLocation LIKE '%Faridabad%' OR CustomLocation LIKE '%Industrial%' THEN 4
        WHEN CustomLocation LIKE '%Mumbai%' OR CustomLocation LIKE '%Fort%' OR CustomLocation LIKE '%Bandra%' THEN 5
        WHEN CustomLocation LIKE '%Bangalore%' OR CustomLocation LIKE '%Electronic City%' THEN 6
        WHEN CustomLocation LIKE '%Chennai%' OR CustomLocation LIKE '%T Nagar%' THEN 7
        WHEN CustomLocation LIKE '%Pune%' OR CustomLocation LIKE '%Koregaon%' THEN 8
        WHEN CustomLocation LIKE '%Ahmedabad%' OR CustomLocation LIKE '%Satellite%' THEN 9
        WHEN CustomLocation LIKE '%Ghaziabad%' OR CustomLocation LIKE '%Raj Nagar%' THEN 10
        ELSE 1 -- Default to Delhi
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
        WHEN CustomLocation LIKE '%Fort%' OR CustomLocation LIKE '%Mumbai%' THEN 9
        WHEN CustomLocation LIKE '%Electronic City%' OR CustomLocation LIKE '%Bangalore%' THEN 10
        ELSE 1 -- Default to Connaught Place
    END,
    AreaIds = CASE 
        WHEN CustomLocation LIKE '%Connaught%' THEN '1'
        WHEN CustomLocation LIKE '%Khan Market%' THEN '2'
        WHEN CustomLocation LIKE '%Dwarka%' THEN '3'
        WHEN CustomLocation LIKE '%Janakpuri%' THEN '4'
        WHEN CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Gurgaon%' THEN '5'
        WHEN CustomLocation LIKE '%Cyber City%' THEN '6'
        WHEN CustomLocation LIKE '%Sector 18%' OR CustomLocation LIKE '%Noida%' THEN '7'
        WHEN CustomLocation LIKE '%Industrial%' OR CustomLocation LIKE '%Faridabad%' THEN '8'
        WHEN CustomLocation LIKE '%Fort%' OR CustomLocation LIKE '%Mumbai%' THEN '9'
        WHEN CustomLocation LIKE '%Electronic City%' OR CustomLocation LIKE '%Bangalore%' THEN '10'
        ELSE '1' -- Default to Connaught Place
    END,
    AreaNames = CASE 
        WHEN CustomLocation LIKE '%Connaught%' THEN 'Connaught Place'
        WHEN CustomLocation LIKE '%Khan Market%' THEN 'Khan Market'
        WHEN CustomLocation LIKE '%Dwarka%' THEN 'Dwarka'
        WHEN CustomLocation LIKE '%Janakpuri%' THEN 'Janakpuri'
        WHEN CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Gurgaon%' THEN 'Sector 29'
        WHEN CustomLocation LIKE '%Cyber City%' THEN 'Cyber City'
        WHEN CustomLocation LIKE '%Sector 18%' OR CustomLocation LIKE '%Noida%' THEN 'Sector 18'
        WHEN CustomLocation LIKE '%Industrial%' OR CustomLocation LIKE '%Faridabad%' THEN 'Industrial Area'
        WHEN CustomLocation LIKE '%Fort%' OR CustomLocation LIKE '%Mumbai%' THEN 'Fort'
        WHEN CustomLocation LIKE '%Electronic City%' OR CustomLocation LIKE '%Bangalore%' THEN 'Electronic City'
        ELSE 'Connaught Place' -- Default
    END,
    CityName = CASE 
        WHEN CustomLocation LIKE '%Delhi%' OR CustomLocation LIKE '%Connaught%' OR CustomLocation LIKE '%Khan Market%' THEN 'Delhi'
        WHEN CustomLocation LIKE '%Gurgaon%' OR CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Cyber City%' THEN 'Gurgaon'
        WHEN CustomLocation LIKE '%Noida%' OR CustomLocation LIKE '%Sector 18%' THEN 'Noida'
        WHEN CustomLocation LIKE '%Faridabad%' OR CustomLocation LIKE '%Industrial%' THEN 'Faridabad'
        WHEN CustomLocation LIKE '%Mumbai%' OR CustomLocation LIKE '%Fort%' OR CustomLocation LIKE '%Bandra%' THEN 'Mumbai'
        WHEN CustomLocation LIKE '%Bangalore%' OR CustomLocation LIKE '%Electronic City%' THEN 'Bangalore'
        WHEN CustomLocation LIKE '%Chennai%' OR CustomLocation LIKE '%T Nagar%' THEN 'Chennai'
        WHEN CustomLocation LIKE '%Pune%' OR CustomLocation LIKE '%Koregaon%' THEN 'Pune'
        WHEN CustomLocation LIKE '%Ahmedabad%' OR CustomLocation LIKE '%Satellite%' THEN 'Ahmedabad'
        WHEN CustomLocation LIKE '%Ghaziabad%' OR CustomLocation LIKE '%Raj Nagar%' THEN 'Ghaziabad'
        ELSE 'Delhi' -- Default
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
        WHEN CustomLocation LIKE '%Fort%' THEN 'Fort'
        WHEN CustomLocation LIKE '%Electronic City%' THEN 'Electronic City'
        ELSE ISNULL(CustomLocation, 'Connaught Place') -- Use custom location or default
    END,
    PincodeId = CASE 
        WHEN CustomLocation LIKE '%Connaught%' THEN 161
        WHEN CustomLocation LIKE '%Khan Market%' THEN 162
        WHEN CustomLocation LIKE '%Dwarka%' THEN 163
        WHEN CustomLocation LIKE '%Janakpuri%' THEN 164
        WHEN CustomLocation LIKE '%Sector 29%' THEN 165
        WHEN CustomLocation LIKE '%Cyber City%' THEN 166
        WHEN CustomLocation LIKE '%Sector 18%' THEN 167
        WHEN CustomLocation LIKE '%Industrial%' THEN 168
        WHEN CustomLocation LIKE '%Fort%' THEN 169
        WHEN CustomLocation LIKE '%Electronic City%' THEN 170
        ELSE 161 -- Default to Connaught Place pincode
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
        WHEN CustomLocation LIKE '%Fort%' THEN '400001'
        WHEN CustomLocation LIKE '%Electronic City%' THEN '560100'
        ELSE '110001' -- Default to Connaught Place pincode
    END,
    StateName = CASE 
        WHEN CustomLocation LIKE '%Delhi%' OR CustomLocation LIKE '%Connaught%' OR CustomLocation LIKE '%Khan Market%' THEN 'Delhi'
        WHEN CustomLocation LIKE '%Gurgaon%' OR CustomLocation LIKE '%Sector 29%' OR CustomLocation LIKE '%Cyber City%' THEN 'Haryana'
        WHEN CustomLocation LIKE '%Noida%' OR CustomLocation LIKE '%Sector 18%' THEN 'Uttar Pradesh'
        WHEN CustomLocation LIKE '%Faridabad%' OR CustomLocation LIKE '%Industrial%' THEN 'Haryana'
        WHEN CustomLocation LIKE '%Mumbai%' OR CustomLocation LIKE '%Fort%' OR CustomLocation LIKE '%Bandra%' THEN 'Maharashtra'
        WHEN CustomLocation LIKE '%Bangalore%' OR CustomLocation LIKE '%Electronic City%' THEN 'Karnataka'
        WHEN CustomLocation LIKE '%Chennai%' OR CustomLocation LIKE '%T Nagar%' THEN 'Tamil Nadu'
        WHEN CustomLocation LIKE '%Pune%' OR CustomLocation LIKE '%Koregaon%' THEN 'Maharashtra'
        WHEN CustomLocation LIKE '%Ahmedabad%' OR CustomLocation LIKE '%Satellite%' THEN 'Gujarat'
        WHEN CustomLocation LIKE '%Ghaziabad%' OR CustomLocation LIKE '%Raj Nagar%' THEN 'Uttar Pradesh'
        ELSE 'Delhi' -- Default
    END,
    UserId = CASE 
        WHEN AssignedByUserId = 2 THEN 2
        ELSE 2 -- Default to admin user
    END,
    ConsultantFeedback = CASE 
        WHEN ConsultantFeedback IS NULL THEN 'Task completed successfully. All objectives met within the specified timeframe.'
        ELSE ConsultantFeedback
    END
WHERE StateId IS NULL OR CityId IS NULL OR AreaId IS NULL OR PincodeId IS NULL;

-- Update EmployeeIdNumber for tasks that have NULL values
UPDATE Tasks 
SET EmployeeIdNumber = CASE 
    WHEN EmployeeId = 2 THEN 'EMP001'
    WHEN EmployeeId = 4 THEN 'EMP002'
    WHEN EmployeeId = 5 THEN 'EMP003'
    WHEN EmployeeId = 6 THEN 'EMP004'
    WHEN EmployeeId = 7 THEN 'EMP005'
    WHEN EmployeeId = 8 THEN 'EMP006'
    WHEN EmployeeId = 9 THEN 'EMP007'
    WHEN EmployeeId = 10 THEN 'EMP008'
    WHEN EmployeeId = 11 THEN 'EMP009'
    WHEN EmployeeId = 12 THEN 'EMP010'
    WHEN EmployeeId = 13 THEN 'EMP011'
    WHEN EmployeeId = 14 THEN 'EMP012'
    WHEN EmployeeId = 15 THEN 'EMP013'
    WHEN EmployeeId = 16 THEN 'EMP014'
    WHEN EmployeeId = 17 THEN 'EMP015'
    WHEN EmployeeId = 18 THEN 'EMP016'
    ELSE 'EMP' + RIGHT('000' + CAST(EmployeeId AS VARCHAR), 3)
END
WHERE EmployeeIdNumber IS NULL;

-- Update ClientName for tasks that have NULL values
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

-- Update ProjectCode for tasks that have NULL values
UPDATE Tasks 
SET ProjectCode = CASE 
    WHEN TaskId BETWEEN 2 AND 15 THEN 'AMI-2024-' + RIGHT('000' + CAST(TaskId AS VARCHAR), 3)
    WHEN TaskId BETWEEN 26 AND 55 THEN 'AMI-2024-' + RIGHT('000' + CAST(TaskId AS VARCHAR), 3)
    WHEN TaskId BETWEEN 56 AND 59 THEN 'MKT-' + RIGHT('000' + CAST(TaskId AS VARCHAR), 3)
    ELSE 'AMI-2024-' + RIGHT('000' + CAST(TaskId AS VARCHAR), 3)
END
WHERE ProjectCode IS NULL;

-- Update EstimatedHours for tasks that have NULL values
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
    WHEN Description LIKE '%meeting%' THEN 2.00
    WHEN Description LIKE '%marketing%' THEN 3.00
    ELSE 8.00 -- Default
END
WHERE EstimatedHours IS NULL;

PRINT 'Task data population completed successfully!';
PRINT 'Updated ' + CAST(@@ROWCOUNT AS VARCHAR) + ' task records with realistic data.';
