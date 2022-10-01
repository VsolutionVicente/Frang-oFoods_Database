CREATE or alter  VIEW [dbo].[VW_FF_VS_RelaFinaRemeCob] as

/*ERP*/
SELECT 
	    [RemessaCob].[NUM_REMESSA]				AS [NUM_REMESSA],
		[RemessaCob].[Cod_banco_caixa]          AS [Cod_carteira],
	    [RemessaCob].[NOME_CARTEIRA_REMESSA]	AS [CARTEIRA], 
		[TituloRece].Cod_cli_for                AS [COD_CLIENTE],
	    [TituloRece].[NOME_CLI_FOR]				AS [CLIENTE],
	    [TituloRece].[TITULO]					AS [TITULO], 
	    [TituloRece].[DATA_EMISSAO]				AS [DATA_EMISSAO], 
	    [TituloRece].[DATA_VENCTO]				AS [DATA_VENCTO], 
	    [RemessaCob].[VALOR_OCORRENCIA_REMESSA] AS [VALOR_REMESSA],
		[TituloRece].[VALOR_SALDO]				AS [VALOR_SALDO], 
	    [TituloRece].[VALOR_TITULO]				AS [VALOR_TITULO]
FROM	[SATKFRANGAO].[dbo].[VWATAK4NET_REMESSACOBRANCA] AS [RemessaCob]
		INNER JOIN	[SATKFRANGAO].[dbo].[VWATAK4NET_TITULOS_A_RECEBER] [TituloRece] 
		ON			[RemessaCob].[CHAVE_FATO_TITULO] = [TituloRece].[CHAVE_FATO_TITULO]
WHERE	[RemessaCob].[DATA_LOTE] >= dateadd(d,-90,cast(getdate() as date))
AND		[RemessaCob].[OPERFIN] = 'TRECINC' 
union
/*SisATAK*/
SELECT TI.NUM_REMESSA                   as [NUM_REMESSA],
       C.COD_CADASTRO                   as [COD_CARTEIRA], 
	   C.NOME_CADASTRO                  as [CARTEIRA],
	   TC.COD_CADASTRO                  AS [COD_CLIENTE],
	   TC.NOME_CADASTRO                 as [CLIENTE],
       CAST(TI.COD_FILIAL AS VARCHAR) + '-' +
	   TR.COD_DOCTO   +'-' +
	   TR.SERIE_DOCTO +'-' +
	   [TI_DATABASE].[DBO].FN_ZERO(TR.NUM_DOCTO,6)+'-'+
	   CAST(TR.NUM_PARCELA AS VARCHAR)  as [TITULO],
	   TR.DATA_EMISSAO                  as [DATA_EMISSAO],	
	   TR.DATA_VENCTO                   as [DATA_VENCTO],
	   TI.VALOR_LIQUIDO                 as [VALOR_LIQUIDO],
	   TR.VALOR_SALDO                   as [VALOR_SALDO],
	   TR.VALOR_TITULO                  as [VALOR_TITULO]
FROM [SATKFRANGAO].[DBO].TBREMESSAITEMCOB TI 
INNER JOIN [SATKFRANGAO].[DBO].TBTITULOREC TR ON TI.CHAVE_FATO = TR.CHAVE_FATO
INNER JOIN [SATKFRANGAO].[DBO].TBCADASTROGERAL TC ON TR.COD_CLIENTE=TC.COD_CADASTRO
INNER JOIN [SATKFRANGAO].[DBO].TBCADASTROGERAL C ON  TR.COD_BANCO_CAIXA=C.COD_CADASTRO
WHERE TR.DATA_EMISSAO >= DATEADD(D,-90,CAST(GETDATE() AS DATE))
GO


create function fn_zero(@codigo Int, @quantidade int)
returns varchar(20)
as
begin
return ( replicate('0',(@quantidade - len(cast(@Codigo as varchar)))) + cast(@Codigo as Varchar))
end

 
CREATE OR ALTER VIEW VW_FF_VS_RelaFinaRemeCob as
SELECT 
	    [RemessaCob].[NUM_REMESSA]				AS [NUM_REMESSA],
	    [RemessaCob].[NOME_CARTEIRA_REMESSA]	AS [CARTEIRA], 
	    [TituloRece].[NOME_CLI_FOR]				AS [CLIENTE],
	    [TituloRece].[TITULO]					AS [TITULO], 
	    [TituloRece].[DATA_EMISSAO]				AS [DATA_EMISSAO], 
	    [TituloRece].[DATA_VENCTO]				AS [DATA_VENCTO], 
	    [RemessaCob].[VALOR_OCORRENCIA_REMESSA] AS [VALOR_REMESSA],
		[TituloRece].[VALOR_SALDO]				AS [VALOR_SALDO], 
	    [TituloRece].[VALOR_TITULO]				AS [VALOR_TITULO]
FROM	[SATKFRANGAO].[dbo].[VWATAK4NET_REMESSACOBRANCA] AS [RemessaCob]
		INNER JOIN	[SATKFRANGAO].[dbo].[VWATAK4NET_TITULOS_A_RECEBER] [TituloRece] 
		ON			[RemessaCob].[CHAVE_FATO_TITULO] = [TituloRece].[CHAVE_FATO_TITULO]
WHERE	[RemessaCob].[DATA_LOTE] >= dateadd(d,-90,cast(getdate() as date))
AND		[RemessaCob].[OPERFIN] = 'TRECINC' 


select * from VW_FF_VS_RelaFinaRemeCob