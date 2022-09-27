USE [TI_Database]
GO
/****** Object:  Table [dbo].[Status_Job_SQL_Agent]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status_Job_SQL_Agent](
	[Name] [varchar](200) NULL,
	[Dt_Referencia] [date] NULL,
	[Date_Modified] [datetime] NULL,
	[Fl_Status] [bit] NULL
) ON [PRIMARY]
GO
