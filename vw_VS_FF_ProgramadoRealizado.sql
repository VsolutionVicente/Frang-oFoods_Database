create or alter view vw_VS_FF_ProgramadoRealizado as
select Format(Entrada.Data_movto,'dd/MM/yyyy') data, 
       Entrada.Num_docto, 
	   Entrada_Item.Cod_produto,
       Programacao.Qtde_pri Programados_KG,
	   Programacao.Qtde_aux Programados_CX, 
       Producao.Qtde_pri Producao_KG,
	   Producao.Qtde_aux Producao_CX,
       Pedidos.Qtde_pri Pedidos_KG,
	   Pedidos.Qtde_aux Pedidos_CX
  from [SATKFRANGAO].[dbo].TBENTRADAS Entrada 
  join [SATKFRANGAO].[dbo].tbEntradasItem Entrada_Item 
    on Entrada.Chave_fato = Entrada_Item.Chave_fato 
  join (select Entrada.Data_movto, 
               Entrada.Num_docto, 
	           Entrada_Item.Cod_produto,
               Entrada_Item.Qtde_pri,
               Entrada_Item.Qtde_aux
		  from [SATKFRANGAO].[dbo].TBENTRADAS Entrada 
          join [SATKFRANGAO].[dbo].tbEntradasItem Entrada_Item 
            on Entrada.Chave_fato = Entrada_Item.Chave_fato 
		 where Entrada.cod_docto in ('RPE')
        ) Producao on Entrada.Data_movto = Producao.Data_movto
		          and Entrada_Item.Cod_produto = Producao.Cod_produto
  join (select Entrada.Data_movto, 
               Entrada.Num_docto, 
	           Entrada_Item.Cod_produto,
               Entrada_Item.Qtde_pri,
               Entrada_Item.Qtde_aux
		  from [SATKFRANGAO].[dbo].TBENTRADAS Entrada 
          join [SATKFRANGAO].[dbo].tbEntradasItem Entrada_Item 
            on Entrada.Chave_fato = Entrada_Item.Chave_fato 
		 where Entrada.cod_docto in ('ORP')
        ) Programacao on Entrada.Data_movto = Programacao.Data_movto
		             and Entrada_Item.Cod_produto = Programacao.Cod_produto
 LEFT JOIN (select Saidas.Data_v1,
     	           Saidas_Item.Cod_produto, 
	               sum(ISNULL(Saidas_Item.QTDE_PRI, 0)) QTDE_PRI, 
	               sum(ISNULL(Saidas_Item.QTDE_AUX, 0)) QTDE_AUX
              from [SATKFRANGAO].[dbo].tbSaidas Saidas
              join [SATKFRANGAO].[dbo].tbSaidasItem Saidas_Item
	            on Saidas.Chave_fato = Saidas_Item.Chave_fato
             where Cod_tipo_mv in ('T500','M500', 'T501')
               AND Saidas.Status <> 'C'
               AND Saidas_Item.QTDE_AUX <> 0
			 group by 
			       Saidas.Data_v1,
     	           Saidas_Item.Cod_produto) Pedidos on Entrada.Data_movto = Pedidos.Data_v1
		                                              and Entrada_Item.Cod_produto = Pedidos.Cod_produto
 where Entrada.Data_movto >= '20210601'
   and Entrada_Item.Cod_produto like 'PA%'
   AND Entrada.cod_docto in ('ORP')
