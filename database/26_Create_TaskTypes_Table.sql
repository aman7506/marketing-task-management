-- =============================================
-- CREATE TaskTypes TABLE
-- =============================================

USE marketing_db;
GO

-- Create TaskTypes table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TaskTypes')
BEGIN
    CREATE TABLE TaskTypes (
        TaskTypeId INT PRIMARY KEY IDENTITY(1,1),
        TypeName NVARCHAR(50) NOT NULL,
        Description NVARCHAR(200),
        IsActive BIT DEFAULT 1,
        CreatedAt DATETIME DEFAULT GETDATE()
    );
    PRINT 'Created TaskTypes table';
END

-- Insert sample data if table is empty
IF NOT EXISTS (SELECT TOP 1 * FROM TaskTypes)
BEGIN
    INSERT INTO TaskTypes (TypeName, Description, IsActive) VALUES
    ('General', 'General marketing tasks', 1),
    ('Field Work', 'Field marketing activities', 1),
    ('Digital Marketing', 'Online marketing campaigns', 1),
    ('Event Management', 'Event planning and execution', 1),
    ('Content Creation', 'Content development and creation', 1),
    ('Market Research', 'Market analysis and research', 1),
    ('Client Meeting', 'Client meetings and presentations', 1),
    ('Training', 'Training and development activities', 1);
    PRINT 'Inserted sample TaskTypes data';
END

GO
