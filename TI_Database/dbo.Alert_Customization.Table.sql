USE [TI_Database]
GO
/****** Object:  Table [dbo].[Alert_Customization]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Alert_Customization](
	[Id_Alert_Customizations] [int] IDENTITY(1,1) NOT NULL,
	[Nm_Alert] [varchar](100) NULL,
	[Nm_Procedure] [varchar](200) NULL,
	[Ds_Customization] [varchar](8000) NULL,
	[Dt_Customization] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Alert_Customization] ADD  CONSTRAINT [DF_Alert_Customization]  DEFAULT (getdate()) FOR [Dt_Customization]
GO
