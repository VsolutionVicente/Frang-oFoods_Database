USE [TI_Database]
GO
/****** Object:  View [dbo].[vw_vs_ff_Devolucoes_desenv]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   view [dbo].[vw_vs_ff_Devolucoes_desenv]
as
select casT(e.Chave_fato as Numeric) as Chave_fato,
       format(e.Data_movto,'dd/MM/yyy','pt-br')  as Data_movto,
       e.COD_VEND_COMP AS COD_VENDEDOR, 
       ISNULL(GVEND.NOME_CADASTRO, 'Ñ INFORMADO') AS NOME_VENDEDOR, 
       e.COD_CLI_FOR AS COD_CLIENTE, 
       ISNULL(GCLI.NOME_CADASTRO, 'Ñ INFORMADO') AS NOME_CLIENTE, 
       e.NUM_DOCTO, 
	   e.Cod_tipo_mv TMV,
       sum(ISNULL(EI.QTDE_PRI, 0)) AS QTDE_PRI, 
       sum(ISNULL(EI.QTDE_AUX, 0)) AS QTDE_AUX, 
       sum(ISNULL(eI.VALOR_LIQUIDO, 0)) AS VALOR_Total,
	   EP.Num_parcela,
       EP.Valor,
       EP.Perc_parcela,
       EP.Prazo,
	   Data_vencto,
	   Data_vencto_util,
	   eo.OBSERVACAO Nota_Origem, 
	   coalesce(eo.Desc_mensagem1,'') as Desc_mensagem1,
	   coalesce(eo.Desc_mensagem2,'') as Desc_mensagem2,
	   coalesce(eo.Desc_mensagem3,'') as Desc_mensagem3,
	   coalesce(eo.Desc_mensagem4,'') as Desc_mensagem4
  from [SATKFRANGAO].[dbo].tbEntradas e
       inner join [SATKFRANGAO].[dbo].tbEntradasItem ei 
	           ON E.CHAVE_FATO = EI.CHAVE_FATO
              AND EI.NUM_SUBITEM = 0
	   inner join [SATKFRANGAO].[dbo].tbEntradasObs EO
	           on E.CHAVE_FATO = EO.CHAVE_FATO 
       INNER JOIN [SATKFRANGAO].[dbo].TBPRODUTO P 
	           ON EI.COD_PRODUTO = P.COD_PRODUTO
       INNER JOIN [SATKFRANGAO].[dbo].TBTIPOMVESTOQUE TMV ON TMV.COD_TIPO_MV = E.COD_TIPO_MV
        LEFT JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL GVEND 
		       ON GVEND.COD_CADASTRO = E.COD_VEND_COMP
       INNER JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL GCLI 
	           ON GCLI.COD_CADASTRO = e.COD_CLI_FOR
  	    LEFT JOIN [SATKFRANGAO].[dbo].tbPercurso 
		       ON (GCLI.COD_PERCURSO = tbPercurso.Cod_percurso)
        LEFT JOIN [SATKFRANGAO].[dbo].tbSaidas S  
		       ON EI.CHAVE_FATO_ORIG = S.CHAVE_FATO
   	   inner join [SATKFRANGAO].[dbo].tbEntradasParc ep
	           on EP.CHAVE_FATO = e.CHAVE_FATO
 where e.Cod_tipo_mv in ('T582','T583','T584','T587')
   and e.STATUS <> 'C'
   /*AND eI.QTDE_AUX <> 0*/
   and e.Data_movto >= dateadd(d,-365,cast(getdate() as date))
   --and e.Chave_fato ='000097740'
group by 
      e.Chave_fato,
      e.Data_movto,
      e.COD_VEND_COMP, 
      GVEND.NOME_CADASTRO, 
      e.COD_CLI_FOR, 
      GCLI.NOME_CADASTRO, 
      e.NUM_DOCTO, 
	  e.Cod_tipo_mv,
	  EP.Num_parcela,
      EP.Valor,
      EP.Perc_parcela,
      EP.Prazo,
	  ep.Data_vencto,
	  ep.Data_vencto_util,
      eo.OBSERVACAO, 
	  eo.Desc_mensagem1,
	  eo.Desc_mensagem2,
	  eo.Desc_mensagem3,
	  eo.Desc_mensagem4

GO
