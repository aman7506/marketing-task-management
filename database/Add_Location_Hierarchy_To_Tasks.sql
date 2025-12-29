-- Fix Tasks table to support hierarchical location
USE [MarketingTaskDB];
GO

-- Add columns if they don't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'StateId')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD [StateId] INT NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'StateName')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD [StateName] NVARCHAR(100) NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'CityId')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD [CityId] INT NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'CityName')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD [CityName] NVARCHAR(100) NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'AreaId')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD [AreaId] INT NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'AreaName')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD [AreaName] NVARCHAR(200) NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'PincodeId')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD [PincodeId] INT NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'PincodeValue')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD [PincodeValue] NVARCHAR(10) NULL;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND name = 'LocalityName')
BEGIN
    ALTER TABLE [dbo].[Tasks] ADD [LocalityName] NVARCHAR(200) NULL;
END
GO

-- Add foreign key constraints (optional, for data integrity)
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Tasks_States')
BEGIN
    ALTER TABLE [dbo].[Tasks]
    ADD CONSTRAINT [FK_Tasks_States] FOREIGN KEY ([StateId])
    REFERENCES [dbo].[States]([StateId])
    ON DELETE SET NULL;
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Tasks_Cities')
BEGIN
    ALTER TABLE [dbo].[Tasks]
    ADD CONSTRAINT [FK_Tasks_Cities] FOREIGN KEY ([CityId])
    REFERENCES [dbo].[Cities]([CityId])
    ON DELETE SET NULL;
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Tasks_Areas')
BEGIN
    ALTER TABLE [dbo].[Tasks]
    ADD CONSTRAINT [FK_Tasks_Areas] FOREIGN KEY ([AreaId])
    REFERENCES [dbo].[Areas]([AreaId])
    ON DELETE SET NULL;
END

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Tasks_Pincodes')
BEGIN
    ALTER TABLE [dbo].[Tasks]
    ADD CONSTRAINT [FK_Tasks_Pincodes] FOREIGN KEY ([PincodeId])
    REFERENCES [dbo].[Pincodes]([PincodeId])
    ON DELETE SET NULL;
END
GO

PRINT 'Tasks table updated with hierarchical location support';
GO

-- Update MarketingCampaigns table
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND type in (N'U'))
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND name = 'StateId')
    BEGIN
        ALTER TABLE [dbo].[MarketingCampaigns] ADD [StateId] INT NULL;
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND name = 'CityId')
    BEGIN
        ALTER TABLE [dbo].[MarketingCampaigns] ADD [CityId] INT NULL;
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND name = 'AreaId')
    BEGIN
        ALTER TABLE [dbo].[MarketingCampaigns] ADD [AreaId] INT NULL;
    END

    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND name = 'PincodeId')
    BEGIN
        ALTER TABLE [dbo].[MarketingCampaigns] ADD [PincodeId] INT NULL;
    END
    
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[MarketingCampaigns]') AND name = 'LocalityName')
    BEGIN
        ALTER TABLE [dbo].[MarketingCampaigns] ADD [LocalityName] NVARCHAR(200) NULL;
    END

    PRINT 'MarketingCampaigns table updated with hierarchical location support';
END
GO
