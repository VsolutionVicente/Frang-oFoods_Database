USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_VS_FF_ContasReceber]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   view [dbo].[VW_VS_FF_ContasReceber] as
select Cast(sp.Cod_carteira as varchar) + '-'+
       sp.Nome_carteira as "Emp/Carteira", 
	   case when Cod_docto = 'NE'
	        then 'NF-e'
			else Cod_docto
			end as Origem,
       SP.Nome_Cli_for  "Razão Social", 
       cast(sp.Num_docto as varchar) + '-' + cast(sp.Num_parcela as varchar) "Nota - Parcela",
       format(sp.Data_emissao,'dd/MM/yyyy', 'pt-br') as "DT Emissão",
       format(sp.Data_vencto,'dd/MM/yyyy', 'pt-br') as "VECTO",
       format(sp.Data_vencto_util,'dd/MM/yyyy', 'pt-br') as "Vencimento Util",
       sp.Valor_titulo,
	   sp.Valor_saldo AS Saldo,
	   coalesce(sp.Valor_abatimento,0) AS Desconto
  from [SATKFRANGAO].[dbo].[vwAtak4Net_titulos_a_receber] SP
  where SP.Data_emissao >= dateadd(d,-5,getdate())
   and  sp.Cod_docto ='NE'
	--order by 1 desc


GO
