USE [TI_Database]
GO
/****** Object:  User [Consulta_DW]    Script Date: 10/06/2021 09:29:16 ******/
CREATE USER [Consulta_DW] FOR LOGIN [Consulta_DW] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Consulta_DW]
GO
