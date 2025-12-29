-- =============================================
-- Author: Marketing Form System
-- Create date: 2024-01-15
-- Description: Stored Procedure to save marketing campaign form data
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

-- =============================================
-- Create supporting tables if they don't exist
-- =============================================

-- MarketingCampaigns table
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
END
GO

-- CampaignTaskTypes junction table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='CampaignTaskTypes' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[CampaignTaskTypes] (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [CampaignId] INT NOT NULL,
        [TaskTypeId] INT NOT NULL,
        [CreatedAt] DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (CampaignId) REFERENCES MarketingCampaigns(CampaignId) ON DELETE CASCADE
    );
END
GO

-- TaskTypes lookup table
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
END
GO

-- States lookup table
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
END
GO

-- Cities lookup table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Cities' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Cities] (
        [CityId] INT IDENTITY(1,1) PRIMARY KEY,
        [CityName] NVARCHAR(100) NOT NULL,
        [StateId] INT NOT NULL,
        [IsActive] BIT DEFAULT 1,
        FOREIGN KEY (StateId) REFERENCES States(StateId)
    );
END
GO

-- ErrorLogs table for error tracking
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
END
GO

-- =============================================
-- Example usage of the stored procedure
-- =============================================

/*
DECLARE @CampaignId INT, @Success BIT, @Message NVARCHAR(500);

EXEC sp_save_marketing_campaign
    @CampaignManager = 'Dr. Priya Sharma',
    @EmployeeCode = 'EMP2024001',
    @TaskDescription = 'Digital marketing campaign for Action Medical Institute',
    @TaskDate = '2024-01-15',
    @Deadline = '2024-02-15',
    @Priority = 'High',
    @IsUrgent = 1,
    @StateId = 29,
    @CityId = 1,
    @Locality = 'Connaught Place',
    @Pincode = '110001',
    @ClientName = 'Action Medical Institute',
    @ProjectCode = 'MKT-2024-001',
    @ConsultantName = 'Dr. Rajesh Kumar',
    @CampaignCode = 'CAMP-2024-001',
    @EstimatedHours = 60.00,
    @ExpectedReach = 25000,
    @ConversionGoal = '8%',
    @KPIs = 'Increase website traffic by 40%',
    @MarketingMaterials = 'Brochures, Social media graphics',
    @ApprovalRequired = 1,
    @ApprovalContact = 'approval@actionmedical.com',
    @BudgetCode = 'BUD-2024-MKT',
    @AdditionalNotes = 'Focus on digital channels',
    @ConsultantFeedback = 'Excellent campaign strategy',
    @SelectedTaskTypes = '[1,2,3,4]',
    @CampaignId = @CampaignId OUTPUT,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

SELECT @CampaignId, @Success, @Message;
*/
