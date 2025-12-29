-- =============================================
-- UPDATE CAMPAIGN CODE FORMAT
-- From: MKT-YYYY-XXXX
-- To: CAMP-YYYY-XXX
-- =============================================

USE [marketing_db]
GO

PRINT '========================================';
PRINT 'UPDATING CAMPAIGN CODE FORMAT';
PRINT 'From: MKT-2025-XXXX';
PRINT 'To: CAMP-2025-XXX';
PRINT '========================================';
PRINT '';

-- =============================================
-- STEP 1: Drop old stored procedure (if exists)
-- =============================================
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_generate_campaign_code')
BEGIN
    DROP PROCEDURE sp_generate_campaign_code;
    PRINT '✅ Old procedure dropped';
END
GO

-- =============================================
-- STEP 2: Create NEW stored procedure with CAMP format
-- =============================================
CREATE PROCEDURE [dbo].[sp_generate_campaign_code]
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
        DECLARE @PaddedNumber NVARCHAR(3);
        
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
        SET @PaddedNumber = RIGHT('000' + CAST(@NextNumber AS NVARCHAR(3)), 3);
        
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
            ErrorMessage, ErrorNumber, ErrorSeverity, ErrorState,
            ErrorProcedure, ErrorLine, CreatedAt
        )
        VALUES (
            ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(),
            'sp_generate_campaign_code', ERROR_LINE(), GETDATE()
        );
        
        -- Re-throw error
        THROW;
    END CATCH
END
GO

PRINT '✅ New stored procedure created with CAMP format';
PRINT '';

-- =============================================
-- STEP 3: Test the new format
-- =============================================
PRINT 'STEP 3: Testing new campaign code format...';
PRINT '';

DECLARE @TestCode1 NVARCHAR(50);
DECLARE @TestCode2 NVARCHAR(50);

-- Test for current year (2025)
EXEC sp_generate_campaign_code @CampaignCode = @TestCode1 OUTPUT;
PRINT 'Test 1 - Code for 2025: ' + ISNULL(@TestCode1, 'NULL');

-- Test for 2026
EXEC sp_generate_campaign_code @Year = 2026, @CampaignCode = @TestCode2 OUTPUT;
PRINT 'Test 2 - Code for 2026: ' + ISNULL(@TestCode2, 'NULL');

PRINT '';

-- =============================================
-- STEP 4: Show existing campaigns
-- =============================================
PRINT 'STEP 4: Existing campaigns in database:';
PRINT '';

SELECT TOP 10
    CampaignId,
    CampaignCode,
    CampaignManager,
    CreatedAt
FROM MarketingCampaigns
ORDER BY CampaignId DESC;

PRINT '';

-- =============================================
-- FINAL MESSAGE
-- =============================================
PRINT '========================================';
PRINT 'FORMAT UPDATE COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'New Format: CAMP-YYYY-XXX';
PRINT 'Example: CAMP-2025-001, CAMP-2025-002';
PRINT '';
PRINT 'Next Steps:';
PRINT '1. Restart backend (if needed)';
PRINT '2. Test in Marketing Form';
PRINT '3. New campaigns will use CAMP format';
PRINT '';
PRINT '========================================';
GO
