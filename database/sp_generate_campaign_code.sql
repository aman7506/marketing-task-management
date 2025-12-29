-- =============================================
-- Stored Procedure: sp_generate_campaign_code
-- Purpose: Generate unique campaign code in format MKT-YYYY-XXXX
-- =============================================

USE [marketing_db]
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

PRINT 'Stored procedure sp_generate_campaign_code created successfully';
GO

-- =============================================
-- Test the procedure
-- =============================================
DECLARE @TestCode NVARCHAR(50);
EXEC sp_generate_campaign_code @CampaignCode = @TestCode OUTPUT;
SELECT 'Generated Code' as Description, @TestCode as CampaignCode;
GO
