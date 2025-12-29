USE marketing_db;
GO

-- Insert default locations for Delhi, Haryana, and Gurgaon
INSERT INTO Locations (LocationName, State) VALUES
-- Delhi Locations
('Connaught Place', 'Delhi'),
('Khan Market', 'Delhi'),
('Lajpat Nagar', 'Delhi'),
('Saket', 'Delhi'),
('Dwarka', 'Delhi'),
('Rohini', 'Delhi'),
('Pitampura', 'Delhi'),
('Janakpuri', 'Delhi'),
('Rajouri Garden', 'Delhi'),
('Hauz Khas', 'Delhi'),

-- Haryana Locations
('Gurgaon', 'Haryana'),
('Faridabad', 'Haryana'),
('Panipat', 'Haryana'),
('Karnal', 'Haryana'),
('Sonipat', 'Haryana'),
('Yamunanagar', 'Haryana'),
('Hisar', 'Haryana'),
('Rohtak', 'Haryana'),
('Bhiwani', 'Haryana'),
('Jind', 'Haryana'),

-- Gurgaon Specific Locations
('Cyber City', 'Haryana'),
('Sohna Road', 'Haryana'),
('Sector 29', 'Haryana'),
('Sector 56', 'Haryana'),
('Sector 23', 'Haryana'),
('Sector 15', 'Haryana'),
('Sector 14', 'Haryana'),
('Sector 7', 'Haryana'),
('Sector 4', 'Haryana'),
('Sector 1', 'Haryana')
GO

-- Insert sample employees
INSERT INTO Employees (Name, Contact, Designation, Email) VALUES
('Rahul Sharma', '9876543210', 'Marketing Executive', 'rahul.sharma@actionmedical.com'),
('Priya Singh', '9876543211', 'Marketing Manager', 'priya.singh@actionmedical.com'),
('Amit Kumar', '9876543212', 'Field Executive', 'amit.kumar@actionmedical.com'),
('Neha Gupta', '9876543213', 'Marketing Coordinator', 'neha.gupta@actionmedical.com'),
('Vikram Malhotra', '9876543214', 'Senior Executive', 'vikram.malhotra@actionmedical.com'),
('Sneha Patel', '9876543215', 'Marketing Assistant', 'sneha.patel@actionmedical.com'),
('Rajesh Verma', '9876543216', 'Field Coordinator', 'rajesh.verma@actionmedical.com'),
('Anjali Kapoor', '9876543217', 'Marketing Specialist', 'anjali.kapoor@actionmedical.com')
GO

-- Insert default users (password: Admin123! and Employee123!)
INSERT INTO Users (Username, PasswordHash, Role, EmployeeId) VALUES
('admin@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Admin', NULL),
('rahul.sharma@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', 1),
('priya.singh@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', 2),
('amit.kumar@actionmedical.com', 'AQAAAAIAAYagAAAAELbXpFJgFbwVzK8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q9X8Q==', 'Employee', 3)
GO 