USE [TI_Database]
GO
/****** Object:  Table [dbo].[Log_Counter]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Log_Counter](
	[Id_Log_Counter] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Log] [datetime] NULL,
	[Id_Counter] [int] NULL,
	[Value] [bigint] NULL
) ON [PRIMARY]
GO
