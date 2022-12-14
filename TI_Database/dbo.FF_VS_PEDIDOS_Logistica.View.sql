USE [TI_Database]
GO
/****** Object:  View [dbo].[FF_VS_PEDIDOS_Logistica]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[FF_VS_PEDIDOS_Logistica] AS
SELECT S.NUM_DOCTO,
       S.NUM_CARGA,
	   S.COD_TIPO_MV TipoMovimento, 
       (RTRIM(S.COD_DOCTO) +'-'+ RTRIM(S.SERIE_SEQ) +'-'+ CAST(S.NUM_DOCTO AS CHAR)) AS Pedido_Grupo,
       (RTRIM(S.COD_DOCTO) +'-'+ RTRIM(S.SERIE_SEQ) +'-'+ CAST(rtrim(S.NUM_DOCTO) AS varchar) + '- CEP - ' + Cast(e.Cep as Varchar)) AS Pedido_CEP,
       case when S.Tipo_frete1 = 'C'
	        then 'C - CIF'
			else 'F - FOB'
			end Tipo_Frete, 
	   S.COD_CLI_FOR Cod_CLiente, 
	   G.APELIDO CLiente,
	   case G.Cod_situacao
	        when 'A' then 'A - Ativo'
			when 'I' then 'I - Inativo'
			when 'B' then 'B - Bloqueado'
			end StatusCliente,
       (RTRIM(ISNULL(E.UF,'ZZ')) + '-' + RTRIM(ISNULL(E.CIDADE,'ZZ')))  AS Cidade,
	   e.Endereco + ', ' + e.Numero as Endereco,
	   RTRIM(ISNULL(E.BAIRRO,'ZZ')) as Bairro,
       e.Cep,
       S.DATA_V1,
       ISNULL(P.COD_PERCURSO,'99999') AS Cod_Percurso, 
	   ISNULL(P.DESCRICAO,'NAO INFORMADA') AS Rota, 
	   SUM(SI.QTDE_PRI) as PesoPadrao,
       SUM(SI.QTDE_PRI + (SI.QTDE_AUX*ISNULL(REF.TARA_EXTERNA,0))) AS Peso,  
	   Sum(SI.QTDE_AUX) caixas, 
       CASE S.STATUS_BLOQUEIO
            WHEN 'S' THEN 'SIM'
            WHEN 'N' THEN 'NÃO' END AS Status_Bloqueio,
       CASE S.STATUS_CTB
            WHEN 'S' THEN 'SIM'
            WHEN 'N' THEN 'NÃO' END AS Status_Atualizado,
       CASE WHEN NS.STATUS_CTB = 'S' 
	        THEN 'SIM' 
			ELSE 'NÃO' END AS Status_Faturado
FROM [SATKFRANGAO].[dbo].TBSAIDAS S 
     INNER JOIN [SATKFRANGAO].[dbo].TBSAIDASITEM SI
             ON SI.CHAVE_FATO = S.CHAVE_FATO AND SI.NUM_SUBITEM=0
            AND SI.NUM_SUBITEM = 0
     INNER JOIN [SATKFRANGAO].[dbo].TBPRODUTO PROD
             ON PROD.COD_PRODUTO = SI.COD_PRODUTO   
     INNER JOIN [SATKFRANGAO].[dbo].TBPRODUTOREF REF
             ON REF.COD_PRODUTO = SI.COD_PRODUTO
            AND REF.COD_REF = SI.COD_REF
     INNER JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL G
             ON G.COD_CADASTRO = S.COD_CLI_FOR
      LEFT JOIN [SATKFRANGAO].[dbo].TBENDERECO E
             ON E.COD_CADASTRO = S.COD_CLI_FOR
            AND E.TIPO_ENDERECO = 'E'
      LEFT JOIN [SATKFRANGAO].[dbo].TBPERCURSO P
             ON P.COD_PERCURSO = ISNULL(S.COD_PERCURSO,'0')
      LEFT JOIN [SATKFRANGAO].[dbo].TBSAIDAS R
             ON S.CHAVE_FATO=R.CHAVE_FATO_ORIG_UN
            AND R.COD_DOCTO='ROS'
      LEFT JOIN [SATKFRANGAO].[dbo].TBSAIDAS NS 
             ON NS.CHAVE_FATO_ORIG_UN = R.CHAVE_FATO
            AND R.COD_DOCTO LIKE 'N%'
WHERE S.COD_DOCTO in ('PVE','PVB') 
  AND NOT (S.CHAVE_FATO IN (SELECT DISTINCT CHAVE_FATO_ORIG_UN FROM [SATKFRANGAO].[dbo].TBSAIDAS WHERE COD_DOCTO = 'ROS')) 
  AND R.CHAVE_FATO_ORIG_UN IS NULL 
  AND S.DATA_V1 >= cast(getdate() - 5 as date)
  AND S.STATUS <> 'C'  
  AND S.COD_TIPO_MV NOT IN ('T503')
group by 
      S.NUM_DOCTO,
      S.NUM_CARGA,
      S.COD_DOCTO,
	  S.SERIE_SEQ,
      S.COD_CLI_FOR, 
	  G.APELIDO,
	  S.COD_TIPO_MV, 
	  S.Tipo_frete1, 
      (RTRIM(ISNULL(E.UF,'ZZ')) + '-' + RTRIM(ISNULL(E.CIDADE,'ZZ'))),
	  RTRIM(ISNULL(E.BAIRRO,'ZZ')),
      S.DATA_V1,
      ISNULL(P.COD_PERCURSO,'99999'), 
	  ISNULL(P.DESCRICAO,'NAO INFORMADA'), 
      S.STATUS_BLOQUEIO,
      S.STATUS_CTB,
      NS.STATUS_CTB,
	  E.Endereco,
	  E.Numero,
      E.Cep,
	   G.Cod_situacao
GO
