USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Database_Created]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_Database_Created]
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
	FROM dbo.Alert_Parameter 
	WHERE Nm_Alert = 'Database Created'
	
	IF @Fl_Enable = 0
		RETURN
		
	IF ( OBJECT_ID('tempdb..#Alert_Database_Created') IS NOT NULL ) 
		DROP TABLE #Alert_Database_Created
	
	SELECT	[database_id],
			[name], 
			[recovery_model_desc], 
			[create_date], 
			CASE WHEN [is_auto_close_on] = 0 THEN 'NÃO' ELSE 'SIM' END AS [is_auto_close_on], 
			CASE WHEN [is_auto_shrink_on] = 0 THEN 'NÃO' ELSE 'SIM' END AS [is_auto_shrink_on], 
			CASE WHEN [is_auto_create_stats_on] = 0 THEN 'NÃO' ELSE 'SIM' END AS [is_auto_create_stats_on], 
			CASE WHEN [is_auto_update_stats_on] = 0 THEN 'NÃO' ELSE 'SIM' END AS [is_auto_update_stats_on]
	INTO #Alert_Database_Created
	FROM [sys].[databases] WITH(NOLOCK)
	WHERE	[database_id] <> 2 -- "TempDb"
			AND [create_date] >= DATEADD(HOUR, -@Vl_Parameter, GETDATE())			
	
	--	Did we have a new database?
	IF EXISTS( SELECT null FROM #Alert_Database_Created )
	BEGIN

		IF (OBJECT_ID('tempdb..##Alerta_Database_Files') IS NOT NULL)
			DROP TABLE ##Alerta_Database_Files

		CREATE TABLE ##Alerta_Database_Files (
			[Nm_Database]		VARCHAR(100),
			[Logical_Name]		VARCHAR(100),
			[Size]				NUMERIC(15,2),
			[Total_Used]	NUMERIC(15,2),
			[Free_Space (MB)] NUMERIC(15,2),
			[Percent_Free] NUMERIC(15,2)
		)
		
		IF (OBJECT_ID('tempdb..#Alert_Database_Loop') IS NOT NULL)
			DROP TABLE #Alert_Database_Loop

		SELECT *
		INTO #Alert_Database_Loop
		FROM #Alert_Database_Created
		
		WHILE EXISTS (SELECT TOP 1 database_id FROM #Alert_Database_Loop)
		BEGIN
			DECLARE @DATABASE_ID INT = (SELECT MIN(database_id) FROM #Alert_Database_Loop)

			DECLARE @DB sysname = (SELECT DB_NAME(@DATABASE_ID))

			DECLARE @SQL VARCHAR(max) = 'USE [' + @DB +']' + CHAR(13) + 
			'
			;WITH cte_datafiles AS 
			(
			  SELECT name, size = size/128.0 FROM sys.database_files
			),
			cte_datainfo AS
			(
			  SELECT	name, CAST(size as numeric(15,2)) as size, 
						CAST( (CONVERT(INT,FILEPROPERTY(name,''SpaceUsed''))/128.0) as numeric(15,2)) as used, 
						free = CAST( (size - (CONVERT(INT,FILEPROPERTY(name,''SpaceUsed''))/128.0)) as numeric(15,2))
			  FROM cte_datafiles
			)

			INSERT INTO ##Alerta_Database_Files
			SELECT	DB_NAME(), name as [Logical_Name], size, used, free,
					percent_free = case when size <> 0 then cast((free * 100.0 / size) as numeric(15,2)) else 0 end
			FROM cte_datainfo
		    '
		               
			EXEC (@SQL )

			DELETE #Alert_Database_Loop
			WHERE database_id = @DATABASE_ID
		END

		IF (OBJECT_ID('tempdb..#Alert_Database_Created_Data_File') IS NOT NULL)
			DROP TABLE #Alert_Database_Created_Data_File

		SELECT	DB_NAME(A.database_id) AS [Nm_Database],
				[name] AS [Logical_Name],
				A.[physical_name] AS [Filename],
				B.[Size] AS [Total_Reserved],
				B.[Total_Used],
				B.[Free_Space (MB)] AS [Free_Space (MB)],
				B.[Percent_Free] AS [Free_Space (%)],
				CASE WHEN A.[Max_Size] = -1 THEN -1 ELSE (A.[Max_Size] / 1024) * 8 END AS [MaxSize(MB)], 
				CASE WHEN [is_percent_growth] = 1 
					THEN CAST(A.[Growth] AS VARCHAR) + ' %'
					ELSE CAST(CAST((A.[Growth] * 8 ) / 1024.00 AS NUMERIC(15, 2)) AS VARCHAR) + ' MB'
				END AS [Growth]
		INTO #Alert_Database_Created_Data_File
		FROM [sys].[master_files] A WITH(NOLOCK)	
		JOIN ##Alerta_Database_Files B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
		WHERE	A.[type_desc] <> 'FULLTEXT'
				and A.type = 0	-- (MDF and NDF)
								
		IF (OBJECT_ID('tempdb..#Alert_Database_Created_Log_File') IS NOT NULL)
			DROP TABLE #Alert_Database_Created_Log_File

		SELECT	DB_NAME(A.database_id) AS [Nm_Database],
				[name] AS [Logical_Name],
				A.[physical_name] AS [Filename],
				B.[Size] AS [Total_Reserved],
				B.[Total_Used],
				B.[Free_Space (MB)] AS [Free_Space (MB)],
				B.[Percent_Free] AS [Free_Space (%)],
				CASE WHEN A.[Max_Size] = -1 THEN -1 ELSE (A.[Max_Size] / 1024) * 8 END AS [MaxSize(MB)], 
				CASE WHEN [is_percent_growth] = 1 
					THEN CAST(A.[Growth] AS VARCHAR) + ' %'
					ELSE CAST(CAST((A.[Growth] * 8 ) / 1024.00 AS NUMERIC(15, 2)) AS VARCHAR) + ' MB'
				END AS [Growth]
		INTO #Alert_Database_Created_Log_File
		FROM [sys].[master_files] A WITH(NOLOCK)	
		JOIN ##Alerta_Database_Files B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
		WHERE	A.[type_desc] <> 'FULLTEXT'
				and A.type = 1	-- (LDF)
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		SELECT	[name] AS [Database], 
				[recovery_model_desc] AS [Recovery Model], 
				CONVERT(VARCHAR(20), [create_date], 120) AS [Create Date],
				[is_auto_close_on] AS [Is Auto Close On], 
				[is_auto_shrink_on] AS [Is Auto Shrink On], 
				[is_auto_create_stats_on] AS [Is Auto Create Stats On], 
				[is_auto_update_stats_on] AS [Is Auto Update Stats On]
		INTO ##Email_HTML
		FROM #Alert_Database_Created

		IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
			DROP TABLE ##Email_HTML_2

		SELECT 			[Nm_Database] [Database],
						File_Type [File Type],
						[Logical_Name] [Logical Name],
						[Total_Reserved] [Total Reserved], 
						[Total_Used] [Total Used],
						[Free_Space (MB)] [Free Space (MB)], 
						[Free_Space (%)] [Free Space (%)],
						[MaxSize(MB)] [MaxSize (MB)], 
						[Growth]
		INTO ##Email_HTML_2
		FROM (		SELECT	[Nm_Database],
						'Data' File_Type,
						[Logical_Name],
						CAST([Total_Reserved]	 AS VARCHAR) AS [Total_Reserved], 
						CAST([Total_Used]	 AS VARCHAR) AS [Total_Used],
						CAST([Free_Space (MB)] AS VARCHAR) AS [Free_Space (MB)], 
						CAST([Free_Space (%)]	 AS VARCHAR) AS [Free_Space (%)],
						CAST([MaxSize(MB)]		 AS VARCHAR) AS [MaxSize(MB)], 
						CAST([Growth]			 AS VARCHAR) AS [Growth]
				FROM #Alert_Database_Created_Data_File							
				UNION ALL	
				SELECT	[Nm_Database],
						'Log' File_Type,
						[Logical_Name],
						CAST([Total_Reserved]	 AS VARCHAR) AS [Total_Reserved], 
						CAST([Total_Used]	 AS VARCHAR) AS [Total_Used],
						CAST([Free_Space (MB)] AS VARCHAR) AS [Free_Space (MB)], 
						CAST([Free_Space (%)]	 AS VARCHAR) AS [Free_Space (%)],
						CAST([MaxSize(MB)]		 AS VARCHAR) AS [MaxSize(MB)], 
						CAST([Growth]			 AS VARCHAR) AS [Growth]
				FROM #Alert_Database_Created_Log_File	 ) A					

				 
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
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 

		EXEC dbo.stpExport_Table_HTML_Output
				@Ds_Tabela = '##Email_HTML_2', -- varchar(max)
				@Ds_Alinhamento  = 'center',
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
	END -- END - ALERT
END
GO
