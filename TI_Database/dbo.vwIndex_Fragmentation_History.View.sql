USE [TI_Database]
GO
/****** Object:  View [dbo].[vwIndex_Fragmentation_History]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vwIndex_Fragmentation_History]
AS
select A.Dt_Log, B.Nm_Server, C.Nm_Database,D.Nm_Table ,A.Nm_Index, A.Nm_Schema, 
	A.Avg_Fragmentation_In_Percent, A.Page_Count, A.Fill_Factor, A.Fl_Compression
from Index_Fragmentation_History A
	join User_Server B on A.Id_Server = B.Id_Server
	join User_Database C on A.Id_Database = C.Id_Database
	join User_Table D on A.Id_Table = D.Id_Table


GO
