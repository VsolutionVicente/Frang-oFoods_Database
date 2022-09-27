USE [TI_Database]
GO
/****** Object:  View [dbo].[vw_Rendimento]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select * from tbproduto where Cod_produto like 'SB%'
create view [dbo].[vw_Rendimento] as 
select * from [SATKFRANGAO].dbo.FF_VS_RendimentoAbate where Data_Estoque >= cast(getdate() -7 as date)
GO
