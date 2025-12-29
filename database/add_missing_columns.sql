-- Add missing columns to MarketingCampaigns table
USE [marketing_db]
GO

-- Check if LocalityId column exists, if not add it
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND name = 'LocalityId')
BEGIN
    ALTER TABLE [dbo].[MarketingCampaigns]
    ADD LocalityId INT NULL;
    
    PRINT '✅ Added LocalityId column to MarketingCampaigns table';
END
ELSE
BEGIN
    PRINT 'ℹ️ LocalityId column already exists';
END
GO

-- Check if PincodeId column exists, if not add it
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND name = 'PincodeId')
BEGIN
    ALTER TABLE [dbo].[MarketingCampaigns]
    ADD PincodeId INT NULL;
    
    PRINT '✅ Added PincodeId column to MarketingCampaigns table';
END
ELSE
BEGIN
    PRINT 'ℹ️ PincodeId column already exists';
END
GO

-- Add foreign key constraints (optional but recommended)
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_MarketingCampaigns_Localities')
BEGIN
    ALTER TABLE [dbo].[MarketingCampaigns]
    ADD CONSTRAINT FK_MarketingCampaigns_Localities
    FOREIGN KEY (LocalityId) REFERENCES Localities(LocalityId);
    
    PRINT '✅ Added foreign key constraint for LocalityId';
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_MarketingCampaigns_Pincodes')
BEGIN
    ALTER TABLE [dbo].[MarketingCampaigns]
    ADD CONSTRAINT FK_MarketingCampaigns_Pincodes
    FOREIGN KEY (PincodeId) REFERENCES Pincodes(PincodeId);
    
    PRINT '✅ Added foreign key constraint for PincodeId';
END
GO

PRINT '';
PRINT '🎉 Table schema updated successfully! Now run the stored procedure script.';
GO
