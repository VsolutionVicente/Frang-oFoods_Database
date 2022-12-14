USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_VS_VendasVendedor]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[PS_VS_VendasVendedor] AS 
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

		IF (OBJECT_ID('tempdb..##Test') IS NOT NULL) DROP TABLE ##Test
		SELECT format(cast(Dt_Transacao as date),'dd/MM/yyyy','pt-BR') "Data Faturamento", 
				-- cast(COD_VENDEDOR as varchar) +'-'+ NOME_VENDEDOR as Vendedor,
				Cast(COD_CLIENTE as varchar) + '-' + NOME_CLIENTE as Cliente,
				NUM_DOCTO "Nota", 
				trim(casT(COD_PRODUTO as varchar)) +'-' +trim(NOME_PRODUTO) as Produto,	
				format(QTDE_PRI,'N','pt-br') KG,
				format(QTDE_AUX,'N','pt-br') Caixas,
				FORMAT(VlrUnitario, 'C', 'pt-br') "Vlr Unit",
				FORMAT(VALOR_LIQUIDO, 'C', 'pt-br') "Vlr Total"
			INTO ##Test
			FROM [dbo].[VW_VS_VENDAS] 
			WHERE Dt_Transacao >= CAST(DATEADD(D,-1,GETDATE()) AS DATE)
			and Cod_Vendedor = @vendedor

		IF (OBJECT_ID('tempdb..##Test2') IS NOT NULL) DROP TABLE ##Test2
		SELECT format(cast(Dt_Transacao as date),'dd/MM/yyyy','pt-BR') "Data Faturamento", 
		       cast(COD_VENDEDOR as varchar) +'-'+ NOME_VENDEDOR as Vendedor,
				format(sum(QTDE_PRI),'N','pt-br') KG,
				format(sum(QTDE_AUX),'N','pt-br') Caixas,
				FORMAT(sum(VALOR_LIQUIDO), 'C', 'pt-br') "Vlr Total"
			INTO ##Test2
			FROM [dbo].[VW_VS_VENDAS] 
			WHERE Dt_Transacao >= CAST(DATEADD(D,-1,GETDATE()) AS DATE)
			and Cod_Vendedor = @vendedor  
			group by Dt_Transacao,
			         COD_VENDEDOR,
					 NOME_VENDEDOR

		-- Transforma o conteúdo da query em HTML
		DECLARE @HTML VARCHAR(MAX)
		DECLARE @HTML1 VARCHAR(MAX)
		DECLARE @HTML2 VARCHAR(MAX)
 
		EXEC dbo.stpExporta_Tabela_HTML_Output
			@Ds_Tabela = '##Test', -- varchar(max)
			@Ds_Saida = @HTML1 OUTPUT, -- varchar(max)
			@Ds_Alinhamento = 'left', -- parâmetros: left, center e right
			@Ds_Header = @Assunto;

		EXEC dbo.stpExporta_Tabela_HTML_Output
			@Ds_Tabela = '##Test2', -- varchar(max)
			@Ds_Saida = @HTML2 OUTPUT, -- varchar(max)
			@Ds_Alinhamento = 'left' -- parâmetros: left, center e right
			--@Fl_Aplica_Estilo_Padrao = 0 -- Utilizar 0 se for utilizar a Procedure mais de 1x


			SET @HTML = 
			'</h2><br/><br/>' + ISNULL(@HTML1, '') + '
			<br/><br/>
			<h2>Total Vendas</h2><br/>' + ISNULL(@HTML2, '') + '
			<br/><br/>
			Em caso de dúvidas, favor entrar em contato com Departamento de Vendas<br/><br/>

			Atenciosamente,<br/>
			
			
			<br/><br/>
			<small>Para automatizar seus processos procure a Vsolution comercial@vsolution.com.br</small>			
			';

        set @Email = 'financeiro@frangaofoods.com.br;comercial@frangaofoods.com.br;alex.rodrigues@frangaofoods.com.br;'+ @c_email+';'+ @s_Email;

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
