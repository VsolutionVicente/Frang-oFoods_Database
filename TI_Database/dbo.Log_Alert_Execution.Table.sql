USE [TI_Database]
GO
/****** Object:  Table [dbo].[Log_Alert_Execution]    Script Date: 20/06/2022 18:58:07 ******/
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
