USE [TI_Database]
GO
/****** Object:  Table [dbo].[Alert]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Alert](
	[Id_Alert] [int] IDENTITY(1,1) NOT NULL,
	[Id_Alert_Parameter] [smallint] NOT NULL,
	[Ds_Message] [varchar](2000) NULL,
	[Fl_Type] [tinyint] NULL,
	[Dt_Alert] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id_Alert] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Alert] ADD  DEFAULT (getdate()) FOR [Dt_Alert]
GO
ALTER TABLE [dbo].[Alert]  WITH CHECK ADD  CONSTRAINT [FK01_Alert] FOREIGN KEY([Id_Alert_Parameter])
REFERENCES [dbo].[Alert_Parameter] ([Id_Alert_Parameter])
GO
ALTER TABLE [dbo].[Alert] CHECK CONSTRAINT [FK01_Alert]
GO
