USE [TI_Database]
GO
/****** Object:  Table [dbo].[tbVendedor_Bkp_210222]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbVendedor_Bkp_210222](
	[Cod_cadastro] [int] NOT NULL,
	[Perc_comissao] [decimal](5, 2) NULL,
	[Tipo_vendedor] [char](1) NULL,
	[Tipo_comissao] [char](1) NULL,
	[Perc_desconto_max] [decimal](5, 2) NULL,
	[Cod_supervisor_vda] [int] NULL,
	[Cod_gerente_vda] [int] NULL
) ON [PRIMARY]
GO
