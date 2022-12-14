USE [TI_Database]
GO
/****** Object:  Table [dbo].[Log_Alert_Execution]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Log_Alert_Execution](
	[Id_Log_Alert_Execution] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Procedure] [varchar](100) NULL,
	[Nm_Alert] [varchar](100) NULL,
	[Dt_Execucao] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [SK01_Log_Alert_Execution]    Script Date: 10/06/2021 09:29:17 ******/
CREATE CLUSTERED INDEX [SK01_Log_Alert_Execution] ON [dbo].[Log_Alert_Execution]
(
	[Dt_Execucao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
