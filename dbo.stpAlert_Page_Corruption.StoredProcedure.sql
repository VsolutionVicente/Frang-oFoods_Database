USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Page_Corruption]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stpAlert_Page_Corruption] 
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
	WHERE Nm_Alert = 'Page Corruption'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF(OBJECT_ID('tempdb..#temp_Page_Corruption') IS NOT NULL) 
		DROP TABLE #temp_Page_Corruption

	SELECT SP.*
	INTO #temp_Page_Corruption
	FROM [msdb].[dbo].[suspect_pages] SP
	LEFT JOIN [dbo].Suspect_Pages_History HSP ON	SP.database_id = HSP.database_id AND SP.file_id = HSP.file_id
														AND SP.[page_id] = HSP.[page_id]
														AND CAST(SP.last_update_date AS DATE) = CAST(HSP.Dt_Corruption AS DATE)
	WHERE 	HSP.[page_id] IS NULL	
	
	

	IF EXISTS	(SELECT TOP 1 page_id FROM #temp_Page_Corruption)
	BEGIN	-- BEGIN - ALERT
	
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML
		
		SELECT	B.name AS [Database], 
				CAST(file_id AS VARCHAR) AS [File ID], 
				CAST(page_id AS VARCHAR) AS [Page ID], 
				CAST(event_type AS VARCHAR) AS [Event Type], 
				CAST(error_count AS VARCHAR) AS [Error Count],								
				CONVERT(VARCHAR(20), last_update_date, 120) AS [Last Update Date]
		INTO ##Email_HTML
		FROM #temp_Page_Corruption A
		JOIN [sys].[databases] B ON B.[database_id] = A.[database_id]								
										

				 
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  @Ds_Message_Alert_PTB + @@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  @Ds_Message_Alert_ENG + @@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)			
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Last Update Date]',
			@Ds_Saida = @HTML OUT				-- varchar(max)

	
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space + @Company_Link	

			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'							
		
		INSERT INTO [dbo].Suspect_Pages_History
		SELECT	[database_id] ,
				[file_id] ,
				[page_id] ,
				[event_type] ,
				[last_update_date]
		FROM #temp_Page_Corruption

		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			
		
	END		-- END - ALERT
	
END

GO
