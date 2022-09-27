USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_SQLServer_Connection]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************************************************
--	ALERTA: CONEXAO SQL SERVER
*******************************************************************************************************************************/

CREATE PROCEDURE [dbo].[stpAlert_SQLServer_Connection]
AS
BEGIN
	SET NOCOUNT ON
	    
	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		
		
	declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 	
	

					
	-- Alert information
	SELECT @Id_Alert_Parameter = Id_Alert_Parameter, 
		@Fl_Enable = Fl_Enable, 
		@Vl_Parameter = Vl_Parameter,		-- Minutes,
		@Ds_Email = Ds_Email,
		@Fl_Language = Fl_Language,
		@Ds_Profile_Email = Ds_Profile_Email,
		@Vl_Parameter_2 = Vl_Parameter_2,		--minute
		@Dt_Now = GETDATE(),
		@Ds_Message_Alert_ENG = Ds_Message_Alert_ENG,
		@Ds_Message_Clear_ENG = Ds_Message_Clear_ENG,
		@Ds_Message_Alert_PTB = Ds_Message_Alert_PTB,
		@Ds_Message_Clear_PTB = Ds_Message_Clear_PTB,
		@Ds_Email_Information_1_ENG = Ds_Email_Information_1_ENG,
		@Ds_Email_Information_2_ENG = Ds_Email_Information_2_ENG,
		@Ds_Email_Information_1_PTB = Ds_Email_Information_1_PTB,
		@Ds_Email_Information_2_PTB = Ds_Email_Information_2_PTB
	FROM [dbo].Alert_Parameter 
	WHERE Nm_Alert = 'SQL Server Connection'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )	


	DECLARE @Qt_Connections SMALLINT
	SELECT @Qt_Connections = count(*) FROM sys.dm_exec_sessions WHERE session_id > 50

	--Did we have connection Problem?
	IF (@Qt_Connections > @Vl_Parameter)
	BEGIN					            
		IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
		BEGIN
			IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

			if object_id('tempdb..#Open_Connections') is not null
				drop table #Open_Connections

			SELECT	TOP 25 IDENTITY(INT, 1, 1) AS id, 
					replace(replace(ec.client_net_address,'<',''),'>','') client_net_address, 
					case when es.[program_name] = '' then 'Sem nome na string de conexão' else [program_name] end [program_name], 
					es.[host_name], es.login_name, /*db_name(database_id)*/ '' Base,
					COUNT(ec.session_id)  AS [connection count] 
			into #Open_Connections
			FROM sys.dm_exec_sessions AS es  
			INNER JOIN sys.dm_exec_connections AS ec ON es.session_id = ec.session_id   
			GROUP BY ec.client_net_address, es.[program_name], es.[host_name],/*db_name(database_id),*/ es.login_name  			
			order by [connection count] desc
					
			SELECT	client_net_address [Client Net Address], 
					[program_name] [Program Name], 
					[host_name] [Host Name], 
					login_name [Login Name], 
					Base AS [Database],
					[connection count] [Connection Count] --,id
			INTO ##Email_HTML
			FROM #Open_Connections
			
	
			IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_2
				FROM ##WhoIsActive_Result
	
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML', -- varchar(max)				
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Connection Count] DESC',
				@Ds_Saida = @HTML OUT				-- varchar(max)

			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		
				
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_2', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
				@Ds_Saida = @HTML OUT				-- varchar(max)			

			IF @Fl_Language = 1
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
			ELSE 
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)				

			-- Second Result
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link			

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'									
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1	
		END		
	END		-- END - ALERT
	ELSE 
	BEGIN	-- BEGIN - CLEAR	 
		IF @Fl_Type = 1
		BEGIN
	
			if object_id('tempdb..#Open_Connections_Clear') is not null
				drop table #Open_Connections_Clear

			SELECT	top 25 IDENTITY(INT, 1, 1) AS id, 
					replace(replace(ec.client_net_address,'<',''),'>','') client_net_address, 
					case when es.[program_name] = '' then 'Without a Name' else [program_name] end [program_name], 
					es.[host_name], es.login_name, /*db_name(database_id)*/ '' Base,
					COUNT(ec.session_id)  AS [connection count] 
			into #Open_Connections_Clear
			FROM sys.dm_exec_sessions AS es  
			INNER JOIN sys.dm_exec_connections AS ec  
			ON es.session_id = ec.session_id   
			GROUP BY ec.client_net_address, es.[program_name], es.[host_name],/*db_name(database_id),*/ es.login_name  			
			order by [connection count] desc
		
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR

			SELECT	client_net_address [Client Net Address], 
					[program_name] [Program Name], 
					[host_name] [Host Name], 
					login_name [Login Name], 
					Base AS [Database],
					cast([connection count] as varchar) [Connection Count] --,id
			INTO ##Email_HTML_CLEAR
			FROM #Open_Connections_Clear 
			ORDER BY id 
			
		IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_CLEAR_2
				FROM ##WhoIsActive_Result
				ORDER BY [dd hh:mm:ss.mss] DESC 
				 
			-- Get HTML Informations
			SELECT @Company_Link = Company_Link,
				@Line_Space = Line_Space,
				@Header_Default = Header
			FROM HTML_Parameter
			

			IF @Fl_Language = 1 --Portuguese
			BEGIN
				 SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				 SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
			END
           ELSE 
		   BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Clear_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		   END		   		

			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Connection Count] DESC',
				@Ds_Saida = @HTML OUT				-- varchar(max)

			-- First Result
			SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		
				
			EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_CLEAR_2', -- varchar(max)
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[dd hh:mm:ss.mss] desc',
				@Ds_Saida = @HTML OUT				-- varchar(max)			

			IF @Fl_Language = 1
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_PTB)
			ELSE 
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_2_ENG)				

			-- Second Result
			SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space + @Company_Link			

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'		
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END
	END		-- END - CLEAR
END

GO
