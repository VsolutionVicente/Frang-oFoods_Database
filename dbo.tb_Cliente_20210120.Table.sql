USE [TI_Database]
GO
/****** Object:  Table [dbo].[tb_Cliente_20210120]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_Cliente_20210120](
	[Cod_cadastro] [int] NOT NULL,
	[Cod_lista] [smallint] NULL,
	[Cod_grupo_limite] [int] NULL,
	[Cod_risco] [int] NULL,
	[Perc_desconto] [decimal](5, 2) NULL,
	[Data_ultima_compra] [datetime] NULL,
	[Vlr_ultima_compra] [decimal](15, 2) NULL,
	[Vlr_maior_compra] [decimal](15, 2) NULL,
	[Limite_credito] [decimal](15, 2) NULL,
	[Cod_moeda] [smallint] NULL,
	[Cod_vendedor] [int] NULL,
	[Cod_banco_caixa] [int] NULL,
	[Data_renova_credit] [datetime] NULL,
	[Consumidor_final] [char](1) NULL,
	[Prazo_atraso_max] [int] NULL,
	[Periodicidade] [char](1) NULL,
	[Info_dia] [char](7) NULL,
	[Hora_ligacao] [char](6) NULL,
	[Hora_entrega_ini1] [char](6) NULL,
	[Hora_entrega_fim1] [char](6) NULL,
	[Hora_entrega_ini2] [char](6) NULL,
	[Hora_entrega_fim2] [char](6) NULL,
	[Aceita_subst_trib] [char](1) NULL,
	[Perc_subst_trib] [decimal](5, 2) NULL,
	[Prazo_medio_max] [smallint] NULL,
	[Cod_forma_cob] [int] NULL,
	[Qtde_funcionario] [smallint] NULL,
	[Faturamento_mes] [decimal](15, 2) NULL,
	[Imovel_proprio] [char](1) NULL,
	[Data_alt_contrato] [datetime] NULL,
	[Capital_social_integ] [decimal](15, 2) NULL,
	[Data_abertura_firma] [datetime] NULL,
	[Data_primeira_compra] [datetime] NULL,
	[Qtde_compras] [int] NULL,
	[Prazo_medio_compras] [smallint] NULL,
	[Valor_medio_compras] [decimal](15, 2) NULL,
	[Media_atraso_pagto] [smallint] NULL,
	[Cod_transportadora1] [int] NULL,
	[Cod_transportadora2] [int] NULL,
	[Banco_caixa_fixo] [char](1) NULL,
	[Perc_redutor_cmsv] [decimal](5, 2) NULL,
	[Valor_saldo_rec] [decimal](15, 2) NULL,
	[Valor_saldo_pag] [decimal](15, 2) NULL,
	[Valor_saldo_rec_ad] [decimal](15, 2) NULL,
	[Valor_saldo_pag_ad] [decimal](15, 2) NULL,
	[Valor_saldo_pve] [decimal](15, 2) NULL,
	[Data_alteracao_fin] [datetime] NULL,
	[Data_alteracao_pve] [datetime] NULL
) ON [PRIMARY]
GO
