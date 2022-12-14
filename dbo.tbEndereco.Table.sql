USE [TI_Database]
GO
/****** Object:  Table [dbo].[tbEndereco]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbEndereco](
	[Cod_cadastro] [int] NOT NULL,
	[Tipo_endereco] [char](1) NOT NULL,
	[Cod_pais] [char](4) NULL,
	[Uf] [char](2) NULL,
	[Endereco] [varchar](255) NULL,
	[Bairro] [varchar](30) NULL,
	[Cidade] [varchar](25) NULL,
	[Fone] [char](11) NULL,
	[Fax] [char](11) NULL,
	[Email] [varchar](1024) NULL,
	[Cep] [char](8) NULL,
	[Observacao] [varchar](256) NULL,
	[Numero] [varchar](10) NULL,
	[Cod_municipio] [varchar](10) NULL,
	[Latitude] [float] NULL,
	[Longitude] [float] NULL,
	[ID_Praca] [int] NULL
) ON [PRIMARY]
GO
