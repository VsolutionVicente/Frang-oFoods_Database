USE [TI_Database]
GO
/****** Object:  Table [dbo].[SQL_Counter]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SQL_Counter](
	[Id_Counter] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Counter] [varchar](50) NULL
) ON [PRIMARY]
GO
