USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_CPU_Utilization_MI]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[dbo].[stpWhoIsActive_Result]
CREATE PROCEDURE [dbo].[stpAlert_CPU_Utilization_MI]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		

	declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 

	
	--IF  OBJECT_ID('tempdb..##WhoIsActive_Result')	IS NULL
	--	return
					
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
	FROM [TI_Databse].[dbo].Alert_Parameter 
	WHERE Nm_Alert = 'CPU Utilization MI'
	
			
	IF @Fl_Enable = 0
		RETURN

	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		

	--------------------------------------------------------------------------------------------------------------------------------
	-- CPU Utilization
	--------------------------------------------------------------------------------------------------------------------------------	
	IF ( OBJECT_ID('tempdb..#CPU_Utilization') IS NOT NULL )
		DROP TABLE #CPU_Utilization
	
	
	DECLARE @Top INT
    SET @Top =  4 * @Vl_Parameter_2 -- 1 minute = 4 rows

	SELECT TOP (@Top) A.*
	INTO #CPU_Utilization
	FROM master.sys.server_resource_stats A 
	WHERE A.start_time >= DATEADD(MINUTE,-15,GETDATE()) --6 minutes of delay from MI
	ORDER BY start_time desc
		
	--	Do we have CPU problem?	
	IF (
			SELECT COUNT(*)
			FROM #CPU_Utilization
			WHERE avg_cpu_percent > @Vl_Parameter
		) = @Top
	BEGIN	
			IF ISNULL(@Fl_Type, 0) = 0	-- Control Alert/Clear
			BEGIN
				IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
					DROP TABLE ##Email_HTML
						
				SELECT ISNULL(CONVERT(VARCHAR(20), GETDATE(), 120), '-')  [Alert Time],ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-')  [Log Azure Time],
					resource_name [Resource],sku,virtual_core_count [vCores],avg_cpu_percent [** CPU (%) **],io_requests [IO Request],io_bytes_read [IO bytes Read],io_bytes_written [IO Bytes Written]
				INTO ##Email_HTML
				FROM #CPU_Utilization
							
			
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
				@Ds_Tabela = '##Email_HTML',	
				@Ds_Alinhamento  = 'center',
				@Ds_OrderBy = '[Log Azure Time] DESC',
				
				@Ds_Saida = @HTML OUT	

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

			EXEC [msdb].[dbo].[sp_send_dbmail]
					@profile_name = @Ds_Profile_Email,
					@recipients =	@Ds_Email,
					@subject =		@Ds_Subject,
					@body =			@Final_HTML,
					@body_format =	'HTML',
					@importance =	'High'									
		
			-- Fl_Type = 1 : ALERT	
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		END
	END		-- END - ALERT
	
	ELSE 
	BEGIN	-- BEGIN - CLEAR				
		IF @Fl_Type = 1
		BEGIN			
			
			IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR
											
				SELECT ISNULL(CONVERT(VARCHAR(20), GETDATE(), 120), '-')  [Alert Time],ISNULL(CONVERT(VARCHAR(20), [start_time], 120), '-')  [Log Azure Time],
					resource_name [Resource],sku,virtual_core_count [vCores],avg_cpu_percent [** CPU (%) **],io_requests [IO Request],io_bytes_read [IO bytes Read],io_bytes_written [IO Bytes Written]
				INTO ##Email_HTML_CLEAR
				FROM #CPU_Utilization
											
			
				IF ( OBJECT_ID('tempdb..##Email_HTML_CLEAR_2') IS NOT NULL )
					DROP TABLE ##Email_HTML_CLEAR_2	
				 	
				SELECT TOP 50 *
				INTO ##Email_HTML_CLEAR_2
				FROM ##WhoIsActive_Result
			
				 
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
				@Ds_OrderBy = '[Log Azure Time] DESC',
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

			EXEC [msdb].[dbo].[sp_send_dbmail]
					@profile_name = @Ds_Profile_Email,
					@recipients =	@Ds_Email,
					@subject =		@Ds_Subject,
					@body =			@Final_HTML,
					@body_format =	'HTML',
					@importance =	'High'			
			
			-- Fl_Type = 0 : CLEAR
			INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
			SELECT @Id_Alert_Parameter, @Ds_Subject, 0		
		END		
	END		-- END - CLEAR	

END

GO
