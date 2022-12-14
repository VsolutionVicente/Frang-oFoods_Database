USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_VS_VENDAS]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE View [dbo].[VW_VS_VENDAS] AS 
SELECT S.DATA_V1 as Data_Faturamento,
	   s.Cod_tipo_mv TipoMovimento,
		cast(case when datepart(HH,S.Data_hora) <= 6
					then dateadd(D,-1,S.Data_hora)
					else S.Data_hora 
					end as date)          as Dt_Transacao,
       S.COD_VEND_COMP AS COD_VENDEDOR, 
       ISNULL(GVEND.NOME_CADASTRO, 'Ñ INFORMADO') AS NOME_VENDEDOR, 
	   tbEndereco.email as Email_Vendedor,
       S.COD_CLI_FOR AS COD_CLIENTE, 
       ISNULL(GCLI.NOME_CADASTRO, 'Ñ INFORMADO') AS NOME_CLIENTE, 
	   supervisor.Nome_cadastro as Nome_Supervisor,
	   SuperEnde.Email as Email_Supervisor,
       s.Cod_cond_pgto CondicaooPagto,
	   Isnull(Cli.Perc_desconto,0) Perc_Desconto,
	   Cli.Cod_grupo_limite CodGrupoEconomico,
	   grupo.Nome GrupoEconomico,
       S.DATA_MOVTO, 
       S.NUM_DOCTO, 
       SI.COD_PRODUTO AS COD_PRODUTO, 
       P.DESC_PRODUTO_NF AS NOME_PRODUTO,
       ISNULL(SI.QTDE_PRI, 0) AS QTDE_PRI, 
       ISNULL(SI.QTDE_AUX, 0) AS QTDE_AUX, 
       ISNULL(SI.VALOR_LIQUIDO, 0) AS VALOR_LIQUIDO,
	   ISNULL(SI.VALOR_LIQUIDO, 0) / 
	   ISNULL(SI.QTDE_PRI, 0)   AS VlrUnitario
FROM [SATKFRANGAO].[dbo].TBSAIDASITEM SI
     INNER JOIN [SATKFRANGAO].[dbo].TBSAIDAS S 
	         ON S.CHAVE_FATO = SI.CHAVE_FATO
            AND SI.NUM_SUBITEM = 0
     INNER JOIN [SATKFRANGAO].[dbo].TBPRODUTO P 
	         ON SI.COD_PRODUTO = P.COD_PRODUTO
     INNER JOIN [SATKFRANGAO].[dbo].TBTIPOMVESTOQUE TMV 
	         ON TMV.COD_TIPO_MV = S.COD_TIPO_MV
     LEFT  JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL GVEND 
	         ON GVEND.COD_CADASTRO = S.COD_VEND_COMP
	 LEFT  JOIN [SATKFRANGAO].[dbo].tbEndereco 
	         ON GVEND.Cod_cadastro = tbEndereco.Cod_cadastro
     INNER JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL GCLI 
	         ON GCLI.COD_CADASTRO = S.COD_CLI_FOR
	 INNER JOIN [SATKFRANGAO].[dbo].TbCliente Cli 
	         ON Cli.Cod_cadastro = GCLI.Cod_cadastro
	 LEFT  JOIN [SATKFRANGAO].[dbo].tbPercurso 
	         ON GCLI.COD_PERCURSO = tbPercurso.Cod_percurso
	 LEFT  JOIN [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
	         ON grupo.Cod_grupo_limite = cli.Cod_grupo_limite
	 
	 LEFT  JOIN [SATKFRANGAO].[dbo].tbVendedor Vend 
	         ON Vend.Cod_cadastro = S.COD_VEND_COMP
	 
	 LEFT  JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL Supervisor 
	         ON Vend.Cod_supervisor_vda = Supervisor.Cod_cadastro

	 LEFT  JOIN [SATKFRANGAO].[dbo].tbEndereco SuperEnde
             ON SuperEnde.Cod_cadastro = Supervisor.Cod_cadastro and SuperEnde.Tipo_endereco = 'C'

WHERE TMV.CLASSE = '5'
      AND S.STATUS_CTB = 'S'
      AND S.STATUS <> 'C'
      AND S.COD_DOCTO = 'NE'
      AND SI.QTDE_AUX <> 0
	  and tbEndereco.Tipo_endereco = 'C'
	  

	  
GO
