USE [TI_Database]
GO
/****** Object:  User [FRANGAOFOODS\valceir.amaral]    Script Date: 10/06/2021 09:29:16 ******/
CREATE USER [FRANGAOFOODS\valceir.amaral] FOR LOGIN [FRANGAOFOODS\valceir.amaral] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [FRANGAOFOODS\valceir.amaral]
GO
