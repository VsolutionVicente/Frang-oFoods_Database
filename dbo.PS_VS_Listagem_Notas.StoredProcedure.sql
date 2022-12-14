USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_VS_Listagem_Notas]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PS_VS_Listagem_Notas] AS 
BEGIN
	Declare @ASSUNTO VARCHAR(150)
	Declare @Email nvarchar(max) 
	Declare @DataInicial Date = (getdate()-10)


	IF (OBJECT_ID('tempdb..##Teste') IS NOT NULL) DROP TABLE ##Teste

	select ROW_NUMBER() over(order by Data_movto asc) Id,
	       format(Data_movto,'dd/MM/yyyy','pt-BR') "Data Movimento", 
		   min(Num_docto) "Primeira Nota",
		   Max(Num_docto) "Ultima Nota" 
   		   INTO ##Teste
     from (	        
			select Data_movto,
				   Num_docto
			 from [SATKFRANGAO].[dbo].tbSaidas 
			where Cod_docto = 'NE' 
			  and Data_movto >= @DataInicial
			union all 
			select Data_movto,
				   Num_docto
			 from  [SATKFRANGAO].[dbo].tbEntradas 
				 where Cod_docto = 'NE' 
			  and Data_movto >= @DataInicial
			) vw
			group by Data_movto
	  order by 1

  
	-- Transforma o conteúdo da query em HTML
	DECLARE @HTML VARCHAR(MAX)
 
	EXEC dbo.stpExporta_Tabela_HTML_Output
			@Ds_Tabela = '##Teste', -- varchar(max)
			@Ds_Saida = @HTML OUTPUT, -- varchar(max)
			@Ds_Alinhamento = 'left', -- parâmetros: left, center e right
			@Ds_Header = 'Numeração das Notas Eletrônicas dos ultimos 10 Dias';

        set @Email = 'luciana.muniz@frangaofoods.com.br;faturamento@frangaofoods.com.br;luis.vicente@vsolution.com.br'

		execute msdb.dbo.sp_send_dbmail
			@profile_name = 'TI_VSolution',
			@recipients = @Email, 
			@subject = @ASSUNTO ,
			@body = @HTML, -- nvarchar(max)
			@body_format = 'html';
end 
GO
