USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_vs_fg_Custos]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   View [dbo].[VW_vs_fg_Custos] as
select 'Entradas' as Tipo_Operacao,
       Entradas.Cod_Tipo_MV as TMV,
	   TipoMvEstoque.Descricao,
	   Entradas.Data_movto, 
	   Entradas.Data_ent_sai,
	   Entradas.Data_emissao,
	   Entradas.Data_cancela,
	   Entradas.Data_v1,
	   Entradas.Data_v2,
	   Entradas.Status,
	   TipoDocumento.Classe, 
	   TipoDocumento.Cod_docto,
	   TipoDocumento.Desc_documento,
	   Entradas.Num_docto,
	   Entradas.Cod_cli_for Cliente_Fornecedor, 	   
	   CLIFOR.Nome_cadastro,
	   CLIFOR.Tipo_cadastro,
	   CLIFOR.Data_cadastro,
	   CLIFOR.Data_alteracao,
	   Produto.Cod_produto,
	   Produto.Desc_produto_nf, 
	   EntradasItem.Qtde_pri,
	   EntradasItem.Qtde_aux,
	   EntradasItem.Peso_liquido,
	   EntradasItem.Peso_bruto,
	   EntradasItem.Valor_liquido,
	   EntradasItem.Valor_cancelado,
	   CentroCusto.Cod_ccusto,
	   CentroCusto.Nome_ccusto,
	   EntradasItem.Cod_reduz_conta,
	   EntradasItem.Valor_contabil_custeio_fiscal,
       EntradasItem.Valor_contabil_custeio_rcpe,
	   pl.Cod_conta,
	   pl.Desc_conta,
	   pl.Tipo_conta,
	   pl.Natureza_conta,
	   pl.Nivel_conta,
	   pl.Aceita_lancto
  from [SATKFrangao].[dbo].TbEntradas Entradas
       inner join [SATKFrangao].[dbo].TbEntradasItem EntradasItem
	           on EntradasItem.Chave_fato = Entradas.Chave_fato
       inner join [SATKFrangao].[dbo].[tbTipoMvEstoque] TipoMvEstoque
	           on Entradas.Cod_tipo_mv = TipoMvEstoque.Cod_tipo_mv
	    left join [SATKFRANGAO].[dbo].[tbTipoDocumento] TipoDocumento
		        on TipoDocumento.Cod_docto = Entradas.Cod_docto
       inner join [SATKFrangao].[dbo].[tbCadastroGeral] CLIFOR
	           on CLIFOR.Cod_cadastro = Entradas.Cod_cli_for
       inner join [SATKFrangao].[dbo].[tbProduto] Produto
	           on Produto.Cod_produto = EntradasItem.Cod_produto
        left join SATKFRANGAO.dbo.tbCentroCusto CentroCusto
		        on CentroCusto.Cod_ccusto = EntradasItem.Cod_ccusto
         left  join [SATKFRANGAO].[dbo].tbPlanoConta pl on EntradasItem.Cod_reduz_conta = pl.Cod_reduz_conta
  --where Entradas.Data_movto >='20220418'
  where Entradas.Data_movto >='20211130'
union all 
select 'Saidas' as Tipo_Operacao,
       Saidas.Cod_Tipo_MV as TMV,
	   TipoMvEstoque.Descricao,
	   Saidas.Data_movto, 
	   Saidas.Data_ent_sai,
	   Saidas.Data_emissao,
	   Saidas.Data_cancela,
	   Saidas.Data_v1,
	   Saidas.Data_v2,
	   Saidas.Status,
	   TipoDocumento.Classe, 
	   TipoDocumento.Cod_docto,
	   TipoDocumento.Desc_documento,
	   Saidas.Num_docto,
	   Saidas.Cod_cli_for Cliente_Fornecedor, 	   
	   CLIFOR.Nome_cadastro,
	   CLIFOR.Tipo_cadastro,
	   CLIFOR.Data_cadastro,
	   CLIFOR.Data_alteracao,
	   Produto.Cod_produto,
	   Produto.Desc_produto_nf, 
	   SaidasItem.Qtde_pri,
	   SaidasItem.Qtde_aux,
	   SaidasItem.Peso_liquido,
	   SaidasItem.Peso_bruto,
	   SaidasItem.Valor_liquido,
	   SaidasItem.Valor_cancelado,
	   CentroCusto.Cod_ccusto,
	   CentroCusto.Nome_ccusto,
	   SaidasItem.Cod_reduz_conta,
	   SaidasItem.Valor_contabil_custeio_fiscal,
       SaidasItem.Valor_contabil_custeio_rcpe,
	   pl.Cod_conta,
	   pl.Desc_conta,
	   pl.Tipo_conta,
	   pl.Natureza_conta,
	   pl.Nivel_conta,
	   pl.Aceita_lancto

  from [SATKFrangao].[dbo].TbSaidas Saidas
       inner join [SATKFrangao].[dbo].TbSaidasItem SaidasItem
	           on SaidasItem.Chave_fato = Saidas.Chave_fato
       inner join [SATKFrangao].[dbo].[tbTipoMvEstoque] TipoMvEstoque
	           on Saidas.Cod_tipo_mv = TipoMvEstoque.Cod_tipo_mv
	    left join [SATKFRANGAO].[dbo].[tbTipoDocumento] TipoDocumento
		        on TipoDocumento.Cod_docto = Saidas.Cod_docto
       inner join [SATKFrangao].[dbo].[tbCadastroGeral] CLIFOR
	           on CLIFOR.Cod_cadastro = Saidas.Cod_cli_for
       inner join [SATKFrangao].[dbo].[tbProduto] Produto
	           on Produto.Cod_produto = SaidasItem.Cod_produto
        left join SATKFRANGAO.dbo.tbCentroCusto CentroCusto
		        on CentroCusto.Cod_ccusto = SaidasItem.Cod_ccusto
         left  join [SATKFRANGAO].[dbo].tbPlanoConta pl on SaidasItem.Cod_reduz_conta = pl.Cod_reduz_conta
--  where Saidas.Data_movto >='20220418'
  where Saidas.Data_movto >='20211130'
GO
