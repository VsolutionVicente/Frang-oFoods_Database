USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Slow_Disk]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Chamar essa antes
--EXEC stpRead_Error_log 1 --@Actual_Log = 1 - most recent 
-- stpAlert_Slow_Disk 'Slow Disk Every Hour'
-- stpAlert_Slow_Disk 'Slow Disk'

CREATE PROCEDURE [dbo].[stpAlert_Slow_Disk] @Nm_Alert VARCHAR(100)
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
	WHERE Nm_Alert = @Nm_Alert

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF ( OBJECT_ID('tempdb..#Error_Log_IO') IS NOT NULL ) 
		DROP TABLE #Error_Log_IO

	CREATE TABLE #Error_Log_IO (
		[LogDate]		DATETIME,
		[Process Info]	NVARCHAR(50),
		[Text]			NVARCHAR(MAX)
	)

	-- Error Log
	INSERT INTO #Error_Log_IO
	SELECT *
	FROM ##Error_Log_Result
	WHERE [LogDate] >= DATEADD(hh,@Vl_Parameter*-1,GETDATE())  
		AND [Text] LIKE '%of I/O requests taking longer than 15 seconds%'
		AND DATEPART(HOUR, [LogDate]) >= 6 --ignore admin tasks execution time (you can change this)
		AND DATEPART(HOUR, [LogDate]) < 23
		
	IF EXISTS( SELECT * FROM #Error_Log_IO )
	BEGIN

		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

		SELECT	TOP 50
				Convert(VARCHAR(20),[LogDate],120) AS [Log Date],
				[Process Info], 
				[Text]
		INTO ##Email_HTML
		FROM #Error_Log_IO
	
		 
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
			@Ds_OrderBy = '[Log Date]',
			@Ds_Saida = @HTML OUT				-- varchar(max)
				
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link	


			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'							
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1											
		
	END
END

GO
