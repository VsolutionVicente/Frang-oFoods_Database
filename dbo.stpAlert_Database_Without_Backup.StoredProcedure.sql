USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Database_Without_Backup]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stpAlert_Database_Without_Backup] 
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
	WHERE Nm_Alert = 'Database Without Backup'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	-- Verifica a Quantidade Total de Databases
	IF ( OBJECT_ID('tempdb..#Alert_All_databases') IS NOT NULL )
		DROP TABLE #Alert_All_databases

	SELECT [name] AS [Nm_Database]
	INTO #Alert_All_databases
	FROM [sys].[databases] A
		LEFT JOIN [dbo].[Ignore_Databases] B ON A.[name] = B.[Nm_Database]
	WHERE	[name] NOT IN ('tempdb', 'ReportServerTempDB') 
			AND state_desc <> 'OFFLINE'
			and B.[Nm_Database] IS NULL

	-- Verifica a Quantidade de Databases que tiveram Backup nas ultimas 14 horas
	IF ( OBJECT_ID('tempdb..#Alert_Databases_With_Backup') IS NOT NULL)
		DROP TABLE #Alert_Databases_With_Backup

	SELECT DISTINCT [database_name] AS [Nm_Database]
	INTO #Alert_Databases_With_Backup
	FROM [msdb].[dbo].[backupset] B
	JOIN [msdb].[dbo].[backupmediafamily] BF ON B.[media_set_id] = BF.[media_set_id]
	WHERE	[backup_start_date] >= DATEADD(hh, -@Vl_Parameter, GETDATE())
			AND [type] IN ('D','I')

		-- Databases que não tiveram Backup
	IF ( OBJECT_ID('tempdb..#Alert_Databases_Without_Backup') IS NOT NULL )
		DROP TABLE #Alert_Databases_Without_Backup
		
	SELECT A.[Nm_Database]
	INTO #Alert_Databases_Without_Backup
	FROM #Alert_All_databases A WITH(NOLOCK)
	LEFT JOIN #Alert_Databases_With_Backup B WITH(NOLOCK) ON A.[Nm_Database] = B.[Nm_Database]
	WHERE B.[Nm_Database] IS NULL
	
	--	Do we have backups?
	IF EXISTS	(	SELECT TOP 1 [Nm_Database] FROM #Alert_Databases_Without_Backup)
	BEGIN	-- BEGIN - ALERT
	
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML
					
		-- Databases without Backups
		SELECT [Nm_Database] [Database]
		INTO ##Email_HTML
		FROM #Alert_Databases_Without_Backup
	
						 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB),'###1',@Vl_Parameter)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Vl_Parameter)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG),'###1',@Vl_Parameter)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Vl_Parameter)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Database]',
			@Ds_Saida = @HTML OUT				-- varchar(max)

	
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link	

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		
	END		-- END - ALERT
	
END

GO
