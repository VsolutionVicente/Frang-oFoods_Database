USE [TI_Database]
GO
/****** Object:  View [dbo].[vw_vs_CadastroPesoProd]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE vIEW [dbo].[vw_vs_CadastroPesoProd] as
select PROD.Cod_produto,
       PROD.Desc_produto_nf,
       Ref.Peso_liquido_padrao,
       coalesce(Ref.Tara_externa,0) Tara_externa,
       REF.Peso_minimo,
       Ref.Peso_maximo,
	   coalesce(Ref.Tara_externa,0)  + REF.Peso_minimo as Peso_Minimo_Balanca,
	   coalesce(Ref.Tara_externa,0)  + Ref.Peso_maximo as Peso_Maximo_Balanca
  from [satkfrangao].[dbo].tbProduto Prod
  join [satkfrangao].[dbo].tbProdutoRef REF on (Ref.Cod_produto = prod.Cod_produto)
 WHERE Prod.Cod_produto like 'PA00%'
GO
