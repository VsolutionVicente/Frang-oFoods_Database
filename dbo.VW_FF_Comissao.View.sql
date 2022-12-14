USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_FF_Comissao]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[VW_FF_Comissao] as
SELECT [Extent1].Cod_vendedor,
       [Extent1].Nome_vendedor,
	   [Extent1].Cod_cli_for,
	   [Extent1].Nome_cli_for,
	   [Extent1].Razao_social_cli_for, 
	   [Extent1].Titulo,
	   [Extent2].Data_lancto,
	   [Extent1].Data_emissao,
	   [Extent1].Data_vencto,
	   [Extent2].Tipo_Partida,
	   [Extent1].Cod_forma_cp,
	   [Extent1].Nome_forma_cp,
	   [Extent1].Natureza_titulo,
	   [Extent1].Valor_titulo,
	   [Extent1].Valor_titulo_moeda,
	   [Extent1].[VALOR_ABATIMENTO],
       [Extent1].[VALOR_ACRESCIMO], 
	   [Extent1].Perc_comissao Perc_Comissao_Sist, 
	   cast(1.5 as float) Perc_Comissao_Fixo,
	   [Extent2].operfin,
	   Case when Tipo_Partida = 'C' then 1 else -1 end * Valor_lancto_moeda as Valor_lancto_moeda, 
	   Case when Tipo_Partida = 'C' then 1 else -1 end * Valor_lancto_moeda*.015 Comissao
  FROM  [SATKFRANGAO].[dbo].[VWATAK4NET_TITULOS_A_RECEBER] AS [Extent1]
        INNER JOIN [SATKFRANGAO].[dbo].[vwAtak4Net_movtofin_a_receber] AS [Extent2] ON [Extent1].[CHAVE_FATO_TITULO] = [Extent2].[Chave_fato_titulo]
        WHERE --[Extent2].Cod_cli_for = 51220
		   --AND (COD_VENDEDOR = 80027)  AND
		   --Chave_fato_orig IN ('000046381','000065869','000078315','000096257','000119423')
		   ([Extent2].[Data_lancto] >='20210401') 
		   and ( NOT (([Extent2].[operfin] IN ('TRECDESC', 'TRECDECR', 'TRECINC')) 
		         AND ([Extent2].[operfin] IS NOT NULL))) AND ([Extent2].[Valor_lancto] > cast(0 as decimal(18)))
GO
