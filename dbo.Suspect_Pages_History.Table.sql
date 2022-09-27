USE [TI_Database]
GO
/****** Object:  Table [dbo].[Suspect_Pages_History]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suspect_Pages_History](
	[database_id] [int] NOT NULL,
	[file_id] [int] NOT NULL,
	[page_id] [bigint] NOT NULL,
	[event_type] [int] NOT NULL,
	[Dt_Corruption] [datetime] NOT NULL
) ON [PRIMARY]
GO
