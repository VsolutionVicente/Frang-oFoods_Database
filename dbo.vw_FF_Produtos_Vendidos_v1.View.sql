ALTER view [dbo].[vw_FF_Produtos_Vendidos] as
select Saidas.Data_v1                                          as Data_V1,
	   Produto.Cod_produto                                     as Cod_Produto, 
	   Produto.Desc_produto_nf                                 as Produto, 
	   sum(ISNULL(Saidas_Item.QTDE_PRI, 0))                    as Peso, 
	   sum(ISNULL(Saidas_Item.QTDE_AUX, 0))                    as Caixas
  from [SATKFRANGAO].[dbo].tbSaidas Saidas
       inner join [SATKFRANGAO].[dbo].tbSaidasItem Saidas_Item
	           on Saidas.Chave_fato = Saidas_Item.Chave_fato
	   inner Join [SATKFRANGAO].[dbo].tbProduto Produto
	           on Saidas_Item.Cod_produto = Produto.Cod_produto
where Cod_tipo_mv in ('T500','M500', 'T501','F500','T508','T509','T700')
  AND Saidas.Status <> 'C'
  AND Saidas_Item.QTDE_AUX <> 0
  group by 
		Saidas.Data_v1            ,
		Produto.Cod_produto       ,
		Produto.Desc_produto_nf   

GO
