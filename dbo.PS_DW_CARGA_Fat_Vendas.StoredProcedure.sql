USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_DW_CARGA_Fat_Vendas]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[PS_DW_CARGA_Fat_Vendas]
	@Data DATE = null
AS
DECLARE @MENS_ERRO  VARCHAR(4000)
begin 
	BEGIN TRY
		SET NOCOUNT ON
		set @MENS_ERRO = 'Definindo a data de Processamento';
		if @Data is null 
		begin
			set @Data = cast(getdate()-1 as date);
		end; 

		set @MENS_ERRO = 'Apagamos os Dados na tabela Fato Fat_Vendas';
		/*Apagamos dados da tabela de Produção*/
		DELETE  DW_TI.dbo.Fat_Vendas WHERE Dt_Transacao = @DATA;
	
		/*Tabela Fat_Producao*/
		set @MENS_ERRO = '/*Tabela Fat_Vendas*/';
		Insert Into DW_TI.dbo.Fat_Vendas (
					Dt_FaturamentoVenda		,
					Dt_hh_FaturamentoVenda	,
					Dt_MovimentoVenda		,
					Dt_Transacao			,
					Fl_TipoMovimentoVenda	,
					Sk_Vendedor				,
					Sk_Cliente				,
					Fl_CondicaooPagtoVenda	,
					Pc_DescontoVenda	    ,
					Nr_NotaVenda	        ,
					Sk_PRODUTO				,
					Ps_PesoVenda	        ,
					Qn_CaixasVenda	        ,
					VL_FaturadoVenda		,
					Id_ListaPreco           ,
					VL_listaMinimo          ,
					VL_listaTabela          )
		SELECT cast(S.DATA_V1 as date)         as Dt_FaturamentoVenda,
			   S.Data_hora                     as Dt_hh_FaturamentoVenda,
			   S.DATA_MOVTO                    as Dt_MovimentoVenda, 
			   cast(case when datepart(HH,S.Data_hora) <= 6
						 then dateadd(D,-1,S.Data_hora)
						 else S.Data_hora 
						 end as date)          as Dt_Transacao,
			   s.Cod_tipo_mv                   as Fl_TipoMovimentoVenda,
			   Sk_Vendedor                     as Sk_Vendedor, 
			   Sk_Cliente                      as Sk_Cliente, 
			   s.Cod_cond_pgto                 as Fl_CondicaooPagtoVenda,
			   Isnull(Cli.Perc_desconto,0)     as Pc_DescontoVenda,
			   S.NUM_DOCTO                     as Nr_NotaVenda, 
			   Produtos.Sk_Produto             as Id_PRODUTO, 
			   ISNULL(SI.QTDE_PRI, 0)          as Ps_PesoVenda, 
			   ISNULL(SI.QTDE_AUX, 0)          as Qn_CaixasVenda, 
			   case when TMV.Classe =8 then 0
					else SI.Valor_liquido 
					end                        as VL_FaturadoVenda,
			   LPreco.Id_ListaPreco            as Id_ListaPreco,
			   LPreco.Vl_PrecoMinimoListaPreco as VL_listaMinimo,
			   LPreco.Vl_PrecoTabelaListaPreco as VL_listaTabela
		FROM [SATKFRANGAO].[dbo].TBSAIDASITEM SI
			 INNER JOIN [SATKFRANGAO].[dbo].TBSAIDAS S 
					 on S.CHAVE_FATO = SI.CHAVE_FATO
					and SI.NUM_SUBITEM = 0
			 INNER JOIN [SATKFRANGAO].[dbo].TBTIPOMVESTOQUE TMV 
					 on TMV.COD_TIPO_MV = S.COD_TIPO_MV
			 INNER JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL GCLI 
					 on GCLI.COD_CADASTRO = S.COD_CLI_FOR
			 inner join [SATKFRANGAO].[dbo].TbCliente Cli 
					 on Cli.Cod_cadastro = GCLI.Cod_cadastro
			 inner join [DW_TI].[dbo].[Dim_Produtos] Produtos
					 on Produtos.Id_Produto = SI.COD_PRODUTO
			 inner join [DW_TI].[dbo].[Dim_Vendedores] Vendedores
					 on Vendedores.Id_Vendedor = S.COD_VEND_COMP
			 inner join [DW_TI].[dbo].[Dim_Clientes] Clientes
					 on Clientes.Id_Cliente = S.COD_CLI_FOR
			 inner join [DW_TI].[dbo].[Fat_ListaPreco] LPreco
			         on LPreco.Id_ListaPreco = s.Cod_lista
					and LPreco.Sk_Produto = Produtos.Sk_Produto
					--and LPreco.Dt_Transacao = cast(S.DATA_V1 as date) 
					and LPreco.Dt_Transacao = cast(case when datepart(HH,S.Data_hora) <= 6
						                                then dateadd(D,-1,S.Data_hora)
						                                else S.Data_hora 
						                                end as date) 
		WHERE TMV.CLASSE in ('5','8')
			  AND S.STATUS_CTB = 'S'
			  AND S.STATUS <> 'C'
			  AND S.COD_DOCTO = 'NE'
			  AND SI.QTDE_AUX <> 0
			  and s.Cod_tipo_mv in ('T520','T521','T530','T568')
			  AND cast(case when datepart(HH,S.Data_hora) <= 6
						    then dateadd(D,-1,S.Data_hora)
						    else S.Data_hora 
						    end as date)     = @Data

	END TRY 
	BEGIN CATCH
		/* GERAMOS UMA EXCEÇÃO BASEADA NO ERRO ORIGINAL */
		set @MENS_ERRO = 'PS_DW_CARGA_Fat_Vendas '  + @MENS_ERRO + ' - ';
		RAISERROR(@MENS_ERRO , 16, 1)		
	END CATCH
end
GO
