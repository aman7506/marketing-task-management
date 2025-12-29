
USE master;
GO

-- Create database if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'marketing_db')
BEGIN
    CREATE DATABASE marketing_db;
END
GO

USE marketing_db;
GO

-- Create Users table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        UserId INT PRIMARY KEY IDENTITY(1,1),
        Username NVARCHAR(50) UNIQUE NOT NULL,
        PasswordHash NVARCHAR(256) NOT NULL,
        Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'Employee')),
        EmployeeId INT NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    );
END

-- Create Employees table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employees')
BEGIN
    CREATE TABLE Employees (
        EmployeeId INT PRIMARY KEY IDENTITY(1,1),
        Name NVARCHAR(100) NOT NULL,
        Contact NVARCHAR(50) NOT NULL,
        Designation NVARCHAR(50) NOT NULL,
        Email NVARCHAR(100) UNIQUE NOT NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    );
END

-- Create Locations table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Locations')
BEGIN
    CREATE TABLE Locations (
        LocationId INT PRIMARY KEY IDENTITY(1,1),
        LocationName NVARCHAR(100) NOT NULL UNIQUE,
        State NVARCHAR(50) NOT NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        IsActive BIT DEFAULT 1
    );
END

-- Create Tasks table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Tasks')
BEGIN
    CREATE TABLE Tasks (
        TaskId INT PRIMARY KEY IDENTITY(1,1),
        AssignedByUserId INT NOT NULL,
        EmployeeId INT NOT NULL,
        LocationId INT NULL,
        CustomLocation NVARCHAR(100) NULL,
        Description NVARCHAR(500) NOT NULL,
        Priority NVARCHAR(10) NOT NULL CHECK (Priority IN ('Low', 'Medium', 'High')),
        TaskDate DATE NOT NULL,
        Deadline DATE NOT NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Not Started' CHECK (Status IN ('Not Started', 'In Progress', 'Completed', 'Postponed')),
        CreatedAt DATETIME DEFAULT GETDATE(),
        UpdatedAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (AssignedByUserId) REFERENCES Users(UserId),
        FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
        FOREIGN KEY (LocationId) REFERENCES Locations(LocationId)
    );
END

-- Create TaskStatusHistory table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TaskStatusHistory')
BEGIN
    CREATE TABLE TaskStatusHistory (
        HistoryId INT PRIMARY KEY IDENTITY(1,1),
        TaskId INT NOT NULL,
        Status NVARCHAR(20) NOT NULL,
        Remarks NVARCHAR(500) NULL,
        ChangedByUserId INT NOT NULL,
        ChangedAt DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (TaskId) REFERENCES Tasks(TaskId),
        FOREIGN KEY (ChangedByUserId) REFERENCES Users(UserId)
    );
END

-- Add foreign key constraint for Users.EmployeeId
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Users_Employees')
BEGIN
    ALTER TABLE Users ADD CONSTRAINT FK_Users_Employees 
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId);
END
GO 