USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_VS_Vendas_Redes]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[VW_VS_Vendas_Redes]
as
SELECT Fat_Vendas.Dt_FaturamentoVenda,
       Fat_Vendas.Dt_MovimentoVenda,
       Fat_Vendas.Dt_Transacao, 
	   Fat_Vendas.Fl_TipoMovimentoVenda, 
	   Dim_Vendedores.Id_Vendedor, 
	   Dim_Vendedores.Nm_Vendedor, 
	   Dim_Clientes.Id_Cliente, 
	   Dim_Clientes.Nm_Cliente,
	   Fat_Vendas.Fl_CondicaooPagtoVenda,
	   Dim_Clientes.Pc_DescontoCliente,
	   Dim_Clientes.Id_GrupoEconomicoCliente,
	   Dim_Clientes.Nm_GrupoEconomicoCliente,
	   Fat_Vendas.Nr_NotaVenda,
	   Dim_Produtos.Id_Produto, 
	   Dim_Produtos.Nm_Produto, 
	   Fat_Vendas.Ps_PesoVenda,
	   Fat_Vendas.Qn_CaixasVenda,
	   Fat_Vendas.VL_FaturadoVenda,
	   Fat_Vendas.VL_FaturadoVenda / 
	   Fat_Vendas.Ps_PesoVenda as Vl_KiloVenda,
	   Fat_Vendas.Vl_listaMinimo,
	   /*Lista Ajustada*/
	   (Dim_Clientes.Pc_DescontoCliente/100+1) * Fat_Vendas.Vl_listaMinimo as Lista_Ajustada,
	   /*Diferença entra o Valor de Venda com a Lista Ajustada*/
	   (Fat_Vendas.VL_FaturadoVenda / Fat_Vendas.Ps_PesoVenda) - 
	   (Dim_Clientes.Pc_DescontoCliente/100+1) * Fat_Vendas.Vl_listaMinimo as DIF_TabelaAjustada,
	   Dim_Clientes.GN_CNPJ as CNPJ,
	   Dim_Clientes.Rota
	   
  FROM [DW_TI].[dbo].[Fat_Vendas]
       inner join [DW_TI].[dbo].[Dim_Clientes]
	           on Fat_Vendas.Sk_Cliente =  Dim_Clientes.Sk_Cliente
       inner Join [DW_TI].[dbo].[Dim_Produtos]
	           on Fat_Vendas.Sk_PRODUTO = Dim_Produtos.Sk_Produto
	   left  join [DW_TI].[dbo].[Dim_Vendedores]
	           on Dim_Vendedores.Sk_Vendedor = Fat_Vendas.Sk_Vendedor

GO
