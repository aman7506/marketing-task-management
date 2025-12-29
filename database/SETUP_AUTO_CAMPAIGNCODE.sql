-- =============================================
-- QUICK START: Execute this entire script
-- to set up auto-generated Campaign Codes
-- =============================================

USE [marketing_db]
GO

PRINT '========================================';
PRINT 'STARTING CAMPAIGNCODE AUTO-GENERATION SETUP';
PRINT '========================================';
PRINT '';

-- =============================================
-- STEP 1: Verify MarketingCampaigns table exists
-- =============================================
PRINT 'STEP 1: Checking if MarketingCampaigns table exists...';

IF EXISTS (SELECT * FROM sysobjects WHERE name='MarketingCampaigns' AND xtype='U')
BEGIN
    PRINT '✅ MarketingCampaigns table exists';
    
    -- Check if CampaignCode column exists
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('MarketingCampaigns') AND name = 'CampaignCode')
    BEGIN
        PRINT '✅ CampaignCode column exists';
    END
    ELSE
    BEGIN
        PRINT '❌ CampaignCode column is missing!';
        PRINT 'Adding CampaignCode column...';
        ALTER TABLE MarketingCampaigns ADD [CampaignCode] NVARCHAR(50) NULL;
        PRINT '✅ CampaignCode column added';
    END
END
ELSE
BEGIN
    PRINT '❌ ERROR: MarketingCampaigns table does not exist!';
    PRINT 'Please run setup_marketing_db.sql first';
    RETURN;
END

PRINT '';

-- =============================================
-- STEP 2: Create sp_generate_campaign_code
-- =============================================
PRINT 'STEP 2: Creating sp_generate_campaign_code stored procedure...';
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_generate_campaign_code]
    @Year INT = NULL,
    @CampaignCode NVARCHAR(50) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Use current year if not provided
        IF @Year IS NULL
            SET @Year = YEAR(GETDATE());
        
        DECLARE @NextNumber INT;
        DECLARE @PaddedNumber NVARCHAR(4);
        
        -- Get the last campaign code for this year
        -- This query is thread-safe due to SERIALIZABLE isolation level
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        BEGIN TRANSACTION;
        
        SELECT TOP 1 @NextNumber = 
            CAST(RIGHT(CampaignCode, 3) AS INT) + 1
        FROM MarketingCampaigns
        WHERE CampaignCode LIKE 'CAMP-' + CAST(@Year AS NVARCHAR(4)) + '-%'
        ORDER BY CampaignCode DESC;
        
        -- If no campaigns exist for this year, start from 1
        IF @NextNumber IS NULL
            SET @NextNumber = 1;
        
        -- Pad the number with leading zeros (001, 002, etc.)
        SET @PaddedNumber = RIGHT('000' + CAST(@NextNumber AS NVARCHAR(4)), 3);
        
        -- Generate the campaign code: CAMP-YYYY-XXX
        SET @CampaignCode = 'CAMP-' + CAST(@Year AS NVARCHAR(4)) + '-' + @PaddedNumber;
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Return error
        SET @CampaignCode = NULL;
        
        -- Log error
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
            'sp_generate_campaign_code',
            ERROR_LINE(),
            GETDATE()
        );
        
        -- Re-throw error
        THROW;
    END CATCH
END
GO

PRINT '✅ sp_generate_campaign_code created successfully';
PRINT '';

-- =============================================
-- STEP 3: Test the stored procedure
-- =============================================
PRINT 'STEP 3: Testing campaign code generation...';
PRINT '';

DECLARE @TestCode1 NVARCHAR(50);
DECLARE @TestCode2 NVARCHAR(50);
DECLARE @TestCode3 NVARCHAR(50);

-- Test 1: Generate first code
EXEC sp_generate_campaign_code @CampaignCode = @TestCode1 OUTPUT;
PRINT 'Test 1 - First code generated: ' + ISNULL(@TestCode1, 'NULL');

-- Test 2: Generate second code (should increment)
EXEC sp_generate_campaign_code @CampaignCode = @TestCode2 OUTPUT;
PRINT 'Test 2 - Second code generated: ' + ISNULL(@TestCode2, 'NULL');

-- Test 3: Generate code for specific year
EXEC sp_generate_campaign_code @Year = 2026, @CampaignCode = @TestCode3 OUTPUT;
PRINT 'Test 3 - Code for year 2026: ' + ISNULL(@TestCode3, 'NULL');

PRINT '';

-- =============================================
-- STEP 4: Show existing campaigns (if any)
-- =============================================
PRINT 'STEP 4: Showing existing campaigns with codes...';
PRINT '';

IF EXISTS (SELECT 1 FROM MarketingCampaigns WHERE CampaignCode IS NOT NULL)
BEGIN
    SELECT TOP 10
        CampaignId,
        CampaignCode,
        CampaignManager,
        CreatedAt
    FROM MarketingCampaigns
    WHERE CampaignCode IS NOT NULL
    ORDER BY CampaignCode DESC;
    
    PRINT '✅ Existing campaigns shown above';
END
ELSE
BEGIN
    PRINT '📝 No campaigns with codes exist yet';
    PRINT 'The first campaign will get: MKT-' + CAST(YEAR(GETDATE()) AS NVARCHAR(4)) + '-0001';
END

PRINT '';

-- =============================================
-- STEP 5: Verification queries
-- =============================================
PRINT 'STEP 5: Running verification queries...';
PRINT '';

-- Check stored procedure exists
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_generate_campaign_code')
    PRINT '✅ sp_generate_campaign_code exists';
ELSE
    PRINT '❌ sp_generate_campaign_code does NOT exist';

-- Check ErrorLogs table exists
IF EXISTS (SELECT * FROM sysobjects WHERE name='ErrorLogs' AND xtype='U')
    PRINT '✅ ErrorLogs table exists';
ELSE
BEGIN
    PRINT '⚠️  ErrorLogs table does not exist';
    PRINT 'Creating ErrorLogs table...';
    
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
    
    PRINT '✅ ErrorLogs table created';
END

PRINT '';

-- =============================================
-- FINAL SUMMARY
-- =============================================
PRINT '========================================';
PRINT 'SETUP COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT '✅ Auto-generated Campaign Code system is ready!';
PRINT '';
PRINT 'FORMAT: MKT-YYYY-XXXX';
PRINT 'Example: MKT-2025-0001, MKT-2025-0002, etc.';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. Restart your backend server (dotnet run)';
PRINT '2. Test GET /api/marketingcampaign/newcode endpoint';
PRINT '3. Open Marketing Form in browser';
PRINT '4. Verify auto-generated code appears in the form';
PRINT '';
PRINT '========================================';
GO
