USE [TI_Database]
GO
/****** Object:  Table [dbo].[Table_Size_History]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Table_Size_History](
	[Id_Size_History] [int] IDENTITY(1,1) NOT NULL,
	[Id_Server] [smallint] NULL,
	[Id_Database] [smallint] NULL,
	[Id_Table] [int] NULL,
	[Nm_Drive] [char](1) NULL,
	[Nr_Total_Size] [numeric](15, 2) NULL,
	[Nr_Data_Size] [numeric](15, 2) NULL,
	[Nr_Index_Size] [numeric](15, 2) NULL,
	[Qt_Rows] [bigint] NULL,
	[Dt_Log] [date] NULL,
 CONSTRAINT [PK_Table_Size_History] PRIMARY KEY CLUSTERED 
(
	[Id_Size_History] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
