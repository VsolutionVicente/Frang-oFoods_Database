USE [TI_Database]
GO
/****** Object:  Table [dbo].[Index_Fragmentation_History]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Index_Fragmentation_History](
	[Id_Index_Fragmentation_History] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Log] [date] NULL,
	[Id_Server] [smallint] NULL,
	[Id_Database] [smallint] NULL,
	[Id_Table] [int] NULL,
	[Nm_Index] [varchar](1000) NULL,
	[Nm_Schema] [varchar](50) NULL,
	[Avg_Fragmentation_In_Percent] [numeric](5, 2) NULL,
	[Page_Count] [int] NULL,
	[Fill_Factor] [tinyint] NULL,
	[Fl_Compression] [tinyint] NULL
) ON [PRIMARY]
GO
