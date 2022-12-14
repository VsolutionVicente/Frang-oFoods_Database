USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Slow_File_Growth]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_Slow_File_Growth]
AS
BEGIN
	SET NOCOUNT ON

		DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		
	
	declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 	

		
	
	if not exists(SELECT null FROM sys.TI_Database WHERE is_default = 1)
		return
	
							
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
	WHERE Nm_Alert = 'Slow File Growth'

	IF @Fl_Enable = 0
		RETURN

	DECLARE @Ds_Arquivo_Trace VARCHAR(500) = (SELECT [path] FROM sys.TI_Database WHERE is_default = 1);
	DECLARE @Index INT = PATINDEX('%\%', REVERSE(@Ds_Arquivo_Trace));
	DECLARE @Nm_Arquivo_Trace VARCHAR(500) = LEFT(@Ds_Arquivo_Trace, LEN(@Ds_Arquivo_Trace) - @Index) + '\log.trc';

	DECLARE @Dt_Referencia DATETIME = DATEADD(HOUR, @Vl_Parameter_2*-1, GETDATE())

	IF ( OBJECT_ID('tempdb..#Alert_File_Growth') IS NOT NULL ) 
		DROP TABLE #Alert_File_Growth

	SELECT DatabaseName AS Nm_Database,
		   [Filename],
		   (Duration / 1000000) AS Duration,
		   StartTime,
		   EndTime,
		   ROUND((IntegerData * 8.0 / 1024),2) AS Growth_Size,
		   ApplicationName,
		   HostName,
		   LoginName
	INTO #Alert_File_Growth
	FROM::fn_trace_gettable(@Nm_Arquivo_Trace, DEFAULT) A
	WHERE EventClass >= 92
		  AND EventClass <= 95
		  AND StartTime > @Dt_Referencia
		  AND ServerName = @@servername
		  AND ROUND((Duration / 1000000),2) >= @Vl_Parameter
	ORDER BY A.StartTime DESC;
	
	-- Do we have some slow growth?
	IF EXISTS( SELECT null FROM #Alert_File_Growth )
	BEGIN
			
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		select	TOP 50
				Nm_Database,
				ISNULL(CAST([Filename] AS VARCHAR), '-')		AS [File Name],
				ISNULL(CAST([Duration] AS VARCHAR), '-')		AS [Duration],
				ISNULL(CAST([StartTime] AS VARCHAR), '-')		AS [Start Time],
				ISNULL(CAST([EndTime] AS VARCHAR), '-')			AS [End Time],
				ISNULL(CAST([Growth_Size] AS VARCHAR), '-')		AS [Growth Size],
				ISNULL(CAST([ApplicationName] AS VARCHAR), '-') 	AS [Application],
				ISNULL(CAST([HostName] AS VARCHAR), '-')		AS [Host Name],
				ISNULL(CAST([LoginName] AS VARCHAR), '-')		AS [Login]
		INTO ##Email_HTML
		from #Alert_File_Growth	
		 
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
