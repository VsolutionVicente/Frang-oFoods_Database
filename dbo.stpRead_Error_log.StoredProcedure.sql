USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpRead_Error_log]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stpRead_Error_log] @Actual_Log bit
AS
BEGIN
	SET DATEFORMAT YMD

	IF (OBJECT_ID('tempdb..##Error_Log_Result') IS NOT NULL)
		DROP TABLE ##Error_Log_Result
	
	CREATE TABLE ##Error_Log_Result (
		[LogDate]		DATETIME,
		[ProcessInfo]	NVARCHAR(50),
		[Text]			NVARCHAR(MAX)
	)

	IF (OBJECT_ID('tempdb..#logF') IS NOT NULL)
		DROP TABLE #logF
	
	CREATE TABLE #logF (
		[ArchiveNumber] INT,
		[LogDate]		DATETIME,
		[LogSize]		INT 
	)

	INSERT INTO #logF  
	EXEC sp_enumerrorlogs
		
	IF @Actual_Log = 0 
	BEGIN 
		DELETE FROM #logF
		WHERE ArchiveNumber NOT IN (
			SELECT ArchiveNumber
			FROM #logF
			WHERE (LogDate > DATEADD(hh,-36,GETDATE()) -- many files from 30 hours
					OR ArchiveNumber <= 1) --OR two old files to be faster
		)
	END
		ELSE --@Actual_Log = 1 - most recent 
        	BEGIN 
				DELETE FROM #logF
				WHERE ArchiveNumber <> 0
				
				DECLARE @Vl_Parameter_2 int
				SELECT @Vl_Parameter_2 = Vl_Parameter_2 FROM [Alert_Parameter] 	WHERE [Nm_Alert] = 'Slow Disk Every Hour'
				
				DELETE FROM #logF
				WHERE LogSize >= @Vl_Parameter_2 * 1024*1024-- just look at small logs
			END

	DECLARE @lC INT

	SELECT @lC = MIN(ArchiveNumber) FROM #logF

	WHILE @lC IS NOT NULL
	BEGIN
		  INSERT INTO ##Error_Log_Result
		  EXEC sp_readerrorlog @lC
		  SELECT @lC = MIN(ArchiveNumber) FROM #logF
		  WHERE ArchiveNumber > @lC
	END

END




GO
