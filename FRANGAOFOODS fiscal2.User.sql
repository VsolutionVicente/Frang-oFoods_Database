USE [TI_Database]
GO
/****** Object:  User [FRANGAOFOODS\fiscal2]    Script Date: 10/06/2021 09:29:16 ******/
CREATE USER [FRANGAOFOODS\fiscal2] FOR LOGIN [FRANGAOFOODS\fiscal2] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [FRANGAOFOODS\fiscal2]
GO
