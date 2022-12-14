USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_FF_Comissao_OLD]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create view [dbo].[VW_FF_Comissao_OLD] as
SELECT [Extent1].Cod_vendedor,
       [Extent1].Nome_vendedor,
	   tbVendedor.Cod_supervisor_vda Cod_Supervisor,
	   Vendedor.Nome_cadastro            Supervisor,
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
	   -- coalesce([Extent1].Perc_comissao, 1.5) Perc_Comissao_Fixo, 
		case when (    coalesce([Extent1].Perc_comissao, 1.5) >= 0  
		           and coalesce([Extent1].Perc_comissao, 1.5) < 1.5)
			   and tbVendedorVenda.Perc_comissao >0
			 then 1.5
			 else coalesce([Extent1].Perc_comissao, 1.5)
		end Perc_Comissao_Fixo,
	   /*
	   case [Extent1].Cod_vendedor 
	        when 80171 then cast (2.5 as float)
			else cast(1.5 as float) 
			end Perc_Comissao_Fixo,
	   */

	   [Extent2].operfin,
	   Case when Tipo_Partida = 'C' then 1 else -1 end * Valor_lancto_moeda as Valor_lancto_moeda, 
	   Case when Tipo_Partida = 'C' 
	        then 1 
			else -1 end * 
			Valor_lancto_moeda * 
		case when (    coalesce([Extent1].Perc_comissao, 1.5) >= 0  
		           and coalesce([Extent1].Perc_comissao, 1.5) < 1.5)
			       and tbVendedorVenda.Perc_comissao >0
			     then (1.5 /100)
				 else (coalesce([Extent1].Perc_comissao, 1.5)/100)
            end  Comissao
  FROM  [SATKFRANGAO].[dbo].[VWATAK4NET_TITULOS_A_RECEBER] AS [Extent1]
        INNER JOIN [SATKFRANGAO].[dbo].[vwAtak4Net_movtofin_a_receber] AS [Extent2] 
		        ON [Extent1].[CHAVE_FATO_TITULO] = [Extent2].[Chave_fato_titulo]
        Inner join [SATKFRANGAO].[dbo].tbVendedor as tbVendedorVenda
		        on [Extent1].Cod_vendedor = tbVendedorVenda.Cod_cadastro
		INNER JOIN [SATKFRANGAO].[dbo].tbVendedor as tbVendedor
		        on [Extent1].Cod_cli_for = tbVendedor.Cod_cadastro
		 left join [SATKFRANGAO].[dbo].tbCadastroGeral Vendedor
		        on tbVendedor.Cod_supervisor_vda = Vendedor.Cod_cadastro
        WHERE  ([Extent2].[Data_lancto] >='20210401') 
		   and ( NOT (([Extent2].[operfin] IN ('TRECDESC', 'TRECDECR', 'TRECINC')) 
		         AND ([Extent2].[operfin] IS NOT NULL))) 
		   AND ([Extent2].[Valor_lancto] > cast(0 as decimal(18)))
		   AND (substring([Extent1].Titulo,5,3) <> 'ADC' )/* Alteração Solicitada pela Cilene Dia 13/10/2021 */
GO
