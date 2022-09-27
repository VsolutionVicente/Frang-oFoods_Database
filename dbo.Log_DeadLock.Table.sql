USE [TI_Database]
GO
/****** Object:  Table [dbo].[Log_DeadLock]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Log_DeadLock](
	[eventName] [varchar](100) NULL,
	[eventDate] [datetime] NULL,
	[deadlock] [xml] NULL,
	[Nm_Object] [varchar](500) NULL,
	[Nm_Database] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
