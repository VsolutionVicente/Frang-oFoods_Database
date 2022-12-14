USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpTest_Alerts]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpTest_Alerts]
AS
BEGIN
	EXEC stpWhoIsActive_Result

	--SELECT * FROM ##WhoIsActive_Result
	--------------------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = -1
	WHERE Nm_Alert = 'Database Without Log BACKUP'

	EXEC stpAlert_Database_Without_Log_Backup

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 2
	WHERE Nm_Alert = 'Database Without Log BACKUP'

	EXEC stpAlert_Database_Without_Log_Backup

	--------------------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert =  'SQL Server Connection'

	EXEC stpAlert_SQLServer_Connection

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 5000
	WHERE Nm_Alert =  'SQL Server Connection'

	EXEC stpAlert_SQLServer_Connection


	--------------------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert = 'Long Running Process'

	EXEC stpAlert_Long_Runnning_Process

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 2
	WHERE Nm_Alert = 'Long Running Process'

	--------------------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0,Vl_Parameter_2 = 0
	WHERE Nm_Alert = 'Tempdb MDF File Utilization'

	EXEC stpAlert_Tempdb_MDF_File_Utilization

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 70,Vl_Parameter_2 = 10000
	WHERE Nm_Alert = 'Tempdb MDF File Utilization'

	EXEC stpAlert_Tempdb_MDF_File_Utilization

	----------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert = 'CPU Utilization'

	EXEC [stpAlert_CPU_Utilization]

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 85
	WHERE Nm_Alert = 'CPU Utilization'

	EXEC [stpAlert_CPU_Utilization]

	------------------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 100
	WHERE Nm_Alert = 'Memory Available'

	EXEC stpAlert_Memory_Available

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 2
	WHERE Nm_Alert = 'Memory Available'

	EXEC stpAlert_Memory_Available

	----------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter_2 = 0
	WHERE Nm_Alert = 'Large LDF File'

	EXEC stpAlert_Large_LDF_File

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter_2 = 10
	WHERE Nm_Alert = 'Large LDF File'

	EXEC stpAlert_Large_LDF_File

	-------------------------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 32000
	WHERE Nm_Alert = 'SQL Server Restarted'

	EXEC stpAlert_SQLServer_Restarted

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 20
	WHERE Nm_Alert = 'SQL Server Restarted'

	------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 5000
	WHERE Nm_Alert = 'Database Created'

	EXEC stpAlert_Database_Without_Backup

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 24
	WHERE Nm_Alert = 'Database Created'

	-----------------

	EXEC stpAlert_Page_Corruption



	----------
	EXEC stpRead_Error_log @Actual_Log = 1
	EXEC stpAlert_Slow_Disk @Nm_Alert = 'Slow Disk'

	------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert =  'Login Failed'

	EXEC stpAlert_Login_Failed

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 50
	WHERE Nm_Alert =  'Login Failed'

	---------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 2000
	WHERE Nm_Alert =  'Job Failed'

	EXEC stpAlert_Job_Failed

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 24
	WHERE Nm_Alert =  'Job Failed'

	-------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert =  'SQL Server Connection'

	EXEC stpAlert_SQLServer_Connection

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 5000
	WHERE Nm_Alert =  'SQL Server Connection'

	EXEC stpAlert_SQLServer_Connection

	-------------

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0,Vl_Parameter_2 = 5000
	WHERE Nm_Alert = 'Slow File Growth'

	EXEC stpAlert_Slow_File_Growth

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 1, Vl_Parameter_2 = 24
	WHERE Nm_Alert = 'Slow File Growth'

	EXEC stpAlert_Slow_File_Growth

--------------------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0, Vl_Parameter_2=0
	WHERE Nm_Alert = 'Log Full'

	EXEC [stpAlert_Log_Full]


	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 85, Vl_Parameter_2=10000000
	WHERE Nm_Alert = 'Log Full'

	EXEC [stpAlert_Log_Full]


	--------------
	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 0
	WHERE Nm_Alert = 'Disk Space'

	EXEC stpAlert_Disk_Space

	UPDATE dbo.Alert_Parameter
	SET Vl_Parameter = 80
	WHERE Nm_Alert = 'Disk Space'

	EXEC stpAlert_Disk_Space

	---------------
	EXEC dbo.stpSend_Mail_Executing_Process

	--------------
	EXEC stpAlert_Without_Clear

	--------------

	EXEC stpSQLServer_Configuration

END


GO
