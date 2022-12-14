USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpAlert_Every_Minute]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[stpAlert_Every_Minute]
AS
BEGIN

	DECLARE @Query NVARCHAR(4000),@Proc VARCHAR(100), @Frequency_Minutes smallint,@Nm_Alert varchar(100),@Proc_Loop varchar(100)

	DECLARE @Procedures TABLE(Nm_Procedure VARCHAR(100), Frequency_Minutes smallint,Nm_Alert varchar(100))

	declare @minute_now tinyint , @hour_now tinyint , @day_now tinyint, @day_week tinyint
	
	select @minute_now = datepart(mi,getdate()),@hour_now = datepart(hh,getdate())+1,@day_week = datepart(dw,getdate()),@day_now=datepart(dd,getdate())

	--select @minute_now , @hour_now,@day_now,@day_week
	
	insert into @Procedures
	select Nm_Procedure,Frequency_Minutes,Nm_Alert
	from TI_Database..Alert_Parameter
	where Fl_Enable = 1
	and Frequency_Minutes is not null
	and @hour_now between Hour_Start_Execution and Hour_End_Execution


	--select * from @Procedures
	
	SET @Query = ''		

	WHILE EXISTS(SELECT TOP 1 NULL FROM @Procedures)
	BEGIN
		SELECT TOP 1 @Proc = Nm_Procedure,@Frequency_Minutes = Frequency_Minutes,@Nm_Alert = Nm_Alert
		FROM @Procedures

		/*
			32000 monthly on day 1
			25200 weekly on monday 
			3600 dayly
			60 every 1 hour
			20 every 20 minutes
			5 every 5 minutes 
			1 every 1 minutes 
		*/
		 

		if (@Frequency_Minutes = 60 and @minute_now =58) OR -- every hour run on minute 58
		   (@minute_now%@Frequency_Minutes = 0 and @Frequency_Minutes < 60) 			--1,5,20 minutes or other different frequency
		begin  

			if @Nm_Alert = 'Blocked Process'
				set @Proc = @Proc + ' ''Blocked Process'''
			else 
				if @Nm_Alert = 'Blocked Long Process'
					set @Proc = @Proc + ' ''Blocked Long Process'''
				else
					if @Nm_Alert ='Slow Disk Every Hour'
						 set @Proc = @Proc + ' ''Slow Disk Every Hour'''
					else	if 	@Nm_Alert ='Slow Disk Every Hour'
							set @Proc = 'EXEC dbo.stpRead_Error_log 1 ' + @Proc 

			SET @Query = @Query  + ' EXEC ' + @Proc
		end

		if (@Frequency_Minutes = 32000 AND @day_now = 1 and @minute_now = 27) OR		--run just on day 1
			(@Frequency_Minutes = 25200 AND @day_week = 2 and @minute_now = 27) OR		-- weekly run just on monday
			(@Frequency_Minutes = 3600 and @minute_now = 27)		--daily
		begin 
			
			if not exists (select null from Log_Alert_Execution where @Nm_Alert = Nm_Alert and Dt_Execucao >= cast(getdate() as date))
			begin 
			
				if @Nm_Alert = 'Slow Disk' 
				begin 
					set @Proc = @Proc + ' ''Slow Disk'''
					set @Query = 'EXEC dbo.stpRead_Error_log 0' + @Query  --Slow Disk, Login Failed and other alerts that need to use Error_Log
				end							

				SET @Query = @Query  + ' EXEC ' + @Proc			

				insert into Log_Alert_Execution(Nm_Procedure,Dt_Execucao,Nm_Alert)
				select @Proc,getdate(),@Nm_Alert

				delete from Log_Alert_Execution
				where Dt_Execucao < getdate()-7
			end

		end

		DELETE FROM @Procedures
		WHERE Nm_Alert = @Nm_Alert 

	end
		
	set @Query = 'EXEC dbo.stpWhoIsActive_Result '+ @Query
	
	--SELECT @Query

	EXECUTE sp_executesql @Query


END
	
GO
