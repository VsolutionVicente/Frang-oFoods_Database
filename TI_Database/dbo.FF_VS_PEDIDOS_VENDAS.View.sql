USE [TI_Database]
GO
/****** Object:  View [dbo].[FF_VS_PEDIDOS_VENDAS]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[FF_VS_PEDIDOS_VENDAS] AS
select isnull(Supervisor.Cod_cadastro,0)                       as "Cod Supervisor",
       isnull(Supervisor.Nome_cadastro,'ñ Cadastrado')         as "Supervisor",
	   isnull(Vendedor.Cod_cadastro,0)                         as "Cod Vendedor",
	   isnull(VendedorCadastro.Nome_cadastro,'ñ Cadastrado')   as "Vendedor",
       Saidas.Cod_cli_for                                      as "Cod Cliente", 
	   CadastroGeral.Nome_cadastro                             as "Cliente",
	   Saidas.Data_movto                                       as Data_movto,
	   Year(Saidas.Data_movto)                                 as Ano,
	   Month(Saidas.Data_movto)                                as Mes,
	   Saidas.Data_v1                                          as Data_V1,
	   Saidas.Num_docto                                        as Pedido,
	   case when Saidas.Tipo_frete1 = 'C'
	        then 'C - CIF'
			else 'F - FOB'
			end                                                as Tipo_Frete, 
	   case when Saidas.Cod_tipo_mv ='M500'
		    then 'Mobile'
		    else 'Interno'
	   end                                                     as "Tipo Pedido",
	   Produto.Cod_produto                                     as "Cod Produto", 
	   Produto.Desc_produto_nf                                 as "Produto", 
	   ISNULL(Saidas_Item.QTDE_PRI, 0)                         as "Peso Pedido", 
	   ISNULL(Saidas_Item.QTDE_AUX, 0)                         as "Caixas Pedido", 
	   Saidas_Item.Valor_liquido                               as "Faturado Pedido",
	   Saidas_Item.Valor_liquido /                                
	   ISNULL(Saidas_Item.QTDE_PRI, 0)                         as "MIX Pedido",
	   ISNULL(Cliente.Perc_desconto,0)                         as "Perc Desconto"
  from [SATKFRANGAO].[dbo].tbSaidas Saidas
       inner join [SATKFRANGAO].[dbo].tbSaidasItem Saidas_Item
	           on Saidas.Chave_fato = Saidas_Item.Chave_fato
	   INNER JOIN [SATKFRANGAO].[dbo].TBCADASTROGERAL CadastroGeral
		 	   on CadastroGeral.COD_CADASTRO = Saidas.COD_CLI_FOR
	   inner join [SATKFRANGAO].[dbo].TbCliente Cliente 
		  	   on Cliente.Cod_cadastro = CadastroGeral.Cod_cadastro
	   inner Join [SATKFRANGAO].[dbo].tbProduto Produto
	           on Saidas_Item.Cod_produto = Produto.Cod_produto
	   LEFT  Join [SATKFRANGAO].[dbo].TbVendedor Vendedor
	           on Vendedor.Cod_cadastro = Cliente.Cod_vendedor
	   LEFT  Join [SATKFRANGAO].[dbo].TbCadastroGeral VendedorCadastro
	           on VendedorCadastro.Cod_cadastro = Cliente.Cod_vendedor
	   LEFT  Join [SATKFRANGAO].[dbo].TbCadastroGeral Supervisor
	           on Supervisor.Cod_cadastro = Vendedor.Cod_supervisor_vda
where Cod_tipo_mv in ('T500','M500', 'T501')
  AND Saidas.Status <> 'C'
  AND Saidas_Item.QTDE_AUX <> 0
GO
