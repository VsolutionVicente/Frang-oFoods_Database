USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[stpConfiguration_Table]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[stpConfiguration_Table] @Ds_Email VARCHAR(MAX),@Ds_Profile_Email VARCHAR(MAX),@Fl_Language bit
AS
BEGIN




	IF ( OBJECT_ID('[dbo].[Alert]') IS NOT NULL )
		DROP TABLE [dbo].[Alert];

	CREATE TABLE [dbo].[Alert] (
		[Id_Alert]				INT IDENTITY PRIMARY KEY,
		[Id_Alert_Parameter]	SMALLINT NOT NULL,
		[Ds_Message] VARCHAR(2000),
		[Fl_Type]				TINYINT,						-- 0: CLEAR / 1: ALERT
		[Dt_Alert]				DATETIME DEFAULT(GETDATE())
	);


	IF ( OBJECT_ID('[dbo].[Alert_Parameter]') IS NOT NULL )
		DROP TABLE [dbo].[Alert_Parameter];

	CREATE TABLE [dbo].[Alert_Parameter] (
		[Id_Alert_Parameter] SMALLINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
		[Nm_Alert] VARCHAR(100) NOT NULL,
		[Nm_Procedure] VARCHAR(100) NOT NULL,
		[Frequency_Minutes] smallint NULL,
		[Hour_Start_Execution] tinyint NULL,
		[Hour_End_Execution] tinyint NULL,	
		[Fl_Language] BIT NOT NULL,    --0 - English | 1 - Portuguese
		[Fl_Clear] BIT NOT NULL,
		[Fl_Enable] BIT NOT NULL, 
		[Vl_Parameter] SMALLINT NULL,
		[Ds_Metric] VARCHAR(50) NULL,
		[Vl_Parameter_2] INT,
		[Ds_Metric_2] VARCHAR(50) NULL,
		[Ds_Profile_Email] VARCHAR(200) NULL,
		[Ds_Email] VARCHAR(500) NULL,
		Ds_Message_Alert_ENG varchar(1000),
		Ds_Message_Clear_ENG varchar(1000),
		Ds_Message_Alert_PTB varchar(1000),
		Ds_Message_Clear_PTB varchar(1000),
		Ds_Email_Information_1_ENG VARCHAR(200),
		Ds_Email_Information_2_ENG VARCHAR(200),
		Ds_Email_Information_1_PTB VARCHAR(200),
		Ds_Email_Information_2_PTB VARCHAR(200)
		
	) ON [PRIMARY];

	ALTER TABLE [dbo].[Alert]
	ADD CONSTRAINT FK01_Alert
	FOREIGN KEY ([Id_Alert_Parameter])
	REFERENCES [dbo].[Alert_Parameter] ([Id_Alert_Parameter]);


	
INSERT INTO [dbo].[Alert_Parameter]
		([Nm_Alert], [Nm_Procedure],[Frequency_Minutes],[Hour_Start_Execution],[Hour_End_Execution],[Fl_Language], [Fl_Clear],[Fl_Enable], [Vl_Parameter], [Ds_Metric], [Ds_Profile_Email], [Ds_Email],Ds_Message_Alert_ENG,Ds_Message_Clear_ENG,Ds_Message_Alert_PTB,Ds_Message_Clear_PTB,[Ds_Email_Information_1_ENG],[Ds_Email_Information_2_ENG],[Ds_Email_Information_1_PTB],[Ds_Email_Information_2_PTB]) 
VALUES	('Version DB CheckList ',		/*CheckProjectVersion*/'2.1.0',NULL,NULL,NULL,@Fl_Language,									0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		('Version DB Alert ',			/*CheckProjectVersion*/'2.1.0',NULL,NULL,NULL,@Fl_Language,									0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
		('Blocked Process',				'stpAlert_Blocked_Process',1,7,23,@Fl_Language,				1,1,		2,		'Minutes',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There are ###1 Blocked Processes for more than ###2 minutes and a total of ###3 Lock(s) on Server: ' ,'CLEAR: There is not a Blocked Process for more than ###1 minutes on Server: ' ,'ALERTA: Existe(m) ###1 Processo(s) Bloqueado(s) a mais de ###2 minuto(s) e um total de ###3 Lock(s) no Servidor:  ','CLEAR: Não existe mais um processo Bloqueado a mais de ###1 minuto(s) no Servidor: ','TOP 50 - Process by Lock Level','TOP 50 - Process Executing on Database','TOP 50 - Processos por Nível de Lock','TOP 50 - Processos executando no Banco de Dados '),
		('Blocked Long Process',		'stpAlert_Blocked_Process',1,7,23,@Fl_Language,			1,1,		20,		'Minutes',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There are ###1 Blocked Processes for more than ###2 minutes and a total of ###3 Lock(s) on Server: ' ,'CLEAR: There is not a Blocked Process for more than ###1 minutes on Server: ' ,'ALERTA: Existe(m) ###1 Processo(s) Bloqueado(s) a mais de ###2 minuto(s) e um total de ###3 Lock(s) no Servidor:  ','CLEAR: Não existe mais um processo Bloqueado a mais de ###1 minuto(s) no Servidor: ','TOP 50 - Process by Lock Level','TOP 50 - Process Executing on Database','TOP 50 - Processos por Nível de Lock','TOP 50 - Processos executando no Banco de Dados '),
		('Log Full',				'stpAlert_Log_Full',1,0,24,@Fl_Language,				1,1,		85,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Log File with more than ###1% used on Server: ','CLEAR: There is not a Log File with more than ###1 % used on Server: ','ALERTA: Existe um Arquivo de Log com mais de ###1% de utilização no Servidor: ','CLEAR: Não existe mais um Arquivo de Log com mais de ###1 % de utilização no Servidor:','Transaction Log Informations','TOP 50 - Process Executing on Database','Informações dos Arquivos de Log','TOP 50 - Processos executando no Banco de Dados'),
		('CPU Utilization',						'stpAlert_CPU_Utilization',1,7,23,@Fl_Language,					1,1,		85,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: Cpu utilization is greater than ###1% on Server: ','CLEAR: Cpu utilization is lower than ###1% on Server: ','ALERTA: O Consumo de CPU está acima de ###1% no Servidor: ','CLEAR: O Consumo de CPU está abaixo de ###1% no Servidor: ','CPU Utilization','TOP 50 - Process Executing on Database','Consumo de CPU no Servidor','TOP 50 - Processos executando no Banco de Dados'),
		('Disk Space',					'stpAlert_Disk_Space',5,0,24,@Fl_Language,					1,1,		80,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a disk with more than ###1% used on Server: ','CLEAR: There is not a disk with more than ###1% used on Server: ','ALERTA: Existe um disco com mais de ###1% de utilização no Servidor: ','CLEAR: Não existe mais um volume de disco com mais de ###1% de utilização no Servidor: ','Disk Space on Server','TOP 50 - Process Executing on Database','Espaço em Disco no Servidor','TOP 50 - Processos executando no Banco de Dados'),
		('Database Without Backup',				'stpAlert_Database_Without_Backup',3600,6,10,@Fl_Language,			0,1,		24,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Database without Backup in the last ###1 Hours on Server: ','','ALERTA: Existem Databases sem Backup nas últimas ###1 Horas no Servidor: ','','Database without Backup in the last ###1 Hours','','Databases sem Backup nas últimas ###1 Horas',''),
		('SQL Server Restarted',			'stpAlert_SQLServer_Restarted',20,0,24,@Fl_Language,			0,1,		20,		'Minutes',		@Ds_Profile_Email,	@Ds_Email,'ALERT: SQL Server restarted in the last ###1 Minutes on Server: ','','ALERTA: SQL Server Reiniciado nos últimos ###1 Minutos no Servidor: ','','SQL Server Restared in the last ###1 minutes','','SQL Server Reiniciado nos últimos ###1 Minutos',''),
		('Trace Creation',			'stpTrace_Creation',NULL,NULL,NULL,@Fl_Language,							0,1,		3,		'Seconds',		@Ds_Profile_Email,	@Ds_Email,'This is not an Alert','','Não é um Alerta. É para a criação do profile de 3 segundos.','',NULL,NULL,NULL,NULL),
		('Slow Queries',				'stpAlert_Slow_Queries',NULL,NULL,NULL,@Fl_Language,				0,0,		500,	'Quantity',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There are ###1 slower queries in the last ###2 minutes on Server: ','','ALERTA: Existem ###1 queries demoradas nos últimos ###2 minutos no Servidor: ','','TOP 50 - Process Executing on Database','TOP 50 - Slow Queries','TOP 50 - Processos executando no Banco de Dados','TOP 50 - Queries Demoradas'),
		('Database Status',					'stpAlert_Database_Status',1,0,24,@Fl_Language,				1,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Database that is not ONLINE on Server: ','CLEAR: All databases are ONLINE on Server: ','ALERTA: Existe uma Database que não está ONLINE no Servidor: ','CLEAR: Não existe mais uma Database que não está ONLINE no Servidor: ','Databases not ONLINE','','Bases que não estão ONLINE ',''),
		('Page Corruption',				'stpAlert_Page_Corruption',1,0,24,@Fl_Language,				0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a corrupted page on a database on Server: ','','ALERTA: Existe uma Página Corrompida no BD no Servidor: ','','Corrupted Pages','','Páginas Corrompidas',''),
		('Database Corruption',		'stpAlert_CheckDB',NULL,NULL,NULL,@Fl_Language,						0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a corrupted database on Server: ','','ALERTA: Existe um Banco de Dados Corrompido no Servidor: ','','Corrupted Database','','Banco de Dados Corrompido',''),
		('Job Failed',						'stpAlert_Job_Failed',3600,6,10,@Fl_Language,						0,1,		24,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: Jobs failed in the last ###1 Hours on Server: ','','ALERTA: Jobs que Falharam nas últimas ###1 Horas no Servidor: ','','TOP 50 - Failed Jobs',NULL,'TOP 50 - Jobs que Falharam',NULL),
		('Database Created',					'stpAlert_Database_Created',3600,0,5,@Fl_Language,				0,1,		24,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: Database created in the last ###1 Hours on Server: ','','ALERTA: Database Criada nas últimas ###1 Horas no Servidor: ','','Created Database','Created Database - Data and Log Files','Database Criada','Database Criada - Arquivos de Dados e Log'),
		('Tempdb MDF File Utilization',	'stpAlert_Tempdb_MDF_File_Utilization',5,0,24,@Fl_Language,	1,1,		70,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: The Tempdb MDF file is greater than ###1% used on Server: ','CLEAR: The Tempdb MDF file is lower than ###1% used on Server:  ','ALERTA: O Tamanho do Arquivo MDF do Tempdb está acima de ###1% no Servidor: ','CLEAR: O Tamanho do Arquivo MDF do Tempdb está abaixo de ###1% no Servidor: ','Tempdb MDF File Size', 'TOP 50 - Process Executing on Database', 'Tamanho Arquivo MDF Tempdb','TOP 50 - Processos executando no Banco de Dados'),
		('SQL Server Connection',				'stpAlert_SQLServer_Connection',60,0,24,@Fl_Language,				1,1,		5000,	'Quantity',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There are more than ###1 Openned Connections on Server: ','CLEAR: There are not ###1 Openned Connections on Server: ','ALERTA: Existem mais de ###1 Conexões Abertas no SQL Server no Servidor: ','CLEAR: Não existem mais ###1 Conexões Abertas no SQL Server no Servidor: ','TOP 25 - Open Connections on SQL Server','TOP 50 - Process Executing on Database','TOP 25 - Conexões Abertas no SQL Server','TOP 50 - Processos executando no Banco de Dados'),
		('Database Errors',						'stpAlert_Database_Errors',3600,0,5,@Fl_Language,						0,0,		1000,	'Quantity',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There are ###1 Errors on the Last Day on Server: ','','ALERTA: Existem ###1 Erros do Banco de Dados Dia Anterior no Servidor: ','','TOP 50 - Database Erros from Yesterday',NULL,'TOP 50 - Erros do Banco de Dados Dia Anterior',NULL),
		('Slow Disk',					'stpAlert_Slow_Disk',3600,0,5,@Fl_Language,					0,1,		24,	'Hour',			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a slow disk message on the Last Day on Server: ','','ALERTA: Existe uma mensagem de lentidão de Disco no Dia Anterior no Servidor: ','','Yesterday Slow Disk Access ',NULL,'Lentidão de Acesso a Disco no Dia Anterior',NULL),
		('Slow Disk Every Hour',		'stpAlert_Slow_Disk',60,0,24,@Fl_Language,					0,0,		1,	'Hour',			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a slow disk message in the Last Hour on Server: ','','ALERTA: Existe uma mensagem de lentidão de Disco na última Hora no Servidor: ','','Slow Disk Access ',NULL,'Lentidão de Acesso a Disco',NULL),
		('Process Executing',			'stpSend_Mail_Executing_Process',NULL,NULL,NULL,@Fl_Language,		0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'INFO: SQL Process running Now on Server: ','','INFO: Processos executando no Banco de Dados agora no servidor: ','','TOP 50 - Process Executing on Database',NULL,'Processos em Execução no Banco de Dados',NULL),
		('Database CheckList ',		'stpSend_Mail_CheckList_DBA',NULL,NULL,NULL,@Fl_Language,			0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'INFO: Database Checklist on Server: ','','INFO: Checklist do Banco de Dados no Servidor: ','',NULL,NULL,NULL,NULL),
		('SQL Server Configuration',			'stpSQLServer_Configuration',32000,0,24,@Fl_Language,		0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'INFO: Database Information on Server: ','','INFO: Informações do Banco de Dados no Servidor: ','',NULL,NULL,NULL,NULL),
		('Long Running Process',				'stpAlert_Long_Runnning_Process',3600,7,10,@Fl_Language,				0,1,		2,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Process in execution for more than ###1 Hours on Server: ','','ALERTA: Existe(m) Processo(s) em Execução há mais de ###1 Hora(s) no Servidor: ','','TOP 50 - Process Executing on Database',NULL,'Processos executando no Banco de Dados',NULL),
		('Slow File Growth',			'stpAlert_Slow_File_Growth',3600,0,5,@Fl_Language,			0,1,		5,		'Seconds',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a slow growth database file on Server: ','','ALERTA: Existe um Crescimento Lento de Arquivo de Base no Servidor: ','','TOP 50 - Database File Growth',NULL,'TOP 50 - Crescimentos de Arquivos Databases',NULL),
		('Alert Without Clear',				'stpAlert_Without_Clear',3600,0,5,@Fl_Language,						0,1,		NULL,	NULL,			@Ds_Profile_Email,	@Ds_Email,'ALERT: There is an Openned Alert on Server: ','','ALERTA: Existe(m) Alerta(s) sem Clear no Servidor: ','','Alerts Without CLEAR',NULL,'Alertas sem CLEAR',NULL),
		('Login Failed',					'stpAlert_Login_Failed',3600,0,5,@Fl_Language,					0,1,		100,	'Number',			@Ds_Profile_Email,	@Ds_Email,'ALERT: There are failed attempts to login on Server: ','','ALERTA: Existem tentativas de Login com falha no servidor: ','','Logins Failed - SQL Server',NULL,'Falhas de Login - SQL Server',NULL),
		('Database Without Log Backup',			'stpAlert_Database_Without_Log_Backup',60,0,24,@Fl_Language,		1,1,		2,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Database without Log Backup in the last ###1 Hours on Server: ','CLEAR: There is not a Database without Log Backup in the last ###1 Hours on Server: ','ALERTA: Existem Databases sem Backup de Log nas últimas ###1 Horas no Servidor: ','CLEAR: Não Existe Database sem Backup de Log nas últimas ###1 Horas no Servidor: ','Databases Without Log Backup','TOP 50 - Process Executing on Database','Databases sem Backup do Log','TOP 50 - Processos executando no Banco de Dados'),
		('IO Pending',			'stpAlert_IO_Pending',1,0,24,@Fl_Language,		0,1,		10,		'Seconds',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a IO Pending for more than ###1 Seconds on Server: ','','ALERTA: Existe uma operação de IO maior que ###1 Segundos pendentes no Servidor: ','','TOP 50 - IO Pending Operation','TOP 50 - Process Executing on Database','TOP 50 - Operações de IO pendentes','TOP 50 - Processos executando no Banco de Dados'),
		('Memory Available',			'stpAlert_Memory_Available',1,0,24,@Fl_Language,		1,1,		2,		'GB',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There are Less than ###1 GB of Memory Available on Server: ','CLEAR: There are More than ###1 GB of Memory Available on Server: ','ALERTA: Existe menos de ###1 GB de Memória Disponivel no Servidor: ','CLEAR: Existe mais de ###1 GB de Memória Disponivel no Servidor: ','Memory Used','TOP 50 - Process Executing on Database','Utilização de Memória','TOP 50 - Processos executando no Banco de Dados'),
		('Job Disabled',			'stpAlert_Job_Disabled',3600,0,5,@Fl_Language,		0,1,		NULL,		NULL,		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a Disabled Job From Yesterday on Server: ','','ALERTA: Existe um Job que foi Desabilitado no Servidor: ','','Jobs Disabled','','Jobs Desabilitados',''),
		('Large LDF File',			'stpAlert_Large_LDF_File',1,0,24,@Fl_Language,		1,1,		50,		'Percent',		@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a LDF File with ###1 % of the MDF File on Server: ','CLEAR: There is not a LDF File with ###1 % of the MDF File on Server:  ','ALERTA: Existe um Arquivo de Log com ###1 % do tamanho do arquivo de Dados no Servidor: ','CLEAR: Não existe um Arquivo de Log com ###1 % do tamanho do arquivo de Dados no Servidor: ','Database File Informations','TOP 50 - Process Executing on Database','Informações dos Arquivos das Bases de Dados','TOP 50 - Processos executando no Banco de Dados'),
		('Rebuild Failed',			'stpAlert_Rebuild_Failed',NULL,NULL,NULL,@Fl_Language,						0,1,		8,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: The Rebuild Job failed because Lock Timeout on Server: ','','ALERTA: O Job de Rebuild falhou por causa de Lock no Servidor : ','','Last Lock Registered',NULL,'Último Lock Registrado',NULL),
		('DeadLock',			'stpAlert_DeadLocks',3600,0,5,@Fl_Language,						0,0,		24,		'Hours',		@Ds_Profile_Email,	@Ds_Email,'ALERT: We had ###2 DeadLocks in the last ###1 Hours on Server: ','','ALERTA: Aconteceram ###2 DeadLocks as ultimas ###1 Horas no Servidor : ','','DeadLocks Occurrence',NULL,'Ocorrências de DeadLocks',NULL),
		('Database Growth',			'stpAlert_Database_Growth',3600,0,5,@Fl_Language,						0,1,		20,		'GB',		@Ds_Profile_Email,	@Ds_Email,'ALERT: We had a large Database Growth in the Last 24 Hours on Server : ','','ALERTA: Tivemos um crescimento grande de base nas últimas 24 horas no Servidor : ','','Database Growth',NULL,'Crescimento da Base',NULL),
		('MaxSize Growth',			'stpAlert_MaxSize_Growth',60,0,24,@Fl_Language,						1,1,		80,		'Percent',	@Ds_Profile_Email,	@Ds_Email,'ALERT: There is a file with more than ###1% of the Maxsize used on Server: ','CLEAR: There is not a file with more than ###1% of the Maxsize used on Server: ','ALERTA: Existe um arquivo com mais de ###1% de utilização do Maxsize no servidor: ','CLEAR: Não existe um arquivo com mais de ###1% de utilização do Maxsize no servidor: ','SQL Server File(s)','TOP 50 - Process Executing on Database','Arquivo(s) do SQL Server','TOP 50 - Processos executando no Banco de Dados'),
		('CPU Utilization MI',  	 'stpAlert_CPU_Utilization_MI',NULL,NULL,NULL,    @Fl_Language,    1,   0,    85,    'Percent', @Ds_Profile_Email,	@Ds_Email,'ALERT: Cpu utilization is greater than ###1% on Server: ','CLEAR: Cpu utilization is lower than ###1% on Server: ',	'ALERTA: O Consumo de CPU está acima de ###1% no Servidor: ',      'CLEAR: O Consumo de CPU está abaixo de ###1% no Servidor: ', 	   'CPU Utilization', 'TOP 50 - Process Executing on Database',  'Consumo de CPU no Servidor',      'TOP 50 - Processos executando no Banco de Dados'),
		('Database Mirroring',  	 'stpAlert_Status_DB_Mirror',NULL,NULL,NULL,    @Fl_Language,    0,   0,    NULL,    NULL, @Ds_Profile_Email,	@Ds_Email,'ALERT: The DB Mirror Status has changed on Server: ','',	'ALERTA: O Status do Database Mirror mudou no Servidor: ',      '', 	   'Database Mirroring Status', '',  'Status do Database Mirroring',      ''),
	    ('Failover Cluster Active Node',  	 'stpAlert_Cluster_Active_Node',NULL,NULL,NULL,    @Fl_Language,    0,   0,    NULL,    NULL, @Ds_Profile_Email,	@Ds_Email,'ALERT: The Failover Cluster Active Node has Changed','',	'ALERTA: O nó ativo do Cluster mudou',      '', 	   'Failover Cluster Nodes Now', '',  'Failover Cluster Nodes agora',      ''),
	    ('Failover Cluster Node Status',  	 'stpAlert_Cluster_Node_Status',NULL,NULL,NULL,    @Fl_Language,    1,   0,    NULL,    NULL, @Ds_Profile_Email,	@Ds_Email,'ALERT: Some Failover Cluster Node are not UP','CLEAR: ALL Failover Cluster Nodes are UP',	'ALERTA: Algum nó do Cluster não está com o status UP',      'CLEAR: Todos os nós do Cluster estão com o status UP', 	   'Failover Cluster Nodes', '',  'Nós do Cluster',      ''),
	    ('AlwaysON AG STATUS',	'stpAlert_AlwaysON_AG_Status',NULL,NULL,NULL,	@Fl_Language,	0,	0,	NULL,		NULL,	@Ds_Profile_Email,	@Ds_Email,'ALERT: The AlwaysON Status are not SYNCHRONIZED and HEALTHY on Server: ','CLEAR: The AlwaysON Status are SYNCHRONIZED and HEALTHY on Server: ',	'ALERTA: O Status do AlwaysON AG está difernete de SYNCHRONIZED e HEALTHY no Servidor: ',	'CLEAR: O Status do AlwaysON AG está como SYNCHRONIZED e HEALTHY no Servidor: ','AlwaysON AG Dadabase Status','TOP 50 - Process Executing on Database',	'Status das bases do AlwaysON AG','TOP 50 - Processos executando no Banco de Dados'),
		('Index Fragmentation','stpAlert_Index_Fragmentation',25200,0,5,@Fl_Language,0,0,7,'Days', @Ds_Profile_Email,	@Ds_Email,'ALERT: We have a Index Fragmented for more than ###1 days on Server : ','',	'ALERTA: Temos pelo menos um índice Fragmentado por mais de ###1 dias no Servidor: ',      '', 	   'Indexes Fragmented for a long time', '',  'Indices Fragmentados por muito tempo',      '')

			
		-- Alert that needs more than one metric			
		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 32, 
				[Ds_Metric_2] = 'GB'
		WHERE [Nm_Alert] =  'Memory Available';

		-- Alert that needs more than one metric			
		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 65536, --Index with 500 MB 
				[Ds_Metric_2] = 'Pages'
		WHERE [Nm_Alert] =  'Index Fragmentation';
							
		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 1, 
				[Ds_Metric_2] = 'Minute'
		WHERE [Nm_Alert] =  'CPU Utilization MI';
					
		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 10, 
				[Ds_Metric_2] = 'GB'
		WHERE [Nm_Alert] IN ('Large LDF File');
		
		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 1, --SPID that is generating the lock must be executing for at least 1 minute
				[Ds_Metric_2] = 'minute'
		WHERE [Nm_Alert] IN ('Blocked Process','Blocked Long Process');
		
		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 10240, --GB to sent a log alerta
				[Ds_Metric_2] = 'MB'
		WHERE [Nm_Alert] = 'Log Full';

		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 10000, 
				[Ds_Metric_2] = 'MB'
		WHERE [Nm_Alert] = 'Tempdb MDF File Utilization';

		UPDATE [dbo].[Alert_Parameter]
		SET
				[Vl_Parameter_2] = 24, 
				[Ds_Metric_2] = 'Hour'
		WHERE [Nm_Alert] = 'Slow File Growth';

		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 5, 
				[Ds_Metric_2] = 'Minutes'
		WHERE [Nm_Alert] = 'Slow Queries';

		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 24, 
				[Ds_Metric_2] = 'Hour'
		WHERE [Nm_Alert] = 'Database Errors';

	
		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 5, 
				[Ds_Metric_2] = 'MB'
		WHERE [Nm_Alert] = 'Slow Disk Every Hour';


		UPDATE [dbo].[Alert_Parameter]
		SET		[Vl_Parameter_2] = 100, 
				[Ds_Metric_2] = 'Quantity'
		WHERE [Nm_Alert] = 'DeadLock';
		
		IF CONVERT(char(20), SERVERPROPERTY('IsClustered')) = 1
			UPDATE [dbo].[Alert_Parameter]
			SET Fl_Enable = 1
			WHERE Nm_Alert IN ('Failover Cluster Active Node','Failover Cluster Node Status')
		
END

--EXEC stpConfiguration_Table 'fabricioflima@gmail.com','MSSQLServer',1
	
--select * from [dbo].Alert_Parameter
GO
