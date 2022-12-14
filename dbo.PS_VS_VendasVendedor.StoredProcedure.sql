USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_VS_VendasVendedor]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PS_VS_VendasVendedor] AS 
BEGIN
	DECLARE @VENDEDOR INT 
	DECLARE @ASSUNTO VARCHAR(150)
	DECLARE @NOME  VARCHAR(100)
	Declare @Email nvarchar(max) 
	Declare @c_Email nvarchar(max)
	Declare @s_Email nvarchar(max)
 
	-- Cursor para percorrer os registros
	DECLARE cursor1 CURSOR FOR
		select distinct 
			   COD_VENDEDOR, 
			   NOME_VENDEDOR,
			   Email_Vendedor,
			   coalesce(Email_Supervisor,'') Email_Supervisor
		  from [dbo].[VW_VS_VENDAS] 
		  where Dt_Transacao >= CAST(DATEADD(D,-1,GETDATE()) AS DATE)
	--Abrindo Cursor
	OPEN cursor1
	-- Lendo a próxima linha
	FETCH NEXT FROM cursor1 INTO @VENDEDOR, @NOME, @c_Email,@s_Email
 
	-- Percorrendo linhas do cursor (enquanto houverem)
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ASSUNTO = 'Vendas de : ' + CASt(@vendedor AS VARCHAR) + '-' + @NOME + ' - de '+ 
		               cast(Format(CAST(DATEADD(D,-1,GETDATE()) AS DATE),'dd/MM/yyyy','pt-BR')as varchar) ;

		IF (OBJECT_ID('tempdb..##Teste') IS NOT NULL) DROP TABLE ##Teste
		SELECT format(cast(Dt_Transacao as date),'dd/MM/yyyy','pt-BR') "Data Faturamento", 
				-- cast(COD_VENDEDOR as varchar) +'-'+ NOME_VENDEDOR as Vendedor,
				Cast(COD_CLIENTE as varchar) + '-' + NOME_CLIENTE as Cliente,
				NUM_DOCTO "Nota", 
				trim(casT(COD_PRODUTO as varchar)) +'-' +trim(NOME_PRODUTO) as Produto,	
				format(QTDE_PRI,'N','pt-br') KG,
				format(QTDE_AUX,'N','pt-br') Caixas,
				FORMAT(VlrUnitario, 'C', 'pt-br') "Vlr Unit",
				FORMAT(VALOR_LIQUIDO, 'C', 'pt-br') "Vlr Total"
			INTO ##Teste
			FROM [dbo].[VW_VS_VENDAS] 
			WHERE Dt_Transacao >= CAST(DATEADD(D,-1,GETDATE()) AS DATE)
			and Cod_Vendedor = @vendedor
  
		-- Transforma o conteúdo da query em HTML
		DECLARE @HTML VARCHAR(MAX)
 
		EXEC dbo.stpExporta_Tabela_HTML_Output
			@Ds_Tabela = '##Teste', -- varchar(max)
			@Ds_Saida = @HTML OUTPUT, -- varchar(max)
			@Ds_Alinhamento = 'left', -- parâmetros: left, center e right
			@Ds_Header = @Assunto;

        set @Email = 'financeiro@frangaofoods.com.br;comercial@frangaofoods.com.br;alex.rodrigues@frangaofoods.com.br;gleicicomercialfrangao@gmail.com;edivaldo.chr@frangaofoods.com.br;'+ @c_email+';'+ @s_Email;

		execute msdb.dbo.sp_send_dbmail
			@profile_name = 'TI_VSolution',
			@recipients = @Email, 
			@subject = @ASSUNTO ,
			@body = @HTML, -- nvarchar(max)
			@body_format = 'html';


		-- Lendo a próxima linha
		FETCH NEXT FROM cursor1 INTO @VENDEDOR, @NOME, @c_email, @s_Email
	END
 
	-- Fechando Cursor para leitura
	CLOSE cursor1
 
	-- Finalizado o cursor
	DEALLOCATE cursor1
end 
GO
