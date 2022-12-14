USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_IO_Pending]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_IO_Pending]
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
	WHERE Nm_Alert = 'IO Pending'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	SELECT DB_NAME(mf.database_id) AS [Database]
			, mf.physical_name [Physical Name]
			, r.io_pending [IO Pending]
			, r.io_pending_ms_ticks [IO Pending (ms)]
			, r.io_type [IO Type]
			, fs.num_of_reads [Number of Reads]
			, fs.num_of_writes [Number of Writes]
			, GETDATE() [Data]
	INTO #Disk_Result
	FROM sys.dm_io_pending_io_requests AS r
	INNER JOIN sys.dm_io_virtual_file_stats(null,null) AS fs
	ON r.io_handle = fs.file_handle 
	INNER JOIN sys.master_files AS mf
	ON fs.database_id = mf.database_id
	AND fs.file_id = mf.file_id

	insert into Log_IO_Pending([Nm_Database], [Physical_Name], [IO_Pending], [IO_Pending_ms], [IO_Type], [Number_Reads], [Number_Writes], [Dt_Log])
	select * from #Disk_Result

	delete from #Disk_Result
	WHERE [IO Pending (ms)] < @Vl_Parameter*1000
		
	IF EXISTS( SELECT TOP 1 null FROM #Disk_Result )
	BEGIN

		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
				DROP TABLE ##Email_HTML

		SELECT TOP 50 [Database],[Physical Name],[IO Pending],[IO Pending (ms)],[IO Type],[Number of Reads],[Number of Writes],CONVERT(VARCHAR(20), [Data], 120) [Data]
		INTO ##Email_HTML
		FROM #Disk_Result
	
		 
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
			@Ds_OrderBy = '[IO Pending (ms)] desc',
			@Ds_Saida = @HTML OUT				-- varchar(max)
					
		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 	

		IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
			DROP TABLE ##Email_HTML_2	
				 	
		SELECT TOP 50 *
		INTO ##Email_HTML_2
		FROM ##WhoIsActive_Result

				
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
END



GO
