USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_VS_FF_Pedido_Notas_ORIGINAL]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[VW_VS_FF_Pedido_Notas_ORIGINAL] as
select Pedidos.Num_docto                  Nro_Pedido,
       ROS.Num_docto                      Nro_Romaneio,
       Notas.Num_docto                    Nro_Nota,
       Pedidos.Cod_tipo_mv                TMV_Pedido,
       ROS.Cod_tipo_mv                    TMV_Romaneio,
       Notas.Cod_tipo_mv                  TMV_Nota,
	   case when Pedidos.Status = 'C'
	        then 'C - Cancelado'
			else 'A - Ativo'
			end                           Status_Pedido,
       Pedidos.Cod_cli_for                Cliente,
	   Cliente.Cpf_Cgc                    CPF_CNPJ,
	   Cliente.Nome_Cadastro              Nome_Cliente,
	   isnull(Cliente_COMP.Cod_grupo_limite,0) Id_GrupoEconomicoCliente,
	   isnull(Grupo.Nome, 'NAO INFORMADO') Nm_GrupoEconomicoCliente,
       Pedidos.Cod_vend_comp              Vendedor,
	   Vendedor.Nome_Cadastro             Nome_Vendedor,
	   Supervisor_cad.Cod_Cadastro        Supoervisor,
	   Supervisor_cad.Nome_cadastro       Nome_Supervisor,
       case when Pedidos.Tipo_frete1 = 'C'
	        then 'C - CIF'
			else 'F - FOB'
			end                           Tipo_Frete_Pedido, 
       Pedidos.Data_movto                 Data_Movimento_Pedido,
       Pedidos.Data_hora                  DataHora_Movimento_Pedido,
       Pedidos.Data_v1                    Data_V1_Pedido,
       Pedidos.Valor_liquido              Valor_liquido_Pedido,
       ROS.Data_movto                     Data_Movimento_Romaneio,
       ROS.Data_v1                        Data_V1_Romaneio,
       ROS.Valor_liquido                  Valor_liquido_Romaneio,
	   ROS.Peso_bruto		              PesoBruto_Romaneio,
	   ROS.Peso_liquido                   PesoLiquido_Romaneio,
       Notas.Data_movto                   Data_Movimento_Nota,
       Notas.Data_v1                      Data_V1_Nota,
       Notas.Valor_liquido                Valor_liquido_Nota,
	   Notas.Peso_bruto		              PesoBruto_Nota,
	   Notas.Peso_liquido                 PesoLiquido_Nota,
	   Pedidos_Itens.Cod_produto		  Codigo_Produto,
	   Produtos.Desc_produto_nf           Produto,
	   coalesce(Pedidos_Itens.Valor_total,0) Valor_Pedido, 
	   coalesce(Notas_Itens.Valor_total,0)   Valor_Nota, 
	   coalesce(Pedidos_Itens.Qtde_pri,0) Qtde_pri_Pedido, 
	   coalesce(ROS_Itens.Qtde_pri,0)     Qtde_pri_Romaneio, 
	   coalesce(Notas_Itens.Qtde_pri,0)   Qtde_pri_Nota, 
	   coalesce(Pedidos_Itens.Qtde_aux,0) Qtde_aux_Pedido, 
	   coalesce(ROS_Itens.Qtde_aux,0)     Qtde_aux_Romaneio, 
	   coalesce(Notas_Itens.Qtde_aux,0)   Qtde_aux_Nota,
	   ISNULL(Cliente_COMP.Perc_desconto,0) "Desc Redes",
	   Case 
	     when ISNULL(Cliente_COMP.Perc_desconto,0) >0
		 then 'Sim'
		 else 'Não'
		 End                                Rede,
	   case when Pedidos.Cod_cli_for = 52242
	        then coalesce(Pedidos_Itens.Valor_total,0) *2 
			else coalesce(Pedidos_Itens.Valor_total,0)
			end VLR_Pedido_2, 
	   case when Pedidos.Cod_cli_for = 52242
	        then coalesce(Notas_Itens.Valor_total,0) *2  
			else coalesce(Notas_Itens.Valor_total,0)
			end as VLR_Nota_2 


  from [SATKFRANGAO].[dbo].TBSAIDAS Pedidos
       inner join [SATKFRANGAO].[dbo].tbCadastroGeral Cliente
               on Cliente.Cod_cadastro = Pedidos.Cod_cli_for
        left join [SATKFRANGAO].[dbo].TBSAIDAS ROS
               on Pedidos.Chave_fato = ROS.Chave_fato_orig_un
              and Ros.Cod_docto = 'ROS'
        left join [SATKFRANGAO].[dbo].TBSAIDAS Notas
               on ROS.Chave_fato = Notas.Chave_fato_orig_un
              and Notas.Cod_docto = 'NE'
	   inner join [SATKFRANGAO].[dbo].tbSaidasItem Pedidos_Itens
	           on Pedidos.CHAVE_FATO = Pedidos_Itens.CHAVE_FATO
              and Pedidos_Itens.NUM_SUBITEM = 0
	   inner join [SATKFRANGAO].[dbo].TBPRODUTO Produtos 
	           ON Pedidos_Itens.COD_PRODUTO = Produtos.COD_PRODUTO
	    left join [SATKFRANGAO].[dbo].tbSaidasItem ROS_Itens
	           on ROS.CHAVE_FATO = ROS_Itens.CHAVE_FATO
			  and Pedidos_Itens.Cod_produto = ROS_Itens.Cod_produto
	    left join [SATKFRANGAO].[dbo].tbSaidasItem Notas_Itens
	           on Notas.CHAVE_FATO = Notas_Itens.CHAVE_FATO
			  and Pedidos_Itens.Cod_produto = Notas_Itens.Cod_produto
        left join [SATKFRANGAO].[dbo].tbCadastroGeral Vendedor
               on Vendedor.Cod_cadastro = Pedidos.Cod_vend_comp
	    LEFT join [SATKFRANGAO].[dbo].TbCliente Cliente_COMP 
		  	   on Cliente.Cod_cadastro = Cliente_COMP.Cod_cadastro
	   left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
		       on grupo.Cod_grupo_limite = Cliente_COMP.Cod_grupo_limite
	    LEFT join [SATKFRANGAO].[dbo].TbVendedor Vendedor_Sup
		  	   on Cliente.Cod_cadastro = Vendedor_Sup.Cod_cadastro
	    LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Supervisor_cad
		  	   on Supervisor_cad.Cod_cadastro = Vendedor_Sup.Cod_supervisor_vda
 where Pedidos.COD_DOCTO in ('PVE','PVB') 
   and Pedidos.Cod_tipo_mv not in ('T503')
   and Pedidos.Data_movto >= '20210101'
union 
select Pedidos.Num_docto                  Nro_Pedido,
       null					              Nro_Romaneio,
       Notas.Num_docto                    Nro_Nota,
       Pedidos.Cod_tipo_mv                TMV_Pedido,
       null                               TMV_Romaneio,
       Notas.Cod_tipo_mv                  TMV_Nota,
	   case when Pedidos.Status = 'C'
	        then 'C - Cancelado'
			else 'A - Ativo'
			end                           Status_Pedido,
       Pedidos.Cod_cli_for                Cliente,
	   Cliente.Cpf_Cgc                    CPF_CNPJ,
	   Cliente.Nome_Cadastro              Nome_Cliente,
	   isnull(Cliente_COMP.Cod_grupo_limite,0) Id_GrupoEconomicoCliente,
	   isnull(Grupo.Nome, 'NAO INFORMADO') Nm_GrupoEconomicoCliente,
       Pedidos.Cod_vend_comp              Vendedor,
	   Vendedor.Nome_Cadastro             Nome_Vendedor,
	   Supervisor_cad.Cod_Cadastro        Supoervisor,
	   Supervisor_cad.Nome_cadastro       Nome_Supervisor,
       case when Pedidos.Tipo_frete1 = 'C'
	        then 'C - CIF'
			else 'F - FOB'
			end                           Tipo_Frete_Pedido, 
       Pedidos.Data_movto                 Data_Movimento_Pedido,
       Pedidos.Data_hora                  Data_Movimento_Pedido,
       Pedidos.Data_v1                    Data_V1_Pedido,
       Pedidos.Valor_liquido              Valor_liquido_Pedido,
       null					              Data_Movimento_Romaneio,
       null					              Data_V1_Romaneio,
       null					              Valor_liquido_Romaneio,
	   null					              PesoBruto_Romaneio,
	   null					              PesoLiquido_Romaneio,
       Notas.Data_movto                   Data_Movimento_Nota,
       Notas.Data_v1                      Data_V1_Nota,
       Notas.Valor_liquido                Valor_liquido_Nota,
	   Notas.Peso_bruto		              PesoBruto_Nota,
	   Notas.Peso_liquido                 PesoLiquido_Nota,
	   Pedidos_Itens.Cod_produto		  Codigo_Produto,
	   Produtos.Desc_produto_nf           Produto,
	   coalesce(Pedidos_Itens.Valor_total,0) Valor_Pedido, 
	   coalesce(Notas_Itens.Valor_total,0)   Valor_Nota, 
	   coalesce(Pedidos_Itens.Qtde_pri,0) Qtde_pri_Pedido, 
	   0                                  Qtde_pri_Romaneio, 
	   coalesce(Notas_Itens.Qtde_pri,0)   Qtde_pri_Nota, 
	   coalesce(Pedidos_Itens.Qtde_aux,0) Qtde_aux_Pedido, 
	   0                                  Qtde_aux_Romaneio, 
	   coalesce(Notas_Itens.Qtde_aux,0)   Qtde_aux_Nota,
	   ISNULL(Cliente_COMP.Perc_desconto,0) "Perc Desconto",
	   Case 
	     when ISNULL(Cliente_COMP.Perc_desconto,0) >0
		 then 'Sim'
		 else 'Não'
		 End                                Rede,
	   case when Pedidos.Cod_cli_for = 52242
	        then coalesce(Pedidos_Itens.Valor_total,0) *2 
			else coalesce(Pedidos_Itens.Valor_total,0)
			end VLR_Pedido_2, 
	   case when Pedidos.Cod_cli_for = 52242
	        then coalesce(Notas_Itens.Valor_total,0) *2  
			else coalesce(Notas_Itens.Valor_total,0)
			end as VLR_Nota_2 

  from [SATKFRANGAO].[dbo].TBSAIDAS Pedidos
       inner join [SATKFRANGAO].[dbo].tbCadastroGeral Cliente
               on Cliente.Cod_cadastro = Pedidos.Cod_cli_for
	    LEFT join [SATKFRANGAO].[dbo].TbCliente Cliente_COMP 
		  	   on Cliente.Cod_cadastro = Cliente_COMP.Cod_cadastro
	   left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
		       on grupo.Cod_grupo_limite = Cliente_COMP.Cod_grupo_limite
	    LEFT join [SATKFRANGAO].[dbo].TbVendedor Vendedor_Sup
		  	   on Cliente.Cod_cadastro = Vendedor_Sup.Cod_cadastro
	    LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Supervisor_cad
		  	   on Supervisor_cad.Cod_cadastro = Vendedor_Sup.Cod_supervisor_vda
        left join [SATKFRANGAO].[dbo].TBSAIDAS Notas
               on Pedidos.Chave_fato = Notas.Chave_fato_orig_un
              and Notas.Cod_docto = 'NE'
	   inner join [SATKFRANGAO].[dbo].tbSaidasItem Pedidos_Itens
	           on Pedidos.CHAVE_FATO = Pedidos_Itens.CHAVE_FATO
              and Pedidos_Itens.NUM_SUBITEM = 0
	   inner join [SATKFRANGAO].[dbo].TBPRODUTO Produtos 
	           ON Pedidos_Itens.COD_PRODUTO = Produtos.COD_PRODUTO
	    left join [SATKFRANGAO].[dbo].tbSaidasItem Notas_Itens
	           on Notas.CHAVE_FATO = Notas_Itens.CHAVE_FATO
			  and Pedidos_Itens.Cod_produto = Notas_Itens.Cod_produto
        left join [SATKFRANGAO].[dbo].tbCadastroGeral Vendedor
               on Vendedor.Cod_cadastro = Pedidos.Cod_vend_comp
 where Pedidos.COD_DOCTO in ('PVE','PVB') 
   and Pedidos.Cod_tipo_mv in ('T503')
   and Pedidos.Data_movto >= '20210101'
GO
