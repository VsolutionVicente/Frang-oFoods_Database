USE [TI_Database]
GO
/****** Object:  Table [dbo].[Waits_Stats_History]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Waits_Stats_History](
	[Id_Waits_Stats_History] [int] IDENTITY(1,1) NOT NULL,
	[Dt_Log] [datetime] NULL,
	[WaitType] [varchar](60) NOT NULL,
	[Wait_S] [decimal](14, 2) NULL,
	[Resource_S] [decimal](14, 2) NULL,
	[Signal_S] [decimal](14, 2) NULL,
	[WaitCount] [bigint] NULL,
	[Percentage] [decimal](4, 2) NULL,
	[Id_Store] [int] NULL,
 CONSTRAINT [PK_Waits_Stats_History] PRIMARY KEY CLUSTERED 
(
	[Id_Waits_Stats_History] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Waits_Stats_History] ADD  DEFAULT (getdate()) FOR [Dt_Log]
GO
