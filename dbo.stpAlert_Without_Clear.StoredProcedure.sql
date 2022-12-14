USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Without_Clear]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************************************************************************
--	Alert: Alerts sem Clear
*******************************************************************************************************************************/
CREATE PROCEDURE [dbo].[stpAlert_Without_Clear]
AS
BEGIN
	SET NOCOUNT ON
	SET DATEFORMAT YMD

		DECLARE @Id_Alert_Parameter SMALLINT, @Fl_Enable BIT, @Fl_Type TINYINT, @Vl_Parameter SMALLINT,@Ds_Email VARCHAR(500),@Ds_Profile_Email VARCHAR(200),@Dt_Now DATETIME,@Vl_Parameter_2 INT,
		@Ds_Email_Information_1_ENG VARCHAR(200), @Ds_Email_Information_2_ENG VARCHAR(200), @Ds_Email_Information_1_PTB VARCHAR(200), @Ds_Email_Information_2_PTB VARCHAR(200),
		@Ds_Message_Alert_ENG varchar(1000),@Ds_Message_Clear_ENG varchar(1000),@Ds_Message_Alert_PTB varchar(1000),@Ds_Message_Clear_PTB varchar(1000), @Ds_Subject VARCHAR(500)
	
	DECLARE @Company_Link  VARCHAR(4000),@Line_Space VARCHAR(4000),@Header_Default VARCHAR(4000),@Header VARCHAR(4000),@Fl_Language BIT,@Final_HTML VARCHAR(MAX),@HTML VARCHAR(MAX)		
	
	DECLARE @Ds_Alinhamento VARCHAR(10),@Ds_OrderBy VARCHAR(MAX)
		

					
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
	WHERE Nm_Alert = 'Alert Without Clear'

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
	
	IF(OBJECT_ID('tempdb..#Alerts') IS NOT NULL)
		DROP TABLE #Alerts

	CREATE TABLE #Alerts (
		Id_Alert INT,
		Id_Alert_Parameter INT,
		Nm_Alert VARCHAR(200),
		Ds_Message VARCHAR(2000),
		Dt_Alert DATETIME,
		Fl_Type BIT,
		Run_Duration VARCHAR(18)
	)

	DECLARE @Dt_Referencia DATETIME = DATEADD(HOUR, -24, GETDATE())

	INSERT INTO #Alerts
	SELECT [Id_Alert], A.[Id_Alert_Parameter], [Nm_Alert], [Ds_Message], [Dt_Alert], [Fl_Type], NULL	
	FROM [dbo].[Alert] A WITH(NOLOCK)
	JOIN [dbo].[Alert_Parameter] B WITH(NOLOCK) ON A.Id_Alert_Parameter = B.Id_Alert_Parameter
	WHERE [Dt_Alert] > @Dt_Referencia

	IF(OBJECT_ID('tempdb..#Alert_Without_Clear') IS NOT NULL)
		DROP TABLE #Alert_Without_Clear

	CREATE TABLE #Alert_Without_Clear
	(
		[Nm_Alert] VARCHAR(200),
		[Ds_Message] VARCHAR(2000),
		[Dt_Alert] DATETIME,
		[Run_Duration] VARCHAR(18)
	)
	
	INSERT INTO #Alert_Without_Clear
	SELECT	[Nm_Alert], [Ds_Message], [Dt_Alert],
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) / 86400) AS VARCHAR), 2) + ' Day(s) ' +	-- day
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) / 3600 % 24) AS VARCHAR), 2) + ':' +		-- Hour
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) / 60 % 60) AS VARCHAR), 2) + ':' +			-- Minutes
			RIGHT('00' + CAST((DATEDIFF(SECOND,Dt_Alert, GETDATE()) % 60) AS VARCHAR), 2) AS [Run_Duration]	-- Seconds	
	FROM [dbo].[Alert] A WITH(NOLOCK)
	JOIN [dbo].[Alert_Parameter] B WITH(NOLOCK) ON A.Id_Alert_Parameter = B.Id_Alert_Parameter
	WHERE	[Id_Alert] = ( SELECT MAX([Id_Alert]) FROM [dbo].[Alert] B WITH(NOLOCK) WHERE A.Id_Alert_Parameter = B.Id_Alert_Parameter )
			AND B.[Fl_Clear] = 1	-- 
			AND A.[Fl_Type] = 1		-- Alert
	ORDER BY [Dt_Alert]
 

	
	--	 Do we have Alert without Clear?
	IF EXISTS( SELECT null FROM #Alert_Without_Clear )
	BEGIN
			
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML
		
		SELECT	[Nm_Alert] [Alert],
				ISNULL([Ds_Message], '-') AS [Message],
				ISNULL(CONVERT(VARCHAR, [Dt_Alert], 120), '-') AS [Alert Date],
				ISNULL([Run_Duration], '-') AS [Opened Duration]
		INTO ##Email_HTML
		FROM #Alert_Without_Clear	

		-- Get HTML Informations
		SELECT @Company_Link = Company_Link,
			@Line_Space = Line_Space,
			@Header_Default = Header
		FROM HTML_Parameter
			
		IF @Fl_Language = 1 --Portuguese
		BEGIN
				SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_PTB)
				SET @Ds_Subject =  @Ds_Message_Alert_PTB+@@SERVERNAME 
		END
	      ELSE 
		BEGIN
			SET @Header = REPLACE(@Header_Default,'HEADERTEXT',@Ds_Email_Information_1_ENG)
			SET @Ds_Subject =  @Ds_Message_Alert_ENG+@@SERVERNAME 
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
		
	END
END

GO
