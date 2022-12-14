USE [TI_Database]
GO
/****** Object:  Table [dbo].[Alert_Parameter]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Alert_Parameter](
	[Id_Alert_Parameter] [smallint] IDENTITY(1,1) NOT NULL,
	[Nm_Alert] [varchar](100) NOT NULL,
	[Nm_Procedure] [varchar](100) NOT NULL,
	[Frequency_Minutes] [smallint] NULL,
	[Hour_Start_Execution] [tinyint] NULL,
	[Hour_End_Execution] [tinyint] NULL,
	[Fl_Language] [bit] NOT NULL,
	[Fl_Clear] [bit] NOT NULL,
	[Fl_Enable] [bit] NOT NULL,
	[Vl_Parameter] [smallint] NULL,
	[Ds_Metric] [varchar](50) NULL,
	[Vl_Parameter_2] [int] NULL,
	[Ds_Metric_2] [varchar](50) NULL,
	[Ds_Profile_Email] [varchar](200) NULL,
	[Ds_Email] [varchar](500) NULL,
	[Ds_Message_Alert_ENG] [varchar](1000) NULL,
	[Ds_Message_Clear_ENG] [varchar](1000) NULL,
	[Ds_Message_Alert_PTB] [varchar](1000) NULL,
	[Ds_Message_Clear_PTB] [varchar](1000) NULL,
	[Ds_Email_Information_1_ENG] [varchar](200) NULL,
	[Ds_Email_Information_2_ENG] [varchar](200) NULL,
	[Ds_Email_Information_1_PTB] [varchar](200) NULL,
	[Ds_Email_Information_2_PTB] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id_Alert_Parameter] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
