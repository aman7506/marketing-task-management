-- =============================================
-- COMPLETE FIXED sp_InsertTask WITH ALL COLUMNS
-- This version works with the updated Tasks table that has all required columns
-- =============================================

USE marketing_db;
GO

-- First, add missing columns if they don't exist
PRINT 'Ensuring all required columns exist...';

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'ConsultantName')
    ALTER TABLE Tasks ADD ConsultantName NVARCHAR(200) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'CampCode')
    ALTER TABLE Tasks ADD CampCode NVARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'EmployeeCode')
    ALTER TABLE Tasks ADD EmployeeCode NVARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'ExpectedReach')
    ALTER TABLE Tasks ADD ExpectedReach NVARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'ConversionGoal')
    ALTER TABLE Tasks ADD ConversionGoal NVARCHAR(100) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'Kpis')
    ALTER TABLE Tasks ADD Kpis NVARCHAR(500) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'MarketingMaterials')
    ALTER TABLE Tasks ADD MarketingMaterials NVARCHAR(500) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'ApprovalRequired')
    ALTER TABLE Tasks ADD ApprovalRequired BIT DEFAULT 0;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'ApprovalContact')
    ALTER TABLE Tasks ADD ApprovalContact NVARCHAR(200) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'BudgetCode')
    ALTER TABLE Tasks ADD BudgetCode NVARCHAR(50) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'DepartmentCode')
    ALTER TABLE Tasks ADD DepartmentCode NVARCHAR(20) NULL;

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Tasks') AND name = 'ConsultantFeedback')
    ALTER TABLE Tasks ADD ConsultantFeedback NVARCHAR(1000) NULL;

PRINT 'All columns verified/added successfully!';
GO

-- Drop existing procedure if it exists
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_InsertTask')
BEGIN
    DROP PROCEDURE sp_InsertTask;
    PRINT 'Dropped existing sp_InsertTask procedure';
END
GO

CREATE PROCEDURE sp_InsertTask
    -- User and Employee
    @AssignedByUserId INT,
    @EmployeeId INT,
    
    -- Location fields
    @LocationId INT = NULL,
    @CustomLocation NVARCHAR(100) = NULL,
    @Pincode NVARCHAR(10) = NULL,
    @LocalityName NVARCHAR(200) = NULL,
    @State NVARCHAR(100) = NULL,
    @City NVARCHAR(100) = NULL,
    @Area NVARCHAR(200) = NULL,
    @StateId INT = NULL,
    @CityId INT = NULL,
    @AreaId INT = NULL,
    @PincodeId INT = NULL,
    
    -- Task core fields
    @Description NVARCHAR(500),
    @Priority NVARCHAR(10),
    @TaskDate DATE,
    @Deadline DATE,
    @Status NVARCHAR(20) = 'Not Started',
    
    -- Task type and department
    @TaskType NVARCHAR(50) = 'General',
    @Department NVARCHAR(100) = 'Marketing',
    @TaskCategory NVARCHAR(50) = 'Field Work',
    
    -- Client and project info
    @ClientName NVARCHAR(200) = NULL,
    @ProjectCode NVARCHAR(100) = NULL,
    @EstimatedHours DECIMAL(5,2) = NULL,
    
    -- Additional fields
    @AdditionalNotes NVARCHAR(1000) = NULL,
    @IsUrgent BIT = 0,
    
    -- Marketing specific fields
    @ExpectedReach NVARCHAR(100) = NULL,
    @ConversionGoal NVARCHAR(100) = NULL,
    @Kpis NVARCHAR(500) = NULL,
    @MarketingMaterials NVARCHAR(500) = NULL,
    @ApprovalRequired BIT = 0,
    @ApprovalContact NVARCHAR(200) = NULL,
    @BudgetCode NVARCHAR(50) = NULL,
    @DepartmentCode NVARCHAR(20) = NULL,
    
    -- Additional consultant fields
    @ConsultantName NVARCHAR(200) = NULL,
    @ConsultantFeedback NVARCHAR(1000) = NULL,
    @CampCode NVARCHAR(50) = NULL,
    @EmployeeCode NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TaskId INT;
    DECLARE @UserId INT = 2; -- Default user ID for system operations
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insert into Tasks table with ALL columns
        INSERT INTO Tasks (
            AssignedByUserId,
            EmployeeId,
            LocationId,
            CustomLocation,
            Description,
            Priority,
            TaskDate,
            Deadline,
            Status,
            TaskType,
            Department,
            ClientName,
            ProjectCode,
            EstimatedHours,
            TaskCategory,
            AdditionalNotes,
            IsUrgent,
            CreatedAt,
            UpdatedAt,
            UserId,
            -- Location hierarchy fields
            StateName,
            CityName,
            LocalityName,
            PincodeValue,
            StateId,
            CityId,
            AreaId,
            PincodeId,
            -- Marketing specific fields
            ExpectedReach,
            ConversionGoal,
            Kpis,
            MarketingMaterials,
            ApprovalRequired,
            ApprovalContact,
            BudgetCode,
            DepartmentCode,
            -- Additional fields
            ConsultantName,
            ConsultantFeedback,
            CampCode,
            EmployeeCode
        )
        VALUES (
            @AssignedByUserId,
            @EmployeeId,
            @LocationId,
            @CustomLocation,
            @Description,
            @Priority,
            @TaskDate,
            @Deadline,
            @Status,
            @TaskType,
            @Department,
            @ClientName,
            @ProjectCode,
            @EstimatedHours,
            @TaskCategory,
            @AdditionalNotes,
            @IsUrgent,
            GETDATE(),
            GETDATE(),
            @UserId,
            -- Location hierarchy
            COALESCE(@State, ''),
            COALESCE(@City, ''),
            COALESCE(@LocalityName, ''),
            COALESCE(@Pincode, ''),
            @StateId,
            @CityId,
            @AreaId,
            @PincodeId,
            -- Marketing specific fields
            @ExpectedReach,
            @ConversionGoal,
            @Kpis,
            @MarketingMaterials,
            @ApprovalRequired,
            @ApprovalContact,
            @BudgetCode,
            @DepartmentCode,
            -- Additional fields
            @ConsultantName,
            @ConsultantFeedback,
            @CampCode,
            @EmployeeCode
        );
        
        SET @TaskId = SCOPE_IDENTITY();
        
        -- Insert initial status history
        INSERT INTO TaskStatusHistory (
            TaskId,
            Status,
            Remarks,
            ChangedByUserId,
            ChangedAt
        )
        VALUES (
            @TaskId,
            @Status,
            'Task created',
            @AssignedByUserId,
            GETDATE()
        );
        
        COMMIT TRANSACTION;
        
        -- Return the created TaskId
        SELECT @TaskId AS TaskId;
        
        PRINT 'Task created successfully with ID: ' + CAST(@TaskId AS VARCHAR);
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

PRINT 'sp_InsertTask procedure created successfully with ALL FIELDS!';
GO
