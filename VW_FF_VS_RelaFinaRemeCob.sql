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