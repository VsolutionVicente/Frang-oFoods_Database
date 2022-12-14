USE [TI_Database]
GO
/****** Object:  Table [dbo].[Queries_Profile]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Queries_Profile](
	[TextData] [varchar](max) NULL,
	[NTUserName] [varchar](128) NULL,
	[HostName] [varchar](128) NULL,
	[ApplicationName] [varchar](128) NULL,
	[LoginName] [varchar](128) NULL,
	[SPID] [int] NULL,
	[Duration] [numeric](15, 2) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[ServerName] [varchar](128) NULL,
	[Reads] [bigint] NULL,
	[Writes] [bigint] NULL,
	[CPU] [bigint] NULL,
	[DataBaseName] [varchar](128) NULL,
	[RowCounts] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
