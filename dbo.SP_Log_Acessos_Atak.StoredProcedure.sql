USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[SP_Log_Acessos_Atak]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Log_Acessos_Atak] 
as
begin

insert into ACESSOS_ATAK (
				Cod_usuario	,
				Login		,
				Last		,	
				MachineID	)
       select 	Cod_usuario	,
				Login		,
				Last		,	
				MachineID	
		   from SATKFRANGAO.dbo.ActiveConnections;
end;
GO
