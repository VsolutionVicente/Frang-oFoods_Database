USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Database_Growth]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[stpAlert_Database_Growth]
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
	WHERE Nm_Alert = 'Database Growth'
		

	IF @Fl_Enable = 0
		RETURN
		
	-- Look for the last time the alert was executed and find if it was a "0: CLEAR" OR "1: ALERT".
	SELECT @Fl_Type = [Fl_Type]
	FROM [dbo].[Alert]
	WHERE [Id_Alert] = (SELECT MAX(Id_Alert) FROM [dbo].[Alert] WHERE [Id_Alert_Parameter] = @Id_Alert_Parameter )		
		
	if OBJECT_ID('Tempdb..#Alert_Database_Growth') is not null
		DROP table #Alert_Database_Growth

	select B.[Nm_Server], [Nm_Database],
			SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) AS [Size Yesterday],
			SUM(CASE WHEN [Dt_Log] = cast(getdate() as date)   THEN A.[Nr_Total_Size] ELSE 0 END) AS [Size Today],
			SUM(CASE WHEN [Dt_Log] = cast(getdate() as date)   THEN A.[Nr_Total_Size] ELSE 0 END) 
			- SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) [Growth (MB)],
			(SUM(CASE WHEN [Dt_Log] = cast(getdate() as date)   THEN A.[Nr_Total_Size] ELSE 0 END) 
			- SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) )/
			case when SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) * 100.00 = 0 
				then 1
				else  SUM(CASE WHEN [Dt_Log] = cast(getdate()-1 as date) THEN A.[Nr_Total_Size] ELSE 0 END) * 100.00 
				end
			[Growth (%)]
	into #Alert_Database_Growth
	FROM [dbo].[Table_Size_History] A
		JOIN [dbo].User_Server B ON A.[Id_Server] = B.[Id_Server] 
		JOIN [dbo].User_Table C ON A.[Id_Table] = C.[Id_Table]
		JOIN [dbo].User_Database D ON A.[Id_Database] = D.[Id_Database]
	WHERE	A.[Dt_Log] >= getdate()-2
		AND B.Nm_Server = @@SERVERNAME		
	GROUP BY B.[Nm_Server], [Nm_Database]
	
	if OBJECT_ID('Tempdb..#High_Growth') is not null
		DROP table #High_Growth

	select [Nm_Database],
			[Size Yesterday], [Size Today], [Growth (MB)],[Growth (%)],
			case when [Size Yesterday] < 100000 and [Growth (%)] > 40 then 1
			when [Size Yesterday] > 100000 and [Growth (%)] > 30 then 1
			when [Size Yesterday] > 300000 and [Growth (%)] > 20 then 1
			when [Size Yesterday] > 500000 and [Growth (%)] > 10 then 1			
			else 0
			end [High Growth]
	into #High_Growth
	from #Alert_Database_Growth
	WHERE [Size Yesterday] > @Vl_Parameter * 1024 
		
					
	IF exists (select null from #High_Growth where [High Growth] = 1) 
	BEGIN
		
		IF ( OBJECT_ID('tempdb..##Email_HTML') IS NOT NULL )
			DROP TABLE ##Email_HTML

		SELECT	*
		into ##Email_HTML
		FROM #High_Growth
		where [High Growth] = 1
						 
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
			@Ds_OrderBy = '[Growth (%)] DESC',
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
