-- =============================================
-- Setup script for marketing_db database
-- Server: 172.1.3.201
-- Database: marketing_db
-- =============================================

USE [marketing_db]
GO

-- =============================================
-- Create MarketingCampaigns table
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='MarketingCampaigns' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[MarketingCampaigns] (
        [CampaignId] INT IDENTITY(1,1) PRIMARY KEY,
        [CampaignManager] NVARCHAR(100) NOT NULL,
        [EmployeeCode] NVARCHAR(50),
        [TaskDescription] NVARCHAR(MAX) NOT NULL,
        [TaskDate] DATE NOT NULL,
        [Deadline] DATE NOT NULL,
        [Priority] NVARCHAR(20) NOT NULL,
        [IsUrgent] BIT DEFAULT 0,
        [StateId] INT,
        [CityId] INT,
        [Locality] NVARCHAR(100),
        [Pincode] NVARCHAR(10),
        [ClientName] NVARCHAR(100),
        [ProjectCode] NVARCHAR(50),
        [ConsultantName] NVARCHAR(100),
        [CampaignCode] NVARCHAR(50),
        [EstimatedHours] DECIMAL(10,2),
        [ExpectedReach] INT,
        [ConversionGoal] NVARCHAR(20),
        [KPIs] NVARCHAR(MAX),
        [MarketingMaterials] NVARCHAR(MAX),
        [ApprovalRequired] BIT DEFAULT 0,
        [ApprovalContact] NVARCHAR(100),
        [BudgetCode] NVARCHAR(50),
        [AdditionalNotes] NVARCHAR(MAX),
        [ConsultantFeedback] NVARCHAR(MAX),
        [Status] NVARCHAR(20) DEFAULT 'Active',
        [CreatedAt] DATETIME DEFAULT GETDATE(),
        [UpdatedAt] DATETIME DEFAULT GETDATE()
    );
    PRINT 'MarketingCampaigns table created successfully';
END
ELSE
BEGIN
    PRINT 'MarketingCampaigns table already exists';
END
GO

-- =============================================
-- Create CampaignTaskTypes junction table
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='CampaignTaskTypes' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[CampaignTaskTypes] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [CampaignId] INT NOT NULL,
        [TaskTypeId] INT NOT NULL,
        [CreatedAt] DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (CampaignId) REFERENCES MarketingCampaigns(CampaignId) ON DELETE CASCADE
    );
    PRINT 'CampaignTaskTypes table created successfully';
END
ELSE
BEGIN
    PRINT 'CampaignTaskTypes table already exists';
END
GO

-- =============================================
-- Create TaskTypes lookup table
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='TaskTypes' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[TaskTypes] (
        [TaskTypeId] INT IDENTITY(1,1) PRIMARY KEY,
        [TypeName] NVARCHAR(100) NOT NULL,
        [Description] NVARCHAR(500),
        [IsActive] BIT DEFAULT 1,
        [CreatedAt] DATETIME DEFAULT GETDATE()
    );
    
    -- Insert default task types
    INSERT INTO TaskTypes (TypeName, Description) VALUES
    ('Digital Marketing', 'Digital marketing activities'),
    ('Social Media', 'Social media campaigns'),
    ('Content Creation', 'Content creation and management'),
    ('Email Marketing', 'Email marketing campaigns'),
    ('Event Marketing', 'Event planning and marketing'),
    ('Print Media', 'Print media campaigns'),
    ('Radio/TV', 'Radio and TV advertisements'),
    ('Outdoor Advertising', 'Billboards and outdoor ads');
    
    PRINT 'TaskTypes table created and populated successfully';
END
ELSE
BEGIN
    PRINT 'TaskTypes table already exists';
END
GO

-- =============================================
-- Create States lookup table
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='States' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[States] (
        [StateId] INT IDENTITY(1,1) PRIMARY KEY,
        [StateName] NVARCHAR(100) NOT NULL,
        [StateCode] NVARCHAR(10),
        [IsActive] BIT DEFAULT 1
    );
    
    -- Insert Indian states
    INSERT INTO States (StateName, StateCode) VALUES
    ('Andhra Pradesh', 'AP'),
    ('Arunachal Pradesh', 'AR'),
    ('Assam', 'AS'),
    ('Bihar', 'BR'),
    ('Chhattisgarh', 'CG'),
    ('Goa', 'GA'),
    ('Gujarat', 'GJ'),
    ('Haryana', 'HR'),
    ('Himachal Pradesh', 'HP'),
    ('Jharkhand', 'JH'),
    ('Karnataka', 'KA'),
    ('Kerala', 'KL'),
    ('Madhya Pradesh', 'MP'),
    ('Maharashtra', 'MH'),
    ('Manipur', 'MN'),
    ('Meghalaya', 'ML'),
    ('Mizoram', 'MZ'),
    ('Nagaland', 'NL'),
    ('Odisha', 'OR'),
    ('Punjab', 'PB'),
    ('Rajasthan', 'RJ'),
    ('Sikkim', 'SK'),
    ('Tamil Nadu', 'TN'),
    ('Telangana', 'TG'),
    ('Tripura', 'TR'),
    ('Uttar Pradesh', 'UP'),
    ('Uttarakhand', 'UK'),
    ('West Bengal', 'WB'),
    ('Delhi', 'DL'),
    ('Jammu and Kashmir', 'JK'),
    ('Ladakh', 'LA'),
    ('Chandigarh', 'CH'),
    ('Dadra and Nagar Haveli and Daman and Diu', 'DN'),
    ('Lakshadweep', 'LD'),
    ('Puducherry', 'PY'),
    ('Andaman and Nicobar Islands', 'AN');
    
    PRINT 'States table created and populated successfully';
END
ELSE
BEGIN
    PRINT 'States table already exists';
END
GO

-- =============================================
-- Create Cities lookup table
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Cities' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Cities] (
        [CityId] INT IDENTITY(1,1) PRIMARY KEY,
        [CityName] NVARCHAR(100) NOT NULL,
        [StateId] INT NOT NULL,
        [IsActive] BIT DEFAULT 1,
        FOREIGN KEY (StateId) REFERENCES States(StateId)
    );
    
    -- Insert some major cities
    INSERT INTO Cities (CityName, StateId) VALUES
    -- Delhi cities
    ('Delhi', 29),
    -- Maharashtra cities
    ('Mumbai', 14),
    ('Pune', 14),
    ('Nagpur', 14),
    ('Thane', 14),
    ('Nashik', 14),
    -- Karnataka cities
    ('Bangalore', 11),
    ('Mysore', 11),
    ('Hubli', 11),
    ('Mangalore', 11),
    -- Tamil Nadu cities
    ('Chennai', 23),
    ('Coimbatore', 23),
    ('Madurai', 23),
    ('Tiruchirappalli', 23),
    -- Gujarat cities
    ('Ahmedabad', 7),
    ('Surat', 7),
    ('Vadodara', 7),
    ('Rajkot', 7),
    -- Andhra Pradesh cities
    ('Hyderabad', 1),
    ('Visakhapatnam', 1),
    ('Vijayawada', 1),
    ('Tirupati', 1);
    
    PRINT 'Cities table created and populated successfully';
END
ELSE
BEGIN
    PRINT 'Cities table already exists';
END
GO

-- =============================================
-- Create ErrorLogs table for error tracking
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ErrorLogs' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[ErrorLogs] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [ErrorMessage] NVARCHAR(MAX),
        [ErrorNumber] INT,
        [ErrorSeverity] INT,
        [ErrorState] INT,
        [ErrorProcedure] NVARCHAR(200),
        [ErrorLine] INT,
        [CreatedAt] DATETIME DEFAULT GETDATE()
    );
    PRINT 'ErrorLogs table created successfully';
END
ELSE
BEGIN
    PRINT 'ErrorLogs table already exists';
END
GO

-- =============================================
-- Create the main stored procedure
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[sp_save_marketing_campaign]
    -- Campaign Information Parameters
    @CampaignManager NVARCHAR(100),
    @EmployeeCode NVARCHAR(50),
    @TaskDescription NVARCHAR(MAX),
    @TaskDate DATE,
    @Deadline DATE,
    @Priority NVARCHAR(20),
    @IsUrgent BIT = 0,
    
    -- Location Information Parameters
    @StateId INT,
    @CityId INT,
    @Locality NVARCHAR(100),
    @Pincode NVARCHAR(10),
    
    -- Project & Client Information Parameters
    @ClientName NVARCHAR(100),
    @ProjectCode NVARCHAR(50),
    @ConsultantName NVARCHAR(100),
    @CampaignCode NVARCHAR(50),
    
    -- Campaign Details Parameters
    @EstimatedHours DECIMAL(10,2),
    @ExpectedReach INT,
    @ConversionGoal NVARCHAR(20),
    @KPIs NVARCHAR(MAX),
    @MarketingMaterials NVARCHAR(MAX),
    @ApprovalRequired BIT = 0,
    @ApprovalContact NVARCHAR(100),
    @BudgetCode NVARCHAR(50),
    @AdditionalNotes NVARCHAR(MAX),
    @ConsultantFeedback NVARCHAR(MAX),
    
    -- Task Types (JSON array of task type IDs)
    @SelectedTaskTypes NVARCHAR(MAX),
    
    -- Output Parameters
    @CampaignId INT OUTPUT,
    @Success BIT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Declare variables
        DECLARE @NewCampaignId INT;
        DECLARE @CurrentDateTime DATETIME = GETDATE();
        
        -- Insert into MarketingCampaigns table
        INSERT INTO MarketingCampaigns (
            CampaignManager,
            EmployeeCode,
            TaskDescription,
            TaskDate,
            Deadline,
            Priority,
            IsUrgent,
            StateId,
            CityId,
            Locality,
            Pincode,
            ClientName,
            ProjectCode,
            ConsultantName,
            CampaignCode,
            EstimatedHours,
            ExpectedReach,
            ConversionGoal,
            KPIs,
            MarketingMaterials,
            ApprovalRequired,
            ApprovalContact,
            BudgetCode,
            AdditionalNotes,
            ConsultantFeedback,
            Status,
            CreatedAt,
            UpdatedAt
        )
        VALUES (
            @CampaignManager,
            @EmployeeCode,
            @TaskDescription,
            @TaskDate,
            @Deadline,
            @Priority,
            @IsUrgent,
            @StateId,
            @CityId,
            @Locality,
            @Pincode,
            @ClientName,
            @ProjectCode,
            @ConsultantName,
            @CampaignCode,
            @EstimatedHours,
            @ExpectedReach,
            @ConversionGoal,
            @KPIs,
            @MarketingMaterials,
            @ApprovalRequired,
            @ApprovalContact,
            @BudgetCode,
            @AdditionalNotes,
            @ConsultantFeedback,
            'Active',
            @CurrentDateTime,
            @CurrentDateTime
        );
        
        -- Get the newly inserted Campaign ID
        SET @NewCampaignId = SCOPE_IDENTITY();
        SET @CampaignId = @NewCampaignId;
        
        -- Insert selected task types into junction table
        IF @SelectedTaskTypes IS NOT NULL AND @SelectedTaskTypes != ''
        BEGIN
            -- Parse JSON and insert task types
            INSERT INTO CampaignTaskTypes (CampaignId, TaskTypeId, CreatedAt)
            SELECT 
                @NewCampaignId,
                CAST(value AS INT),
                @CurrentDateTime
            FROM OPENJSON(@SelectedTaskTypes)
            WHERE CAST(value AS INT) IS NOT NULL;
        END
        
        -- Set success parameters
        SET @Success = 1;
        SET @Message = 'Marketing campaign saved successfully with ID: ' + CAST(@NewCampaignId AS NVARCHAR(10));
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        -- Rollback transaction on error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Set error parameters
        SET @Success = 0;
        SET @Message = 'Error saving marketing campaign: ' + ERROR_MESSAGE();
        SET @CampaignId = 0;
        
        -- Log error details
        INSERT INTO ErrorLogs (
            ErrorMessage,
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorLine,
            CreatedAt
        )
        VALUES (
            ERROR_MESSAGE(),
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            GETDATE()
        );
        
    END CATCH
END
GO

PRINT 'Stored procedure sp_save_marketing_campaign created successfully';
GO

-- =============================================
-- Test the setup
-- =============================================
PRINT 'Testing database setup...';

-- Check if tables exist
SELECT 
    'MarketingCampaigns' as TableName,
    COUNT(*) as RecordCount
FROM MarketingCampaigns
UNION ALL
SELECT 
    'TaskTypes' as TableName,
    COUNT(*) as RecordCount
FROM TaskTypes
UNION ALL
SELECT 
    'States' as TableName,
    COUNT(*) as RecordCount
FROM States
UNION ALL
SELECT 
    'Cities' as TableName,
    COUNT(*) as RecordCount
FROM Cities
UNION ALL
SELECT 
    'CampaignTaskTypes' as TableName,
    COUNT(*) as RecordCount
FROM CampaignTaskTypes
UNION ALL
SELECT 
    'ErrorLogs' as TableName,
    COUNT(*) as RecordCount
FROM ErrorLogs;

PRINT 'Database setup completed successfully!';
PRINT 'You can now run your backend application.';
GO
