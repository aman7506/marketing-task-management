USE marketing_db;
GO

-- =============================================
-- SEED DATA SCRIPT
-- =============================================

PRINT 'Starting data seeding...';

-- Insert sample employees
INSERT INTO Employees (Name, Contact, Designation, Email) VALUES
('John Doe', '9876543210', 'Marketing Executive', 'john.doe@actionmedical.com'),
('Jane Smith', '9876543211', 'Marketing Manager', 'jane.smith@actionmedical.com'),
('Mike Johnson', '9876543212', 'Field Executive', 'mike.johnson@actionmedical.com'),
('Sarah Wilson', '9876543213', 'Marketing Coordinator', 'sarah.wilson@actionmedical.com'),
('David Brown', '9876543214', 'Senior Executive', 'david.brown@actionmedical.com');

PRINT 'Employees inserted successfully!';

-- Insert sample locations
INSERT INTO Locations (LocationName, State) VALUES
('Action Medical Institute - Main Branch', 'Delhi'),
('Action Cancer Hospital - Paschim Vihar', 'Delhi'),
('Action Medical Institute - Sector 62', 'Noida'),
('Action Cancer Hospital - Lajpat Nagar', 'Delhi'),
('Action Medical Institute - Ghaziabad', 'Uttar Pradesh'),
('Action Cancer Hospital - Punjabi Bagh', 'Delhi'),
('Action Medical Institute - Faridabad', 'Haryana'),
('Action Cancer Hospital - Dwarka', 'Delhi');

PRINT 'Locations inserted successfully!';

-- Insert sample users
-- Password hash for 'admin123' (you should use proper hashing in production)
INSERT INTO Users (Username, PasswordHash, Role, EmployeeId) VALUES
('admin', 'AQAAAAEAACcQAAAAEK8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqL', 'Admin', NULL),
('john.doe', 'AQAAAAEAACcQAAAAEK8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqL', 'Employee', 1),
('jane.smith', 'AQAAAAEAACcQAAAAEK8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqL', 'Employee', 2),
('mike.johnson', 'AQAAAAEAACcQAAAAEK8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqL', 'Employee', 3),
('sarah.wilson', 'AQAAAAEAACcQAAAAEK8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqLRDGqQVhqxNQoYjd1K8VJJzOzEqL', 'Employee', 4);

PRINT 'Users inserted successfully!';

-- Insert sample tasks
INSERT INTO Tasks (AssignedByUserId, EmployeeId, LocationId, Description, Priority, TaskDate, Deadline, Status) VALUES
(1, 1, 1, 'Conduct marketing survey at main branch', 'High', '2024-01-15', '2024-01-20', 'Not Started'),
(1, 2, 2, 'Organize health awareness camp', 'Medium', '2024-01-16', '2024-01-25', 'In Progress'),
(1, 3, 3, 'Distribute promotional materials', 'Low', '2024-01-17', '2024-01-22', 'Not Started'),
(1, 4, NULL, 'Online marketing campaign setup', 'High', '2024-01-18', '2024-01-30', 'Not Started'),
(1, 1, 4, 'Patient feedback collection', 'Medium', '2024-01-19', '2024-01-28', 'Not Started');

PRINT 'Tasks inserted successfully!';

-- Insert initial task status history
INSERT INTO TaskStatusHistory (TaskId, Status, Remarks, ChangedByUserId) VALUES
(1, 'Not Started', 'Task assigned to John Doe', 1),
(2, 'Not Started', 'Task assigned to Jane Smith', 1),
(2, 'In Progress', 'Started working on health awareness camp', 2),
(3, 'Not Started', 'Task assigned to Mike Johnson', 1),
(4, 'Not Started', 'Task assigned to Sarah Wilson', 1),
(5, 'Not Started', 'Task assigned to John Doe', 1);

PRINT 'Task status history inserted successfully!';

-- Verify data insertion
PRINT 'Verifying data insertion...';

SELECT 'Employees' AS TableName, COUNT(*) AS RecordCount FROM Employees
UNION ALL
SELECT 'Locations', COUNT(*) FROM Locations
UNION ALL
SELECT 'Users', COUNT(*) FROM Users
UNION ALL
SELECT 'Tasks', COUNT(*) FROM Tasks
UNION ALL
SELECT 'TaskStatusHistory', COUNT(*) FROM TaskStatusHistory;

PRINT '=============================================';
PRINT 'SEED DATA INSERTION COMPLETED SUCCESSFULLY!';
PRINT '=============================================';
PRINT 'Sample data has been inserted into all tables.';
PRINT 'You can now test the stored procedures.';
PRINT '=============================================';