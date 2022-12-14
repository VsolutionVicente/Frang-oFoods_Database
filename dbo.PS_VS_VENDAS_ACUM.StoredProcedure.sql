USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_VS_VENDAS_ACUM]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[PS_VS_VENDAS_ACUM]
as
begin
	SET LANGUAGE Português;
	IF (OBJECT_ID('tempdb..##Teste') IS NOT NULL) DROP TABLE ##Teste
	SELECT cast(COD_VENDEDOR as varchar) +'-'+ NOME_VENDEDOR as Vendedor,
		   format(sum(QTDE_PRI),'N','pt-br') KG,
		   format(Sum(QTDE_AUX),'N0','pt-br') Caixas,
		   FORMAT(sum(VALOR_LIQUIDO)/sum(QTDE_PRI), 'C', 'pt-br') "MIX",
		   FORMAT(sum(VALOR_LIQUIDO), 'C', 'pt-br') "Vlr Total"
	  INTO ##Teste
	  FROM [dbo].[VW_VS_VENDAS] 
	 WHERE month(Dt_Transacao) = month(DATEADD(D,-1,GETDATE()))
	   and YEAR(Dt_Transacao) = Year(DATEADD(D,-1,GETDATE()))
	 group by COD_VENDEDOR,
			  NOME_VENDEDOR 
	 order by COD_VENDEDOR

	 -- Transforma o conteúdo da query em HTML
	DECLARE @HTML VARCHAR(MAX)
	declare @assunto varchar(100)

	select  @assunto = 'Vendas do Mês: ' +  DATENAME (m,DATEADD(D,-1,GETDATE()))+'/'+cast(year(DATEADD(D,-1,GETDATE())) as varchar) 
	EXEC dbo.stpExporta_Tabela_HTML_Output
		@Ds_Tabela = '##Teste',   -- varchar(max)
		@Ds_Saida = @HTML OUTPUT, -- varchar(max)
		@Ds_Alinhamento = 'left'  -- parâmetros: left, center e right


	execute msdb.dbo.sp_send_dbmail
		@profile_name = 'TI_VSolution',
		@recipients = 'luis.vicente@vsolution.com.br; financeiro@frangaofoods.com.br; gleicicomercialfrangao@gmail.com;edivaldo.chr@frangaofoods.com.br;a10@frangaofoods.com.br;p10@frangaofoods.com.br;w20@frangaofoods.com.br',
		@subject = @assunto   ,
		@body = @HTML, 
		@body_format = 'html'
end;
GO
