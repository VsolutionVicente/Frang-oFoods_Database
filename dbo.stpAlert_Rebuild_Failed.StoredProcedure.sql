USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Rebuild_Failed]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_Rebuild_Failed]
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
		@Vl_Parameter = Vl_Parameter,
		@Ds_Email = Ds_Email,
		@Fl_Language = Fl_Language,
		@Ds_Profile_Email = Ds_Profile_Email,
		@Vl_Parameter_2 = Vl_Parameter_2,	
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
	WHERE Nm_Alert = 'Rebuild Failed'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
		
	declare @Dt_Log datetime, @blocking_session_id int

	select top 1 @Dt_Log= Dt_Log, @blocking_session_id = blocking_session_id
	from Log_Whoisactive
	where Dt_Log >= dateadd(hh,-@Vl_Parameter,getdate())
		and blocking_session_id is not null
		and cast(sql_text as varchar(max)) like '%ALTER INDEX%'
	order by Dt_Log desc

	IF ( OBJECT_ID('tempdb..#Rebuild_Failed_By_Lock') IS NOT NULL )
		DROP TABLE #Rebuild_Failed_By_Lock

	select Dt_Log, 
		[dd hh:mm:ss.mss],
		database_name,
		session_id,
		blocking_session_id,
		cast(isnull(sql_text,sql_command) as varchar(max)) Query,
		login_name,
		wait_info,
		status,
		host_name,
		CPU,
		reads,
		writes,
		program_name,
		open_tran_count
	into #Rebuild_Failed_By_Lock
	from Log_Whoisactive	
	where Dt_Log = @Dt_Log	and (session_id = @blocking_session_id or blocking_session_id = @blocking_session_id)

	
	UPDATE #Rebuild_Failed_By_Lock
	SET Query = REPLACE( REPLACE( REPLACE( REPLACE( CAST(Query AS NVARCHAR(4000)), '<?query --', ''), '--?>', ''), '&gt;', '>'), '&lt;', '')
				

	IF EXISTS(SELECT null FROM #Rebuild_Failed_By_Lock)
	BEGIN
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		SELECT	
			CONVERT(VARCHAR(20), Dt_Log, 120) [Log Date], 
			[dd hh:mm:ss.mss] ,
			database_name [Database],
			session_id [Session ID],
			blocking_session_id [Blocking Session ID],
			Query,
			login_name [Login],
			wait_info [Wait Info],
			status [Status],
			host_name [Host Name],
			CPU,
			reads [Reads],
			writes [Writes],
			program_name [Program Name]
		INTO ##Email_HTML
		FROM #Rebuild_Failed_By_Lock
						 
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
			SET @Ds_Subject =  @Ds_Message_Alert_ENG+@@SERVERNAME 
		END		 

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)			
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[dd hh:mm:ss.mss] DESC',
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
