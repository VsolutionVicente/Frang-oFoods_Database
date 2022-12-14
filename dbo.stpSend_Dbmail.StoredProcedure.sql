USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpSend_Dbmail]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	CREATE PROCEDURE [dbo].[stpSend_Dbmail] @Ds_Profile_Email VARCHAR(200), @Ds_Email VARCHAR(500),@Ds_Subject VARCHAR(500),@Ds_Mail_HTML VARCHAR(MAX),@Ds_BodyFormat VARCHAR(50),@Ds_Importance VARCHAR(50)
			AS					
				EXEC msdb.dbo.sp_send_dbmail
					@profile_name = @Ds_Profile_Email,
					@recipients =	@Ds_Email,
					@subject =		@Ds_Subject,
					@body =			@Ds_Mail_HTML,
					@body_format =	@Ds_BodyFormat,
					@importance =	@Ds_Importance			

GO
