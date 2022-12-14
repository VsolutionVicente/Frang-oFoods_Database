USE [TI_Database]
GO
/****** Object:  Table [dbo].[File_Utilization_History]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[File_Utilization_History](
	[Nm_Database] [nvarchar](128) NULL,
	[file_id] [smallint] NOT NULL,
	[io_stall_read_ms] [bigint] NOT NULL,
	[num_of_reads] [bigint] NOT NULL,
	[avg_read_stall_ms] [numeric](10, 1) NULL,
	[io_stall_write_ms] [bigint] NOT NULL,
	[num_of_writes] [bigint] NOT NULL,
	[avg_write_stall_ms] [numeric](10, 1) NULL,
	[io_stalls] [bigint] NULL,
	[total_io] [bigint] NULL,
	[avg_io_stall_ms] [numeric](10, 1) NULL,
	[Dt_Log] [datetime] NOT NULL
) ON [PRIMARY]
GO
