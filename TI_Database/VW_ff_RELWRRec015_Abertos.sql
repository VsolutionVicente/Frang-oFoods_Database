CREATE OR ALTER view [dbo].[VW_ff_RELWRRec015_Abertos] AS
SELECT 
    [Extent1].[NUM_DOCTO] AS [NUM_DOCTO], 
    [Extent1].[CHAVE_FATO_TITULO] AS [CHAVE_FATO_TITULO], 
    [Extent1].[COD_FILIAL] AS [COD_FILIAL], 
    [Extent1].[COD_DOCTO] AS [COD_DOCTO], 
    [Extent1].[SERIE_DOCTO] AS [SERIE_DOCTO], 
    [Extent1].[NUM_PARCELA] AS [NUM_PARCELA], 
    [Extent1].[DATA_EMISSAO] AS [DATA_EMISSAO], 
    [Extent1].[DATA_VENCTO] AS [DATA_VENCTO], 
    [Extent1].[DATA_VENCTO_UTIL] AS [DATA_VENCTO_UTIL], 
    CASE WHEN (([Extent1].[STATUS_TITULO] = 'C') 
	       OR (([Extent1].[STATUS_TITULO] IS NULL) 
		       AND ('C' IS NULL))) 
	  THEN cast(0 as decimal(18)) 
	     WHEN (1 = 1) 
		 THEN CASE WHEN ([Extent1].[COD_DOCTO] LIKE 'AD%') 
		           THEN [Extent1].[VALOR_TITULO] * cast(-1 as decimal(18)) 
				   ELSE [Extent1].[VALOR_TITULO] END 
		  WHEN ([Extent1].[COD_DOCTO] LIKE 'AD%') 
		  THEN [Extent1].[VALOR_TITULO_MOEDA] * cast(-1 as decimal(18)) 
		  ELSE [Extent1].[VALOR_TITULO_MOEDA] END AS [C1], 
    CASE WHEN (([Extent1].[STATUS_TITULO] = 'C') OR (([Extent1].[STATUS_TITULO] IS NULL) AND ('C' IS NULL))) THEN cast(0 as decimal(18)) WHEN ([Extent1].[COD_DOCTO] LIKE 'AD%') THEN [Extent1].[VALOR_TITULO_MOEDA] * cast(-1 as decimal(18)) ELSE [Extent1].[VALOR_TITULO_MOEDA] END AS [C2], 
    CASE WHEN (1 = 1) THEN CASE WHEN ([Extent1].[COD_DOCTO] LIKE 'AD%') THEN [Extent1].[VALOR_SALDO] * cast(-1 as decimal(18)) ELSE [Extent1].[VALOR_SALDO] END WHEN ([Extent1].[COD_DOCTO] LIKE 'AD%') THEN [Extent1].[VALOR_SALDO_MOEDA] * cast(-1 as decimal(18)) ELSE [Extent1].[VALOR_SALDO_MOEDA] END AS [C3], 
    CASE WHEN ([Extent1].[COD_DOCTO] LIKE 'AD%') THEN [Extent1].[VALOR_SALDO_MOEDA] * cast(-1 as decimal(18)) ELSE [Extent1].[VALOR_SALDO_MOEDA] END AS [C4], 
    [Extent1].[STATUS_TITULO] AS [STATUS_TITULO], 
    [Extent1].[NATUREZA_TITULO] AS [NATUREZA_TITULO], 
    [Extent1].[NUM_NOSSO_REC] AS [NUM_NOSSO_REC], 
    CASE WHEN ([Extent1].[PERC_COMISSAO] IS NOT NULL) THEN [Extent1].[PERC_COMISSAO] ELSE cast(0 as decimal(18)) END AS [C5], 
    CASE WHEN ([Extent1].[NUM_REMESSA_REC] IS NOT NULL) THEN [Extent1].[NUM_REMESSA_REC] ELSE 0 END AS [C6], 
    [Extent1].[OBSERVACAO] AS [OBSERVACAO], 
    CASE WHEN ([Extent1].[NUM_DEPOSITO] IS NOT NULL) THEN [Extent1].[NUM_DEPOSITO] ELSE 0 END AS [C7], 
    [Extent1].[CHAVE_FATO_ORIG] AS [CHAVE_FATO_ORIG], 
    [Extent1].[CHAVE_FATO_CHEQUE] AS [CHAVE_FATO_CHEQUE], 
    [Extent1].[CHAVE_FATO_FATURA] AS [CHAVE_FATO_FATURA], 
    CASE WHEN ([Extent1].[VALOR_COTACAO] IS NOT NULL) THEN [Extent1].[VALOR_COTACAO] ELSE cast(0 as decimal(18)) END AS [C8], 
    [Extent1].[COD_BARRAS] AS [COD_BARRAS], 
    CASE WHEN ([Extent1].[VALOR_COTACAO_ORIGINAL] IS NOT NULL) THEN [Extent1].[VALOR_COTACAO_ORIGINAL] ELSE cast(0 as decimal(18)) END AS [C9], 
    CASE WHEN ([Extent1].[VALOR_ABATIMENTO] IS NOT NULL) THEN [Extent1].[VALOR_ABATIMENTO] ELSE cast(0 as decimal(18)) END AS [C10], 
    CASE WHEN ([Extent1].[VALOR_ACRESCIMO] IS NOT NULL) THEN [Extent1].[VALOR_ACRESCIMO] ELSE cast(0 as decimal(18)) END AS [C11], 
    CASE WHEN ([Extent1].[DATA_EMISSAO_ORIGINAL] IS NOT NULL) THEN [Extent1].[DATA_EMISSAO_ORIGINAL] ELSE '0001-01-01 00:00:00' END AS [C12], 
    [Extent1].[LINHA_DIGITAVEL] AS [LINHA_DIGITAVEL], 
    CASE WHEN ([Extent1].[DATA_HORA] IS NOT NULL) THEN [Extent1].[DATA_HORA] ELSE '2001-01-01 00:00:00' END AS [C13], 
    [Extent1].[COD_FORMA_CP] AS [COD_FORMA_CP], 
    [Extent1].[NOME_FORMA_CP] AS [NOME_FORMA_CP], 
    [Extent1].[COD_REDUZ_RESULTAD] AS [COD_REDUZ_RESULTAD], 
    [Extent1].[DESC_CONTA_RESULTADO] AS [DESC_CONTA_RESULTADO], 
    [Extent1].[COD_CARTEIRA] AS [COD_CARTEIRA], 
    [Extent1].[NOME_CARTEIRA] AS [NOME_CARTEIRA], 
    [Extent1].[COD_MOEDA] AS [COD_MOEDA], 
    [Extent1].[SIMBOLO_MOEDA] AS [SIMBOLO_MOEDA], 
    CASE WHEN ([Extent1].[COD_VENDEDOR] IS NOT NULL) THEN [Extent1].[COD_VENDEDOR] ELSE 0 END AS [C14], 
    [Extent1].[NOME_VENDEDOR] AS [NOME_VENDEDOR], 
	Supervisor_cad.Cod_Cadastro                         AS Supoervisor,
	Supervisor_cad.Nome_cadastro                        AS Nome_Supervisor,
    CASE WHEN ([Extent1].[COD_CLI_FOR] IS NOT NULL) THEN [Extent1].[COD_CLI_FOR] ELSE 0 END AS [C15], 
    CASE WHEN ( NOT (('' IS NULL) OR (( CAST(LEN('') AS int)) = 0))) THEN CASE WHEN (N'N' = '') THEN [Extent1].[NOME_CLI_FOR] ELSE [Extent1].[RAZAO_SOCIAL_CLI_FOR] END ELSE [Extent1].[NOME_CLI_FOR] END AS [C16], 
    CASE WHEN ([Extent1].[COD_FUNCIONARIO] IS NOT NULL) THEN [Extent1].[COD_FUNCIONARIO] ELSE 0 END AS [C17], 
    [Extent1].[NOME_FUNCIONARIO] AS [NOME_FUNCIONARIO], 
    [Extent1].[COD_GRUPO_ECONOMICO] AS [COD_GRUPO_ECONOMICO], 
    [Extent1].[NOME_GRUPO_ECONOMICO] AS [NOME_GRUPO_ECONOMICO]

    FROM	[SATKFRANGAO].[dbo].[VWATAK4NET_TITULOS_A_RECEBER] AS [Extent1]
			LEFT	join [SATKFRANGAO].[dbo].TbVendedor Vendedor_Sup
			on		[Extent1].[COD_VENDEDOR] = Vendedor_Sup.Cod_cadastro
			LEFT	join [SATKFRANGAO].[dbo].tbCadastroGeral Supervisor_cad
		    on		Supervisor_cad.Cod_cadastro = Vendedor_Sup.Cod_supervisor_vda
    WHERE ( NOT ([Extent1].[COD_DOCTO] LIKE 'AD%')) 
	  and ([Extent1].[STATUS_TITULO] = 'A')
GO


