CREATE or ALTER   PROCEDURE [dbo].[PS_VS_ComissaoGerencia] 
		(@ID INT = 0)
AS 
BEGIN
	DECLARE @CodVendedor     INT 
	DECLARE @CodSupervisor   INT 
	DECLARE @ASSUNTO         VARCHAR(150)
	DECLARE @Vendedor        VARCHAR(100)
	DECLARE @Supervisor      VARCHAR(100)
	Declare @Emailvendedor   nvarchar(max) 
	Declare @EmailSupervisor nvarchar(max) 
	Declare @Email           nvarchar(max)
	
	IF (OBJECT_ID('tempdb..##Test') IS NOT NULL) DROP TABLE ##Test;

	IF (OBJECT_ID('tempdb..##Test1') IS NOT NULL) DROP TABLE ##Test1;
	
	IF (OBJECT_ID('tempdb..##Test2') IS NOT NULL) DROP TABLE ##Test2;

	select 'Total Geral ' Total,
			format(sum(Valor_lancto_moeda),    'C','pt-br')  as "Valor da Venda",
			format(sum(Comissao),              'C','pt-br')  as "Valor da Comissão"
			INTO ##Test
		from [dbo].[VW_FF_Comissao] 
		where month(Data_lancto) =  MONTH(dateadd(m,-1,getdate()))
		and year(Data_lancto) = year(dateadd(m,-1,getdate())) 
		and Perc_Comissao_Fixo >0;

	select Supervisor,
			format(sum(Valor_lancto_moeda),    'C','pt-br')  as "Valor da Venda",
			format(sum(Comissao),              'C','pt-br')  as "Valor da Comissão"
			INTO ##Test1
		from [dbo].[VW_FF_Comissao] 
		where month(Data_lancto) =  MONTH(dateadd(m,-1,getdate()))
		and year(Data_lancto) = year(dateadd(m,-1,getdate())) 
		and Perc_Comissao_Fixo >0
		group by 
		    Supervisor
	Order by 		   
			Supervisor;
			
	select Supervisor,
			Nome_vendedor                                    as Vendedor,
			format(sum(Valor_lancto_moeda),    'C','pt-br')  as "Valor da Venda",
			format(avg(Perc_Comissao_Fixo/100),'P','pt-br')  as "% Comissão",
			format(sum(Comissao),              'C','pt-br')  as "Valor da Comissão"
			INTO ##Test2
		from [dbo].[VW_FF_Comissao] 
		where month(Data_lancto) =  MONTH(dateadd(m,-1,getdate()))
		and year(Data_lancto) = year(dateadd(m,-1,getdate())) 
		and Perc_Comissao_Fixo >0
		group by 
		    Supervisor,
			Nome_vendedor
	Order by 		   
			Supervisor,
			Nome_vendedor

		-- Transforma o conteúdo da query em HTML
		DECLARE @HTML VARCHAR(MAX)
		DECLARE @HTML1 VARCHAR(MAX)
		DECLARE @HTML2 VARCHAR(MAX)
		DECLARE @HTML3 VARCHAR(MAX)

		EXEC dbo.stpExporta_Tabela_HTML_Output
			@Ds_Tabela = '##Test', -- varchar(max)
			@Ds_Saida = @HTML1 OUTPUT, -- varchar(max)
			@Ds_Alinhamento = 'left'; -- parâmetros: left, center e right
			--@Ds_Header = @Assunto;
			--@Fl_Aplica_Estilo_Padrao = 0 -- Utilizar 0 se for utilizar a Procedure mais de 1x

		EXEC dbo.stpExporta_Tabela_HTML_Output
			@Ds_Tabela = '##Test1', -- varchar(max)
			@Ds_Saida = @HTML2 OUTPUT, -- varchar(max)
			@Ds_Alinhamento = 'left'; -- parâmetros: left, center e right
			-- @Fl_Aplica_Estilo_Padrao = 0 -- Utilizar 0 se for utilizar a Procedure mais de 1x
 
		EXEC dbo.stpExporta_Tabela_HTML_Output
			@Ds_Tabela = '##Test2', -- varchar(max)
			@Ds_Saida = @HTML3 OUTPUT, -- varchar(max)
			@Ds_Alinhamento = 'left'; -- parâmetros: left, center e right
			--@Fl_Aplica_Estilo_Padrao = 0 -- Utilizar 0 se for utilizar a Procedure mais de 1x

			SET @HTML = 
			'<h1>Total Vendas e Comissão</h1>
			 </h2><br/><br/>' + ISNULL(@HTML1, '') + '
			<br/><br/>
			<h1>Total por Supervisor</h1>
			</h2><br/><br/>' + ISNULL(@HTML2, '') + '
			<br/><br/>
			<h1>Total por Supervisor & Vendedor </h1>
			</h2><br/><br/>' + ISNULL(@HTML3, '') + '
			<br/><br/>
			Em caso de dúvidas, favor entrar em contato com Departamento de Vendas<br/><br/>
			Atenciosamente,<br/>
			';

        if (@id = 0) 
		Begin
			set @Email ='luis.vicente@vsolution.com.br;financeiro@frangaofoods.com.br';
		end 
		else 
		begin
			set @Email ='financeiro@frangaofoods.com.br;financeiro3@frangaofoods.com.br;edivaldo.chr@frangaofoods.com.br;p10@frangaofoods.com.br;alex.rodrigues@frangaofoods.com.br;';
		end;
		
		execute msdb.dbo.sp_send_dbmail
			@profile_name = 'TI_VSolution',
			@recipients = @Email, 
			@subject = @ASSUNTO ,
			@body = @HTML, -- nvarchar(max)
			@body_format = 'html';
end 
GO


[dbo].[PS_VS_ComissaoGerencia] 0
