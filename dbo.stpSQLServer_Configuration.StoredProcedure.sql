USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpSQLServer_Configuration]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[stpSQLServer_Configuration]
AS
BEGIN


SET NOCOUNT ON

	DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		

	declare @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX) 	

	SET @Final_HTML = ''	
	
				
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
	WHERE Nm_Alert = 'SQL Server Configuration'
	
	IF @Fl_Enable = 0
		RETURN
		
	-- Get HTML Informations
	SELECT @Company_Link = Company_Link,
		@Line_Space = Line_Space,
		@Header_Default = Header
	FROM HTML_Parameter		

/***********************************************************************************************************************************
--	Read Error Log
***********************************************************************************************************************************/
	IF(OBJECT_ID('tempdb..#ErrorLogFiles') IS NOT NULL) DROP TABLE #ErrorLogFiles

	CREATE TABLE #ErrorLogFiles(
		Id_File INT,
		Dt_Creation VARCHAR(20),
		Size BIGINT
	)

	INSERT INTO #ErrorLogFiles
	EXEC sp_enumerrorlogs;


/***********************************************************************************************************************************
--	SQL Server Version
***********************************************************************************************************************************/
	
	IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
		DROP TABLE ##Email_HTML
						
	SELECT  @@VERSION AS [SQL Server Version] INTO ##Email_HTML
	

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Versão do SQL Server')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','SQL Server Version')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space		
	

/***********************************************************************************************************************************
--	Server Configuration
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_1') IS NOT NULL )
		DROP TABLE ##Email_HTML_1
		
	CREATE TABLE ##Email_HTML_1(
		[Configuration] VARCHAR(256) NULL,
		[Value] VARCHAR(256) NULL
	)

	INSERT INTO ##Email_HTML_1
	SELECT 'ServerName' AS [Ds_Configuration], CAST(SERVERPROPERTY('ServerName') AS VARCHAR(256)) AS [Ds_Value]  
	UNION
	SELECT 'InstanceName' AS [Ds_Configuration], CAST(ISNULL(SERVERPROPERTY('InstanceName'), SERVERPROPERTY('ServerName')) AS VARCHAR(256)) AS [Ds_Value]
	UNION
	SELECT 'IsClustered' AS [Ds_Configuration], CASE WHEN SERVERPROPERTY('IsClustered') = 0 THEN 'NÃO' ELSE 'sim' END AS [Ds_Value]
	UNION
	SELECT 'ComputerNamePhysicalNetBIOS' AS [Ds_Configuration], CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS VARCHAR(256)) AS [Ds_Value]
	UNION
	SELECT 'Collation' AS [Ds_Configuration], CAST(SERVERPROPERTY('Collation') AS VARCHAR(256)) AS [Ds_Value]
	UNION
	SELECT 'IsFullTextInstalled' AS [Ds_Configuration], CASE WHEN SERVERPROPERTY('IsFullTextInstalled') = 0 THEN 'NÃO' ELSE 'SIM' END AS [Ds_Value]
	UNION
	SELECT 'FilestreamConfiguredLevel' AS [Ds_Configuration], CASE WHEN SERVERPROPERTY('FilestreamConfiguredLevel') = 0 THEN 'NÃO' ELSE 'SIM' END AS [Ds_Value]
	UNION
	SELECT 'IsHadrEnabled' AS [Ds_Configuration], CASE WHEN SERVERPROPERTY('IsHadrEnabled') = 0 THEN 'NÃO' ELSE 'SIM' END AS [Ds_Value] 
	UNION
	SELECT 'InstanceDefaultDataPath' AS [Ds_Configuration], ISNULL(CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS VARCHAR(256)), '-') AS [Ds_Value]
	UNION
	SELECT 'InstanceDefaultLogPath' AS [Ds_Configuration], ISNULL(CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS VARCHAR(256)), '-') AS [Ds_Value]
	UNION
	SELECT 'Quantidade de Arquivos do Error Log' AS [Ds_Configuration], CAST(COUNT(*) AS VARCHAR) AS [Ds_Value] FROM #ErrorLogFiles
							 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Configurações do Servidor')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Server Configuration')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_1', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
				

/***********************************************************************************************************************************
--	Instance Configuration
***********************************************************************************************************************************/
					
	IF ( OBJECT_ID('tempdb..##Email_HTML_2') IS NOT NULL )
		DROP TABLE ##Email_HTML_2

	SELECT	name [Name], 
		CAST(value AS VARCHAR(20))			AS [Value],
		CAST(value_in_use AS VARCHAR(20))	AS [Value In Use],
		CAST(minimum AS VARCHAR(20))		AS [Minimum],
		CAST(maximum AS VARCHAR(20))		AS [Maximum],
		[description]
	INTO ##Email_HTML_2
	FROM sys.configurations WITH (NOLOCK)
	ORDER BY name

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Configurações da Instância')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Instance Configuration')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_2', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Name]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				

/***********************************************************************************************************************************
--	Disk Space
***********************************************************************************************************************************/
	DECLARE @OAP_Habilitado sql_variant

	SELECT	@OAP_Habilitado = value_in_use
	FROM sys.configurations WITH (NOLOCK)
	where name = 'Ole Automation Procedures'

	IF(OBJECT_ID('tempdb..#DiskSpace') IS NOT NULL) DROP TABLE #DiskSpace

		CREATE TABLE #DiskSpace (
			[Drive]				VARCHAR(50) ,
			[Size (MB)]		INT,
			[Used (MB)]		INT,
			[Free (MB)]		INT,
			[Free (%)]			INT,
			[Used (%)]			INT,
			[Used by SQL (MB)]	INT, 
			[Date]				SMALLDATETIME
		)
		
	IF (@OAP_Habilitado = 1)
	BEGIN	
		IF(OBJECT_ID('tempdb..#dbspace') IS NOT NULL) DROP TABLE #dbspace

		CREATE TABLE #dbspace (
			[Name]		SYSNAME,
			[Path]	VARCHAR(200),
			[Size]	VARCHAR(10),
			[Drive]		VARCHAR(30)
		)

	

		EXEC sp_MSforeachdb '	Use [?] 
								INSERT INTO #dbspace 
								SELECT	CONVERT(VARCHAR(25), DB_NAME())''Database'', CONVERT(VARCHAR(60), FileName),
										CONVERT(VARCHAR(8), Size/128) ''Size in MB'', CONVERT(VARCHAR(30), Name) 
								FROM [sysfiles]'

		DECLARE @hr INT, @fso INT, @size FLOAT, @TotalSpace INT, @MBFree INT, @Percentage INT, 
				@SQLDriveSize INT, @drive VARCHAR(1), @fso_Method VARCHAR(255), @mbtotal INT	
	
		set @mbtotal = 0

		EXEC @hr = [master].[dbo].[sp_OACreate] 'Scripting.FilesystemObject', @fso OUTPUT

		IF (OBJECT_ID('tempdb..#space') IS NOT NULL) 
			DROP TABLE #space

		CREATE TABLE #space (
			[drive] CHAR(1), 
			[mbfree] INT
		)
	
		INSERT INTO #space EXEC [master].[dbo].[xp_fixeddrives]
	
		DECLARE CheckDrives Cursor For SELECT [drive], [mbfree] 
		FROM #space
	
		Open CheckDrives
		FETCH NEXT FROM CheckDrives INTO @drive, @MBFree

		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			SET @fso_Method = 'Drives("' + @drive + ':").TotalSize'
		
			SELECT @SQLDriveSize = SUM(CONVERT(INT, Size)) 
			FROM #dbspace 
			WHERE SUBSTRING(Path, 1, 1) = @drive
		
			EXEC @hr = sp_OAMethod @fso, @fso_Method, @size OUTPUT
		
			SET @mbtotal = @size / (1024 * 1024)
		
			INSERT INTO #DiskSpace 
			VALUES(	@drive + ':', @mbtotal, @mbtotal-@MBFree, @MBFree, (100 * round(@MBFree, 2) / round(@mbtotal, 2)), 
					(100 - 100 * round(@MBFree,2) / round(@mbtotal, 2)), @SQLDriveSize, GETDATE())

			FETCH NEXT FROM CheckDrives INTO @drive, @MBFree
		END
		CLOSE CheckDrives
		DEALLOCATE CheckDrives
		
	END
							
	IF ( OBJECT_ID('tempdb..##Email_HTML_3') IS NOT NULL )
		DROP TABLE ##Email_HTML_3

	SELECT	[Drive], 
			CAST([Size (MB)] AS VARCHAR) AS [Size (MB)], 
			CAST([Used (MB)] AS VARCHAR) AS [Used (MB)], 
			CAST([Free (MB)] AS VARCHAR) AS [Free (MB)], 
			CAST([Used (%)] AS VARCHAR) AS [Used (%)], 
			CAST([Free (%)] AS VARCHAR) AS [Free (%)], 
			CAST([Used by SQL (MB)] AS VARCHAR) AS [Used by SQL (MB)]
	INTO ##Email_HTML_3
	FROM #DiskSpace
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Espaço em Disco no Servidor')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Server Disk Space')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_3', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Drive]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				

/***********************************************************************************************************************************
--	Trace Flags
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_4') IS NOT NULL )
		DROP TABLE ##Email_HTML_4
						
	CREATE TABLE ##Email_HTML_4(
		[Trace Flag] INT NULL,
		Status INT NULL,
		Global INT NULL,
		Session INT NULL
	)

	INSERT INTO ##Email_HTML_4
	EXEC ('DBCC TRACESTATUS (-1)')
											 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Trace Flags Habilitadas')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Enabled Trace Flag')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_4', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
			
------------------------------------------------------------------------------------------------------------------------------------
--	Jobs da Instância - BODY
------------------------------------------------------------------------------------------------------------------------------------
     IF ( OBJECT_ID('tempdb..##Email_HTML_5') IS NOT NULL )
		DROP TABLE ##Email_HTML_5

	SELECT 
		sj.name AS [Job Name],  
		SUSER_SNAME(sj.owner_sid) AS [Job Owner],
		CASE WHEN sj.[enabled] = 1 THEN 'SIM' ELSE 'NÃO' END AS [Enabled],
		ISNULL(op.name,'-') AS Operator,
		CONVERT(VARCHAR(20),sj.date_created,120) AS [Date Created],
		ISNULL(STUFF(STUFF(CAST(js.next_run_date as varchar),7,0,'-'),5,0,'-') + ' ' + 
				STUFF(STUFF(REPLACE(STR(js.next_run_time,6,0),' ','0'),5,0,':'),3,0,':'), '-') AS [Next Run],
		ISNULL(STUFF(STUFF(CAST(jh.run_date as varchar),7,0,'-'),5,0,'-') + ' ' + 
				STUFF(STUFF(REPLACE(STR(jh.run_time,6,0),' ','0'),5,0,':'),3,0,':'), '-') AS [Last Run],
		ISNULL(CASE	WHEN jh.[run_status] = 0 THEN 'Failed'
				WHEN jh.[run_status] = 1 THEN 'Succeeded'
				WHEN jh.[run_status] = 2 THEN 'Retry (step only)'
				WHEN jh.[run_status] = 3 THEN 'Cancelled'
				WHEN jh.[run_status] = 4 THEN 'In-progress message'
				WHEN jh.[run_status] = 5 THEN 'Unknown' 
		END, '-') [Status Last Execution]	
	INTO ##Email_HTML_5
	FROM msdb.dbo.sysjobs AS sj WITH (NOLOCK)
	INNER JOIN msdb.dbo.syscategories AS sc WITH (NOLOCK) ON sj.category_id = sc.category_id
	LEFT OUTER JOIN msdb.dbo.sysjobschedules AS js WITH (NOLOCK) ON sj.job_id = js.job_id
	LEFT JOIN (
			SELECT	j.job_id, MAX(instance_id) instance_id
			FROM msdb.dbo.sysjobs j 
			INNER JOIN msdb.dbo.sysjobhistory jh ON jh.job_id = j.job_id
			GROUP BY j.job_id
		) AS A ON sj.job_id = A.job_id
	LEFT JOIN msdb.dbo.sysjobhistory jh ON jh.instance_id = A.instance_id
	LEFT JOIN msdb.dbo.sysoperators op ON sj.notify_email_operator_id = op.id				    
	ORDER BY sj.name

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Jobs da Instância ')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','SQL Server Jobs')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_5', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Job Name]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				

/***********************************************************************************************************************************
--	SQL Server Alerts
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_6') IS NOT NULL )
		DROP TABLE ##Email_HTML_6
	
	CREATE TABLE ##Email_HTML_6(
		Name VARCHAR(256) NULL, 
		[Event Source] VARCHAR(256) NULL, 
		[Message ID] INT NULL,
		[Severity] INT NULL,
		[Enabled] VARCHAR(3) NULL
	)

	INSERT INTO ##Email_HTML_6
	SELECT name, event_source, message_id, severity, CASE WHEN [enabled] = 1 THEN 'SIM' ELSE 'NÃO' END AS [enabled]
	FROM msdb.dbo.sysalerts WITH (NOLOCK)
	ORDER BY name
	
	IF @@ROWCOUNT = 0
	BEGIN
																	 
		IF @Fl_Language = 1 --Portuguese
		BEGIN
					INSERT INTO ##Email_HTML_6
			SELECT 'Sem Alertas de severidade',NULL,NULL,NULL,null		
			END
		ELSE 
			BEGIN
						INSERT INTO ##Email_HTML_6
			SELECT 'Without Severity Alerts',NULL,NULL,NULL,null	
			END			

	END
															 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Alertas do SQL Server Agent')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','SQL Server Agent Alerts')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_6', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = 'Name',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
				
/***********************************************************************************************************************************
--	Error Log Files
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_7') IS NOT NULL )
			DROP TABLE ##Email_HTML_7
	
	SELECT	CAST(Id_File AS VARCHAR(20))	AS [File ID],
					Dt_Creation [Creation Date], 					
					CAST(Size AS VARCHAR(50))	AS Size
	INTO ##Email_HTML_7
	FROM #ErrorLogFiles WITH (NOLOCK)
	
															 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Arquivos do Error Log')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Error Log Files')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_7', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Creation Date] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				

/***********************************************************************************************************************************
--	Database Files
***********************************************************************************************************************************/

	IF (OBJECT_ID('tempdb..##MDFs_Sizes') IS NOT NULL)
		DROP TABLE ##MDFs_Sizes

	CREATE TABLE ##MDFs_Sizes (
		[Server]			VARCHAR(50),
		[Nm_Database]		VARCHAR(100),
		[Logical_Name]		VARCHAR(100),
		[Size]				NUMERIC(15,2),
		[Total_Used]	NUMERIC(15,2),
		[Free_Space (MB)] NUMERIC(15,2),
		[Free Space (%)] NUMERIC(15,2)
	)

	EXEC sp_MSforeachdb '
		Use [?]

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

			INSERT INTO ##MDFs_Sizes
			SELECT	@@SERVERNAME, DB_NAME(), name as [Logical_Name], size, used, free, percent_free = cast((free * 100.0 / size) as numeric(15,2))
			FROM cte_datainfo	
	'
	IF ( OBJECT_ID('tempdb..##Email_HTML_8') IS NOT NULL )
		DROP TABLE ##Email_HTML_8

	SELECT *
	INTO ##Email_HTML_8
	FROM (
		SELECT	1 AS ID,
						DB_NAME(A.database_id) AS [Database],
						[name] AS [Logical Name],
						CASE [file_id] WHEN 1 THEN 'MDF' WHEN 2 THEN 'LDF' ELSE 'NDF' END AS [Type], 		
						CAST(B.[Size] AS VARCHAR) AS [Total Reserved],
						CAST(B.[Total_Used] AS VARCHAR) AS [Total Used],
						CAST(B.[Free_Space (MB)] AS VARCHAR) AS [Free Space (MB)],
						CAST(B.[Free Space (%)] AS VARCHAR) AS [Free Space (%)],
						CAST(CASE WHEN A.[Max_Size] = -1 THEN -1 ELSE (A.[Max_Size] / 1024) * 8 END AS VARCHAR) AS [Max Size (MB)], 
						CASE WHEN [is_percent_growth] = 1 
							THEN CAST(A.[Growth] AS VARCHAR) + ' %'
							ELSE CAST(CAST((A.[Growth] * 8 ) / 1024.00 AS NUMERIC(15, 2)) AS VARCHAR) + ' MB'
						END AS [Growth],
						A.[physical_name] AS [Filename],
						A.file_id [File ID]
		FROM [sys].[master_files] A WITH(NOLOCK)	
			JOIN ##MDFs_Sizes B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
		UNION ALL
		SELECT	2 AS ID,
				'TOTAL' AS [Database],
				'-' AS [Logical Name],
				'-' AS [Type],
				CAST(SUM(B.[Size]) AS VARCHAR) AS [Total Reserved],
				CAST(SUM(B.[Total_Used]) AS VARCHAR) AS [Total Used],
				'-' AS [Free Space (MB)],
				'-' AS [Free Space (%)],
				'-' AS [Max Size (MB)], 
				'-' AS [Growth],
				'-' AS [Filename],
				'-' AS [File ID]
		FROM [sys].[master_files] A WITH(NOLOCK)	
			JOIN ##MDFs_Sizes B ON DB_NAME(A.[database_id]) = B.[Nm_Database] and A.[name] = B.[Logical_Name]
		) A
		ORDER BY 	ID, [Database], [File ID]	    
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Arquivos Databases')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Database File Informations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_8', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Database]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
							

/***********************************************************************************************************************************
--	I/O Operations
***********************************************************************************************************************************/

	IF ( OBJECT_ID('tempdb..##Email_HTML_9') IS NOT NULL )
		DROP TABLE ##Email_HTML_9
							
	SELECT  DB_NAME(fs.database_id) AS [Database Name] ,
			mf.physical_name AS [Physical Name],
			CAST(CAST(io_stall_read_ms / ( 1.0 + num_of_reads ) AS NUMERIC(10, 1)) AS VARCHAR) AS [AVG Read Stall (ms)] ,
			CAST(CAST(io_stall_write_ms / ( 1.0 + num_of_writes ) AS NUMERIC(10, 1)) AS VARCHAR) AS [AVG Write Stall (ms)] ,
			CAST(CAST(( io_stall_read_ms + io_stall_write_ms ) / ( 1.0 + num_of_reads
																+ num_of_writes ) AS NUMERIC(10,
																	1)) AS VARCHAR) AS [AVG IO Stall (ms)]
	INTO ##Email_HTML_9
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS fs
	INNER JOIN sys.master_files AS mf WITH ( NOLOCK ) ON fs.database_id = mf.database_id AND fs.[file_id] = mf.[file_id]		
								 

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações de Operações de I/O')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','I/O Operations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_9', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[AVG IO Stall (ms)] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
	
/***********************************************************************************************************************************
--	Log File Information
***********************************************************************************************************************************/
					
	IF ( OBJECT_ID('tempdb..##Email_HTML_10') IS NOT NULL )
		DROP TABLE ##Email_HTML_10

	SELECT	db.[name] AS [Database Name], db.recovery_model_desc AS [Recovery Model], db.state_desc [Status],  
					CONVERT(DECIMAL(18,2), ls.cntr_value/1024.0)  AS [Log Size (MB)], 
					CAST(CONVERT(DECIMAL(18,2), lu.cntr_value/1024.0) AS VARCHAR) AS [Log Used (MB)],
					CAST(CAST(plu.cntr_value as DECIMAL(18,2)) AS VARCHAR) AS [Log Used (%)], 
					CAST(db.[compatibility_level] AS VARCHAR) AS [DB Compatibility Level], 
					db.page_verify_option_desc AS [Page Verify Option], 
					CASE db.is_auto_close_on WHEN 0 THEN 'NÃO' ELSE 'SIM' END AS [Is Auto Close ON],
					CASE db.is_auto_shrink_on WHEN 0 THEN 'NÃO' ELSE 'SIM' END AS [Is Auto Shrink ON],
					CASE db.is_published WHEN 0 THEN 'NÃO' ELSE 'SIM' END AS [Is Published],
					CASE db.is_distributor WHEN 0 THEN 'NÃO' ELSE 'SIM' END AS [Is Distributor]
			INTO ##Email_HTML_10
			FROM sys.databases AS db WITH (NOLOCK)
			INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
			ON db.name = lu.instance_name
			INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
			ON db.name = ls.instance_name
			INNER JOIN sys.dm_os_performance_counters AS plu WITH (NOLOCK)
			ON db.name = plu.instance_name
			WHERE	lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
					AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
					AND plu.counter_name LIKE N'Percent Log Used%'
					--AND ls.cntr_value > 0	
	
	    												 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Arquivos Log (.LDF)')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Log File Information (.LDF)')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_10', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Log Size (MB)] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
			
/***********************************************************************************************************************************
--	Informações Virtual Log Files
***********************************************************************************************************************************/
	/* nao funciona no sql server 2008
	IF(OBJECT_ID('tempdb..#VLFInfo') IS NOT NULL) DROP TABLE #VLFInfo

	CREATE TABLE #VLFInfo (
		RecoveryUnitID int, FileID  int,
		FileSize bigint, StartOffset bigint,
		FSeqNo      bigint, [Status]    bigint,
		Parity      bigint, CreateLSN   numeric(38)
	)

	IF(OBJECT_ID('tempdb..#VLFCountResults') IS NOT NULL) DROP TABLE #VLFCountResults
	 
	CREATE TABLE #VLFCountResults(
		DatabaseName sysname, 
		VLFCount int
	)
	 
	EXEC sp_MSforeachdb N'Use [?]; 

					INSERT INTO #VLFInfo 
					EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
					INSERT INTO #VLFCountResults 
					SELECT DB_NAME(), COUNT(*) 
					FROM #VLFInfo; 

					TRUNCATE TABLE #VLFInfo;'
	 
	 					
	IF ( OBJECT_ID('tempdb..##Email_HTML_11') IS NOT NULL )
		DROP TABLE ##Email_HTML_11

	SELECT TOP 10	DatabaseName [Database], 
		VLFCount [Total VLF]
	INTO ##Email_HTML_11
	FROM #VLFCountResults
	
											 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Virtual Log File')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Virtual Log File Informations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_11', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Total VLF] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
*/


/***********************************************************************************************************************************
--	Informações Buffer Pool
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_12') IS NOT NULL )
		DROP TABLE ##Email_HTML_12
		
	IF ( OBJECT_ID('tempdb..#AggregateBufferPoolUsage') IS NOT NULL )
		DROP TABLE #AggregateBufferPoolUsage
		
	SELECT	DB_NAME(database_id) AS [Database],
			CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS CachedSize
	INTO #AggregateBufferPoolUsage
	FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
	WHERE database_id <> 32767 -- ResourceDB
	GROUP BY DB_NAME(database_id)	
	
	SELECT TOP 5
			[Database], 
			CAST(CachedSize AS VARCHAR) AS [Cached Size (MB)],
			CAST(CAST(CachedSize / SUM(CachedSize) OVER() * 100.0 AS DECIMAL(5,2)) AS VARCHAR) AS [Buffer Pool Percent]
	INTO ##Email_HTML_12
	FROM #AggregateBufferPoolUsage
	ORDER BY [Cached Size (MB)] DESC 
				    				
								 
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Buffer Pool')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Buffer Pool Informations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_12', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Cached Size (MB)] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		

	
/***********************************************************************************************************************************
--	Informações Waits Stats
***********************************************************************************************************************************/
	IF(OBJECT_ID('tempdb..#Waits') IS NOT NULL) DROP TABLE #Waits

	SELECT wait_type, wait_time_ms/ 1000.0 AS [WaitS],
			  (wait_time_ms - signal_wait_time_ms) / 1000.0 AS [ResourceS],
			   signal_wait_time_ms / 1000.0 AS [SignalS],
			   waiting_tasks_count AS [WaitCount],
			   100.0 *  wait_time_ms / SUM (wait_time_ms) OVER() AS [Percentage],
			   ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS [RowNum]
	INTO #Waits
	FROM sys.dm_os_wait_stats WITH (NOLOCK)
	WHERE [wait_type] NOT IN (
		N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
		N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
		N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
		N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
		N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
		N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
		N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT', 
		N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
		N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
		N'PWAIT_ALL_COMPONENTS_INITIALIZED', 
		N'PREEMPTIVE_OS_AUTHENTICATIONOPS', N'PREEMPTIVE_OS_CREATEFILE', N'PREEMPTIVE_OS_GENERICOPS',
		N'PREEMPTIVE_OS_LIBRARYOPS', N'PREEMPTIVE_OS_QUERYREGISTRY',
		N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
		N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'QDS_SHUTDOWN_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
		N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
		N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
		N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
		N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
		N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT')
		AND waiting_tasks_count > 0
	 
	IF ( OBJECT_ID('tempdb..##Email_HTML_13') IS NOT NULL )
		DROP TABLE ##Email_HTML_13

	SELECT TOP 5
		MAX (W1.wait_type) AS [Wait Type],
		CAST(CAST (MAX (W1.WaitS) AS DECIMAL (16,2)) AS VARCHAR) AS [Wait (s)],
		CAST(CAST (MAX (W1.ResourceS) AS DECIMAL (16,2)) AS VARCHAR) AS [Resource (s)],
		CAST(CAST (MAX (W1.SignalS) AS DECIMAL (16,2)) AS VARCHAR) AS [Signal (s)],
		CAST(MAX (W1.WaitCount) AS VARCHAR) AS [Wait Count],
		CAST(CAST (MAX (W1.Percentage) AS DECIMAL (5,2)) AS VARCHAR) AS [Wait (%)],
		CAST(CAST ((MAX (W1.WaitS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS VARCHAR) AS [AVG Wait (s)],
		CAST(CAST ((MAX (W1.ResourceS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS VARCHAR) AS [AVG Resource (s)],
		CAST(CAST ((MAX (W1.SignalS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS VARCHAR) AS [AVG Signal (s)]
	INTO ##Email_HTML_13
	FROM #Waits AS W1
	INNER JOIN #Waits AS W2 ON W2.RowNum <= W1.RowNum
	GROUP BY W1.RowNum
	HAVING SUM (W2.Percentage) - MAX (W1.Percentage) < 99 -- percentage threshold
	ORDER BY   CAST (MAX (W1.Percentage) AS DECIMAL (5,2)) DESC

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Waits Stats')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Wait informations')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_13', -- varchar(max)
				@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Wait (%)] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		


/***********************************************************************************************************************************
--	Page Life Expectancy - HEADER
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_14') IS NOT NULL )
		DROP TABLE ##Email_HTML_14

	-- PLE (Page Life Expectancy) by NUMA Node
	SELECT @@SERVERNAME AS [Server Name], [object_name] [Object Name], instance_name [Instance Name], CAST(cntr_value AS VARCHAR) AS [Page Life Expectancy]
	INTO ##Email_HTML_14
	FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE	[object_name] LIKE N'%Buffer Node%' -- Handles named instances
			AND counter_name = N'Page life expectancy'		
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Page Life Expectancy')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Page Life Expectancy')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_14', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		


/***********************************************************************************************************************************
--	Operators Agent - HEADER
***********************************************************************************************************************************/
  	IF ( OBJECT_ID('tempdb..##Email_HTML_15') IS NOT NULL )
		DROP TABLE ##Email_HTML_15
	
	SELECT	name [Name], 
			CASE enabled WHEN 1 THEN 'SIM' ELSE 'NÃO' END AS [Enabled], 
			email_address [Email Address]
	INTO ##Email_HTML_15
	from msdb.dbo.sysoperators				    

	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Operators Agent')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Agent Operators')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_15', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Name] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 	

/***********************************************************************************************************************************
--	Logins - HEADER
***********************************************************************************************************************************/
  	IF ( OBJECT_ID('tempdb..##Email_HTML_16') IS NOT NULL )
		DROP TABLE ##Email_HTML_16
   	    
	select	name [Name], 
			CONVERT(VARCHAR(20),createdate,120) AS [Create Date], 
			CONVERT(VARCHAR(20),updatedate,120) AS [Update Date], 
			dbname [Database], 
			case when sysadmin = 0 then 'NÃO' else 'SIM' end AS [Sysadmin]
	INTO ##Email_HTML_16
	from sys.syslogins
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações dos Logins')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Logins Information')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_16', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Name] desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 	


/***********************************************************************************************************************************
--	Linked Servers - HEADER
***********************************************************************************************************************************/
	IF ( OBJECT_ID('tempdb..##Email_HTML_17') IS NOT NULL )
		DROP TABLE ##Email_HTML_17   
	

	select srvname [Server Name], srvproduct [Server Product], providername [Provider], ISNULL(datasource,'') AS [Data Source]
	INTO ##Email_HTML_17
	from sys.sysservers
	where srvname <> @@SERVERNAME			  
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações Linked Server')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Linked Server Information')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_17', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Server Name]',

		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 	

/***********************************************************************************************************************************
--	ALERTA - CONEXÕES - HEADER
***********************************************************************************************************************************/
	        
	IF ( OBJECT_ID('tempdb..##Email_HTML_18') IS NOT NULL )
		DROP TABLE ##Email_HTML_18

	SELECT	top 10 
			replace(replace(ec.client_net_address,'<',''),'>','') [Client Net Address], 
			case when es.[program_name] = '' then 'Sem nome na string de conexão' else [program_name] end [Program Name], 
			es.[host_name] [Host Name],
			es.login_name [Login Name],
			CAST(COUNT(ec.session_id) AS VARCHAR) AS [Connection Count] 
	INTO ##Email_HTML_18
	FROM sys.dm_exec_sessions AS es  
	INNER JOIN sys.dm_exec_connections AS ec  
	ON es.session_id = ec.session_id   
	GROUP BY ec.client_net_address, es.[program_name], es.[host_name], es.login_name  			
	order by [Connection Count]  desc
							
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Conexões abertas no SQL Server')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','SQL Server Open Connections')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_18', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Connection Count]  desc',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 	

					
/***********************************************************************************************************************************
--	Backup Information
***********************************************************************************************************************************/
					
	IF ( OBJECT_ID('tempdb..##Email_HTML_19') IS NOT NULL )
		DROP TABLE ##Email_HTML_19
	
	SELECT	db.[name] AS [Database],
			ISNULL((
			SELECT	TOP 1
					CASE type WHEN 'D' THEN 'Full' WHEN 'I' THEN 'Differential' WHEN 'L' THEN 'Transaction log' END + '  ' +
					LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(),backup_finish_date))) + ' days ago', 'NEVER')) + '  ' +
					CONVERT(VARCHAR(20), backup_start_date, 103) + ' ' + CONVERT(VARCHAR(20), backup_start_date, 108) + 
					'  Duration: ' + CAST(DATEDIFF(second, BK.backup_start_date, BK.backup_finish_date) AS VARCHAR(4)) + ' second(s)'
			FROM msdb..backupset BK WHERE BK.database_name = DB_NAME([database_id]) ORDER BY backup_set_id DESC),'No Backup Records') AS [Last backup]
	INTO ##Email_HTML_19
	FROM sys.databases AS db 
	ORDER BY db.[name]
								
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Informações de Backup')				
	END
    ELSE 
	BEGIN
		SET @Header = REPLACE(@Header_Default,'HEADERTEXT','Backup Information')		
	END		  	
	
	EXEC dbo.stpExport_Table_HTML_Output
		@Ds_Tabela = '##Email_HTML_19', -- varchar(max)
		@Ds_Alinhamento  = 'center',
		@Ds_OrderBy = '[Database]',
		@Ds_Saida = @HTML OUT		 -- varchar(max)

	-- Add Mail result
	SET @Final_HTML = @Final_HTML + @Header + @Line_Space + @HTML + @Line_Space 		
				
/***********************************************************************************************************************************
--	Send the Email
***********************************************************************************************************************************/
	
	IF @Fl_Language = 1 --Portuguese
	BEGIN
		SET @Ds_Subject =  @Ds_Message_Alert_PTB+@@SERVERNAME 
	END
    ELSE 
	BEGIN
		SET @Ds_Subject =  @Ds_Message_Alert_ENG+@@SERVERNAME 
	END		   		
				
	-- Second Result
	SET @Final_HTML = @Final_HTML + @Line_Space + @Company_Link			

	EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'							
								
END
GO
