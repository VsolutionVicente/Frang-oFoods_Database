USE [TI_Database]
GO
/****** Object:  View [dbo].[vw_FF_Produtos_Vendidos]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_FF_Produtos_Vendidos] as
select Data_V1,  
       "Cod Produto" Cod_Produto,
       Produto,
	   sum("Peso Pedido") Peso,
	   sum("Caixas Pedido") Caixas
  from [dbo].[FF_VS_PEDIDOS_VENDAS]
  group by 
		Data_V1,  
        "Cod Produto",
        Produto
GO
