USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Every_Day]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stpAlert_Every_Day]
AS
BEGIN
	select 'O script dos alertas foram melhorados após a criação do vídeo e não precisam mais dessa procedure'
	select 'Todos os alertas são chamados pela sp stpAlert_Every_Minute controlados pelas 3 colunas novas criadas em Alert_Paramenter'

END
GO
