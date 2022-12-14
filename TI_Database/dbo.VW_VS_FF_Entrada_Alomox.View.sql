USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_VS_FF_Entrada_Alomox]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[VW_VS_FF_Entrada_Alomox] 
as
select Tipo_Movimento.Descricao,
       Entrada.Cod_tipo_mv,
       format(Entrada.Data_movto,'dd/mm/yyyy','pt-br') DataMovemento, 
	   Day(Entrada.Data_movto)   Dia, 
	   Month(Entrada.Data_movto) Mês, 
	   year(Entrada.Data_movto)  Ano, 
       Entrada.Cod_docto,
	   TipoDocumento.Desc_documento,
	   Entrada.Cod_cli_for, 
	   Cadastro_Geral.Nome_cadastro,
	   Entrada.Num_docto,
	   Entrada_Item.Cod_produto, 
	   Produto.Desc_produto_nf,
	   Produto.Tipo_produto,
	   format(Entrada_Item.Qtde_pri,'N','pt-BR') Qtde_Pri, 
	   format(Entrada_Item.Valor_liquido,'N','pt-BR') Valor
  from [SATKFRANGAO].[dbo].tbentradas Entrada   
       inner join [SATKFRANGAO].[dbo].tbEntradasItem  Entrada_Item
	           on Entrada.Chave_fato = Entrada_Item.Chave_fato
	    inner Join [SATKFRANGAO].[dbo].tbCadastroGeral Cadastro_Geral
		        on Entrada.Cod_cli_for = Cadastro_Geral.Cod_cadastro
		inner Join [SATKFRANGAO].[dbo].tbProduto Produto
		        on Produto.Cod_produto = Entrada_Item.Cod_produto
		Inner join [SATKFRANGAO].[dbo].tbTipoMvEstoque Tipo_Movimento
		        on Tipo_Movimento.Cod_tipo_mv = Entrada.Cod_tipo_mv
		inner join [SATKFRANGAO].[dbo].tbTipoDocumento TipoDocumento
		        on TipoDocumento.Cod_docto = Entrada.Cod_docto
where Produto.Cod_produto like  'AL%'
  and Tipo_Movimento.Cod_tipo_mv = 'T103'
  and Entrada.Status = 'A'
GO
