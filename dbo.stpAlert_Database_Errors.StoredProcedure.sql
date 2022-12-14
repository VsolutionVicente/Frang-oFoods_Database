USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Database_Errors]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_Database_Errors]
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
	WHERE Nm_Alert = 'Database Errors'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		

	DECLARE @Dt_ref DATE, @Quantity_Errors INT
	SET @Dt_ref = DATEADD(hh,-1*@Vl_Parameter_2,GETDATE()) 
	
	IF ( OBJECT_ID('tempdb..#TOP50_DB_Error') IS NOT NULL ) 
		DROP TABLE #TOP50_DB_Error

	CREATE TABLE #TOP50_DB_Error(
		[Nm_Database]	VARCHAR (MAX),
		[Error]		VARCHAR(MAX),
		[HostName]        VARCHAR(MAX),
		[Quantity]			INT,
		[Sequence]			INT
	)

	
	IF ( OBJECT_ID('tempdb..#Erros_BD') IS NOT NULL ) 
		DROP TABLE #Erros_BD
	
	select  B.name AS Nm_Database,
	   A.client_hostname AS HostName,
			case 
				when err_message like '%deadlocked%'
					then 'Deadlock'
				else
					 err_message
			end AS Error,
			count(*) AS Quantity
	INTO #Erros_BD
	from Log_DB_Error A 
	join sys.databases B on A.database_id = B.database_id 
	where err_timestamp >= @Dt_ref and err_timestamp < dateadd(day,1,@Dt_ref)
	group by	case 
					when err_message like '%deadlocked%'
						then 'Deadlock'
					else
						 err_message
				end	, B.name,A.client_hostname
	order by Quantity desc

	Select @Quantity_Errors = SUM(Quantity) FROM #Erros_BD
	
	-- Do we have error problems?
	IF ( @Quantity_Errors >= @Vl_Parameter )
	BEGIN
	
		 INSERT INTO #TOP50_DB_Error (Nm_Database,[HostName], Error, Quantity, Sequence)
		SELECT TOP 50 [Nm_Database],ISNULL([HostName],'-') AS [HostName],  [Error], [Quantity], 1 as [Sequence]
		FROM #Erros_BD
		ORDER BY [Sequence], [Quantity] DESC

		DELETE TOP (50)	FROM #Erros_BD 	
		
		IF (@@ROWCOUNT <> 0)
		BEGIN
			 INSERT INTO #TOP50_DB_Error (Nm_Database,[HostName], Error, Quantity, Sequence)
			SELECT 'OTHERS' AS [Nm_Database],'-' AS [HostName] , '-' AS [Error], SUM([Quantity]) AS [Quantity], 2 as [Sequence]
			FROM #Erros_BD
			ORDER BY [Sequence], [Quantity] DESC
			
			INSERT INTO #TOP50_DB_Error (Nm_Database,[HostName],Error,Quantity,Sequence)
			SELECT 'TOTAL', '-','-',@Quantity_Errors, 3 AS Sequence
		END
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML
			
		SELECT	[Sequence],[Nm_Database] [Database], [HostName],
			[Error],
			[Quantity] as [Total Error]
		INTO ##Email_HTML
		FROM #TOP50_DB_Error
								
		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_PTB,'###1',@Quantity_Errors)+@@SERVERNAME 
		END
        ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  REPLACE(@Ds_Message_Alert_ENG,'###1',@Quantity_Errors)+@@SERVERNAME 
		END		   		

		EXEC dbo.stpExport_Table_HTML_Output
			@Ds_Tabela = '##Email_HTML', -- varchar(max)
			@Ds_Alinhamento  = 'center',
			@Ds_OrderBy = '[Sequence],[Total Error] desc',
			@Ds_Saida = @HTML OUT				-- varchar(max)

		-- First Result
		SET @Final_HTML = @Header + @Line_Space + @HTML + @Line_Space 		
					
			EXEC stpSend_Dbmail @Ds_Profile_Email,@Ds_Email,@Ds_Subject,@Final_HTML,'HTML','High'								
		
		-- Fl_Type = 1 : ALERT	
		INSERT INTO [dbo].[Alert] ( [Id_Alert_Parameter], [Ds_Message], [Fl_Type] )
		SELECT @Id_Alert_Parameter, @Ds_Subject, 1			

	END
END



GO
