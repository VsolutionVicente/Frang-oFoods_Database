USE [TI_Database]
GO
/****** Object:  Table [dbo].[BKP_Vendedor20210308]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BKP_Vendedor20210308](
	[Cod_cadastro] [int] NOT NULL,
	[Nome_Cadastro] [varchar](60) NULL,
	[Tipo] [varchar](50) NULL,
	[Cod_Supervisor] [int] NULL,
	[Supervisor] [varchar](60) NULL
) ON [PRIMARY]
GO
