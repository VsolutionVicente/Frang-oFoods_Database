USE [TI_Database]
GO
/****** Object:  View [dbo].[vw_vs_GIVEWAY]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM tbProduto WHERE Cod_produto like 'PA00%'
--select * from tbProdutoPcp WHERE Cod_produto like 'PA00%'

create   VIEW [dbo].[vw_vs_GIVEWAY] as
select cast(Cod_filial as varchar) +cast(Serie_volume as Varchar) + cast(Num_volume as Varchar) Etiqueta,
       Volume.cod_produto,
	   Volume.Peso_liquido_real,
       Volume.Peso_bruto_real,
       Volume.Peso_bruto,
       Volume.Tara_externa,
       Volume.Tara_interna,
       Volume.Peso_liquido,
	   Ref.Peso_minimo, 
	   ref.Peso_maximo,
	   Volume.Peso_liquido_real - Volume.Peso_liquido "GIVEWAY(g)"
  from [satkfrangao].[dbo].tbVolume volume
  join [satkfrangao].[dbo].tbprodutoRef REF on REF.Cod_produto = Volume.Cod_produto
 where Data_producao >='2021-07-07' and REf.Cod_produto like 'PA%'

GO
