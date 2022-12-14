USE [TI_Database]
GO
/****** Object:  Table [dbo].[Log_IO_Pending]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Log_IO_Pending](
	[Id_Log_IO_Pending] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Database] [varchar](128) NULL,
	[Physical_Name] [varchar](260) NOT NULL,
	[IO_Pending] [int] NOT NULL,
	[IO_Pending_ms] [bigint] NOT NULL,
	[IO_Type] [varchar](60) NOT NULL,
	[Number_Reads] [bigint] NOT NULL,
	[Number_Writes] [bigint] NOT NULL,
	[Dt_Log] [datetime] NOT NULL
) ON [PRIMARY]
GO
