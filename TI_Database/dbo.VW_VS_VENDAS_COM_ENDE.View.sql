USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_VS_VENDAS_COM_ENDE]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VW_VS_VENDAS_COM_ENDE] AS
SELECT format(cast(S.DATA_V1 as date),'dd/MM/yyyy','pt-BR') "Data Faturamento", 
       cast(S.DATA_V1 as date) data,  
       cast(case when datepart(HH,S.Data_hora) <= 6
	             then dateadd(D,-1,S.Data_hora)
				 else S.Data_hora 
				 end as date) "Dt_Transacao",
	   s.Cod_tipo_mv TipoMovimento,
       S.COD_VEND_COMP AS COD_VENDEDOR, 
       ISNULL(GVEND.NOME_CADASTRO, 'Ñ INFORMADO') AS NOME_VENDEDOR, 
	   tbEndereco.email as Email_Vendedor,
       S.COD_CLI_FOR AS COD_CLIENTE, 
       ISNULL(GCLI.NOME_CADASTRO, 'Ñ INFORMADO') AS NOME_CLIENTE, 
	   ENDCLI.Cidade as Cidade_Cliente,
       s.Cod_cond_pgto CondicaooPagto,
	   format(Isnull(Cli.Perc_desconto,0),'N','pt-BR') Perc_Desconto,
	   isnull(Cli.Cod_grupo_limite,0) CodGrupoEconomico,
	   isnull(grupo.Nome, 'NAO INFORMADO') GrupoEconomico,
       format(S.DATA_MOVTO,'dd/MM/yyyy','pt-BR') "Data Movimento", 
       S.NUM_DOCTO, 
       SI.COD_PRODUTO AS COD_PRODUTO, 
       P.DESC_PRODUTO_NF AS NOME_PRODUTO,
       format(ISNULL(SI.QTDE_PRI, 0),'N','pt-BR')      AS PESO, 
       format(ISNULL(SI.QTDE_AUX, 0),'N','pt-BR')      AS CAIXAS, 
       format(ISNULL(SI.VALOR_LIQUIDO, 0),'N','pt-BR') AS VLR_LIQUIDO,
	   format(ISNULL(SI.VALOR_LIQUIDO, 0) / 
	          ISNULL(SI.QTDE_PRI, 0),'N','pt-BR')       AS VlrUnitario,
       SI.Valor_liquido AS VLR_Faturado,
	   ISNULL(SI.QTDE_PRI, 0) as Peso_Faturado
FROM [SATKFRANGAO].[dbo].TBSAIDASITEM SI
     INNER JOIN [SATKFRANGAO].[dbo].TBSAIDAS S ON S.CHAVE_FATO = SI.CHAVE_FATO
                              AND SI.NUM_SUBITEM = 0
     INNER JOIN [SATKFRANGAO].[dbo].TBPRODUTO P ON SI.COD_PRODUTO = P.COD_PRODUTO
     INNER JOIN [SATKFRANGAO].[dbo].TBTIPOMVESTOQUE TMV ON TMV.COD_TIPO_MV = S.COD_TIPO_MV
     LEFT  JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL GVEND ON GVEND.COD_CADASTRO = S.COD_VEND_COMP
	 left  join [SATKFRANGAO].[dbo].tbEndereco on (GVEND.Cod_cadastro = tbEndereco.Cod_cadastro)
     INNER JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL GCLI ON GCLI.COD_CADASTRO = S.COD_CLI_FOR
	 inner join [SATKFRANGAO].[dbo].TbCliente Cli on Cli.Cod_cadastro = GCLI.Cod_cadastro
	 LEFT  JOIN [SATKFRANGAO].[dbo].tbPercurso ON (GCLI.COD_PERCURSO = tbPercurso.Cod_percurso)
	 left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo on grupo.Cod_grupo_limite = cli.Cod_grupo_limite
	 left  join [SATKFRANGAO].[dbo].tbEndereco ENDCLI on (GCLI.Cod_cadastro = ENDCLI.Cod_cadastro)

WHERE TMV.CLASSE = '5'
      AND S.STATUS_CTB = 'S'
      AND S.STATUS <> 'C'
      AND S.COD_DOCTO = 'NE'
      AND SI.QTDE_AUX <> 0
	  and tbEndereco.Tipo_endereco = 'C'
	  and ENDCLI.Tipo_endereco = 'C'
GO
