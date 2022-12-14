USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_VS_FF_Pedido_Notas]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     view [dbo].[VW_VS_FF_Pedido_Notas] as
select Pedidos.Chave_Fato                 Chave_Fato,
       Pedidos.Num_docto                  Nro_Pedido,
       ROS.Num_docto                      Nro_Romaneio,
       Notas.Num_docto                    Nro_Nota,
       Pedidos.Cod_tipo_mv                TMV_Pedido,
       ROS.Cod_tipo_mv                    TMV_Romaneio,
	   COALESCE(
		CAST(Pedidos.Serie_carga AS VARCHAR) + '-' +
		CAST(Pedidos.Num_carga  AS VARCHAR),'')  AS CARGA, 
	   COALESCE(Pedidos.Placa1,'')                   AS PLACA,
	   coalesce(Tranportador.Cod_cadastro,'') cod_Transportador,
	   coalesce(Tranportador.Nome_cadastro,'') Transportador,
	   coalesce(Tranportador.Cpf_Cgc,'') cnpj_transportador,
       Notas.Cod_tipo_mv                  TMV_Nota,
	   case when Pedidos.Status = 'C'
	        then 'C - Cancelado'
			else 'A - Ativo'
			end                           Status_Pedido,
       Pedidos.Cod_cli_for                Cliente,
	   Cliente.Cpf_Cgc                    CPF_CNPJ,
	   Cliente.Nome_Cadastro              Nome_Cliente,
       coalesce (Cast(BancoCaixa.Cod_banco_caixa as varchar)+ ' - ' + 
	             Cast(BancoCaixa.Nome_agencia    as varchar),
				 'Não Cadastrado')                  as "Banco Caixa",
	   case Cliente_COMP.Banco_caixa_fixo  
		     when 'S' then 'S - Sim'
			 when 'N' then 'N - Não'
			 else 'Não Cadastrado' 
			 end                                     as "Carterira Fixa",
       coalesce(Cast(FormaCob.Cod_forma_cob      as Varchar) + ' - ' + 
	            cast(Desc_forma_cob               as varchar) ,'Não Cadastrado') as "Forma Cobrança",
	   coalesce(Cast(CondPagamento.Cod_cond_pgto as Varchar) + ' - ' + 
	            cast(CondPagamento.Desc_cond_pgto as varchar) , 'Não Cadastrado') as "Condicao Pagamento",
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
			end as VLR_Nota_2,
       ISNULL(P.COD_PERCURSO,'99999') AS Cod_Percurso, 
	   ISNULL(P.DESCRICAO,'NAO INFORMADA') AS Rota 
  from [SATKFRANGAO].[dbo].TBSAIDAS Pedidos
       inner join [SATKFRANGAO].[dbo].tbCadastroGeral Cliente
               on Cliente.Cod_cadastro = Pedidos.Cod_cli_for
        left join [SATKFRANGAO].[dbo].TBSAIDAS ROS
               on Pedidos.Chave_fato = ROS.Chave_fato_orig_un
              and Ros.Cod_docto = 'ROS'
        LEFT JOIN [SATKFRANGAO].[dbo].TBPERCURSO P
             ON P.COD_PERCURSO = ISNULL(Pedidos.COD_PERCURSO,'0')
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
        left join SATKFRANGAO.dbo.tbCondPgto CondPagamento
		       on CondPagamento.Cod_cond_pgto = Cliente.Cod_cond_pgto
		left join [SATKFRANGAO].[dbo].[tbFormaCob] FormaCob
		       on FormaCob.Cod_forma_cob = Cliente_COMP.Cod_forma_cob
        left join [SATKFRANGAO].[dbo].[tbBancoCaixa] BancoCaixa 
		       on BancoCaixa.Cod_banco_caixa  = Cliente_COMP.Cod_banco_caixa
	   left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
		       on grupo.Cod_grupo_limite = Cliente_COMP.Cod_grupo_limite
	    LEFT join [SATKFRANGAO].[dbo].TbVendedor Vendedor_Sup
		  	   on Cliente.Cod_cadastro = Vendedor_Sup.Cod_cadastro
	    LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Supervisor_cad
		  	   on Supervisor_cad.Cod_cadastro = Vendedor_Sup.Cod_supervisor_vda
	    LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Tranportador
		  	   on pedidos.Cod_transportador1 = Tranportador.Cod_cadastro
	    
 where Pedidos.COD_DOCTO in ('PVE','PVB') 
   and Pedidos.Cod_tipo_mv not in ('T503','T507')
   and Pedidos.Data_movto >= '20210101'
union 
select Pedidos.Chave_Fato                 Chave_Fato,
       Pedidos.Num_docto                  Nro_Pedido,
       null					              Nro_Romaneio,
       Notas.Num_docto                    Nro_Nota,
       Pedidos.Cod_tipo_mv                TMV_Pedido,
       null                               TMV_Romaneio,
	   COALESCE(
		CAST(Pedidos.Serie_carga AS VARCHAR) + '-' +
		CAST(Pedidos.Num_carga  AS VARCHAR),'')  AS CARGA, 
	   COALESCE(Pedidos.Placa1,'')                   AS PLACA,
	   coalesce(Tranportador.Cod_cadastro,'') cod_Transportador,
	   coalesce(Tranportador.Nome_cadastro,'') Transportador,
	   coalesce(Tranportador.Cpf_Cgc,'') cnpj_transportador,
       Notas.Cod_tipo_mv                  TMV_Nota,
	   case when Pedidos.Status = 'C'
	        then 'C - Cancelado'
			else 'A - Ativo'
			end                           Status_Pedido,
       Pedidos.Cod_cli_for                Cliente,
	   Cliente.Cpf_Cgc                    CPF_CNPJ,
	   Cliente.Nome_Cadastro              Nome_Cliente,
       coalesce (Cast(BancoCaixa.Cod_banco_caixa as varchar)+ ' - ' + 
	             Cast(BancoCaixa.Nome_agencia    as varchar),
				 'Não Cadastrado')                  as "Banco Caixa",
	   case Cliente_COMP.Banco_caixa_fixo  
		     when 'S' then 'S - Sim'
			 when 'N' then 'N - Não'
			 else 'Não Cadastrado' 
			 end                                     as "Carterira Fixa",
       coalesce(Cast(FormaCob.Cod_forma_cob      as Varchar) + ' - ' + 
	            cast(Desc_forma_cob               as varchar) ,'Não Cadastrado') as "Forma Cobrança",
	   coalesce(Cast(CondPagamento.Cod_cond_pgto as Varchar) + ' - ' + 
	            cast(CondPagamento.Desc_cond_pgto as varchar) , 'Não Cadastrado') as "Condicao Pagamento",

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
			end as VLR_Nota_2, 
       ISNULL(P.COD_PERCURSO,'99999') AS Cod_Percurso, 
	   ISNULL(P.DESCRICAO,'NAO INFORMADA') AS Rota 
  from [SATKFRANGAO].[dbo].TBSAIDAS Pedidos
       inner join [SATKFRANGAO].[dbo].tbCadastroGeral Cliente
               on Cliente.Cod_cadastro = Pedidos.Cod_cli_for
	    LEFT join [SATKFRANGAO].[dbo].TbCliente Cliente_COMP 
		  	   on Cliente.Cod_cadastro = Cliente_COMP.Cod_cadastro
        LEFT JOIN [SATKFRANGAO].[dbo].TBPERCURSO P
             ON P.COD_PERCURSO = ISNULL(Pedidos.COD_PERCURSO,'0')
        left join SATKFRANGAO.dbo.tbCondPgto CondPagamento
		       on CondPagamento.Cod_cond_pgto = Cliente.Cod_cond_pgto
		left join [SATKFRANGAO].[dbo].[tbFormaCob] FormaCob
		       on FormaCob.Cod_forma_cob = Cliente_COMP.Cod_forma_cob
        left join [SATKFRANGAO].[dbo].[tbBancoCaixa] BancoCaixa 
		       on BancoCaixa.Cod_banco_caixa  = Cliente_COMP.Cod_banco_caixa
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
	    LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Tranportador
		  	   on pedidos.Cod_transportador1 = Tranportador.Cod_cadastro
 where Pedidos.COD_DOCTO in ('PVE','PVB') 
   and Pedidos.Cod_tipo_mv in ('T503','T507')
   and Pedidos.Data_movto >= '20210101'
union all 
select Pedidos.Chave_Fato                           Chave_Fato,
       Notas.Num_docto                              Nro_Pedido,
       null					                        Nro_Romaneio,
       Pedidos.Num_docto                            Nro_Nota,
       Notas.Cod_tipo_mv                            TMV_Pedido,
       null                                         TMV_Romaneio,
	   COALESCE(
		CAST(Pedidos.Serie_carga AS VARCHAR) + '-' +
		CAST(Pedidos.Num_carga  AS VARCHAR),'')    AS CARGA, 
	   COALESCE(Pedidos.Placa1,'')                 AS PLACA,
	   coalesce(Tranportador.Cod_cadastro,'') cod_Transportador,
	   coalesce(Tranportador.Nome_cadastro,'') Transportador,
	   coalesce(Tranportador.Cpf_Cgc,'') cnpj_transportador,
       Pedidos.Cod_tipo_mv                          TMV_Nota,
	   case when Pedidos.Status = 'C'	            
	        then 'C - Cancelado'		            
			else 'A - Ativo'			            
			end                                     Status_Pedido,
       Pedidos.Cod_cli_for                          Cliente,
	   Cliente.Cpf_Cgc                              CPF_CNPJ,
	   Cliente.Nome_Cadastro                        Nome_Cliente,
       coalesce (Cast(BancoCaixa.Cod_banco_caixa as varchar)+ ' - ' + 
	             Cast(BancoCaixa.Nome_agencia    as varchar),
				 'Não Cadastrado')                  as "Banco Caixa",
	   case Cliente_COMP.Banco_caixa_fixo  
		     when 'S' then 'S - Sim'
			 when 'N' then 'N - Não'
			 else 'Não Cadastrado' 
			 end                                     as "Carterira Fixa",
       coalesce(Cast(FormaCob.Cod_forma_cob      as Varchar) + ' - ' + 
	            cast(Desc_forma_cob               as varchar) ,'Não Cadastrado') as "Forma Cobrança",
	   coalesce(Cast(CondPagamento.Cod_cond_pgto as Varchar) + ' - ' + 
	            cast(CondPagamento.Desc_cond_pgto as varchar) , 'Não Cadastrado') as "Condicao Pagamento",
	   isnull(Cliente_COMP.Cod_grupo_limite,0)      Id_GrupoEconomicoCliente,
	   isnull(Grupo.Nome, 'NAO INFORMADO')          Nm_GrupoEconomicoCliente,
       Pedidos.Cod_vend_comp                        Vendedor,
	   Vendedor.Nome_Cadastro                       Nome_Vendedor,
	   Supervisor_cad.Cod_Cadastro                  Supoervisor,
	   Supervisor_cad.Nome_cadastro                 Nome_Supervisor,
       case when Pedidos.Tipo_frete1 = 'C'          
	        then 'C - CIF'				            
			else 'F - FOB'				            
			end                                     Tipo_Frete_Pedido, 
       Notas.Data_movto                             Data_Movimento_Pedido,
       Notas.Data_hora                              Data_Movimento_Pedido,
       Notas.Data_v1                                Data_V1_Pedido,
       Notas.Valor_liquido*-1                       Valor_liquido_Pedido,
       null					                        Data_Movimento_Romaneio,
       null					                        Data_V1_Romaneio,
       null					                        Valor_liquido_Romaneio,
	   null					                        PesoBruto_Romaneio,
	   null					                        PesoLiquido_Romaneio,
       Pedidos.Data_movto                           Data_Movimento_Nota,
       Pedidos.Data_v1                              Data_V1_Nota,
       Pedidos.Valor_liquido * -1                   Valor_liquido_Nota,
	   Pedidos.Peso_bruto	* -1                    PesoBruto_Nota,
	   Pedidos.Peso_liquido * -1                    PesoLiquido_Nota,
	   Pedidos_Itens.Cod_produto		            Codigo_Produto,
	   Produtos.Desc_produto_nf                     Produto,
	   coalesce(Notas_Itens.Valor_total,0)*-1       Valor_Pedido, 
	   coalesce(Pedidos_Itens.Valor_total,0)*-1     Valor_Nota, 
	   coalesce(Notas_Itens.Qtde_pri,0)*-1          Qtde_pri_Pedido, 
	   0 *-1                                        Qtde_pri_Romaneio, 
	   coalesce(Pedidos_Itens.Qtde_pri,0) *-1       Qtde_pri_Nota, 
	   coalesce(Notas_Itens.Qtde_aux,0) *-1         Qtde_aux_Pedido, 
	   0                                            Qtde_aux_Romaneio, 
	   coalesce(Notas_Itens.Qtde_aux,0) *-1         Qtde_aux_Nota,
	   ISNULL(Cliente_COMP.Perc_desconto,0)         "Perc Desconto",
	   Case 
	     when ISNULL(Cliente_COMP.Perc_desconto,0) >0
		 then 'Sim'
		 else 'Não'
		 End                                         Rede,
	   case when Pedidos.Cod_cli_for = 52242
	        then coalesce(Notas_Itens.Valor_total,0) *-2 
			else coalesce(Notas_Itens.Valor_total,0) *-1
			end                                        VLR_Pedido_2, 
	   case when Pedidos.Cod_cli_for = 52242
	        then coalesce(Pedidos_Itens.Valor_total,0) *-2  
			else coalesce(Pedidos_Itens.Valor_total,0)*-1
			end as                                      VLR_Nota_2,
       ISNULL(P.COD_PERCURSO,'99999') AS Cod_Percurso, 
	   ISNULL(P.DESCRICAO,'NAO INFORMADA') AS Rota 			

  from [SATKFRANGAO].[dbo].tbEntradas Pedidos
       inner join [SATKFRANGAO].[dbo].tbCadastroGeral Cliente
               on Cliente.Cod_cadastro = Pedidos.Cod_cli_for
	    LEFT join [SATKFRANGAO].[dbo].TbCliente Cliente_COMP 
		  	   on Cliente.Cod_cadastro = Cliente_COMP.Cod_cadastro
        LEFT JOIN [SATKFRANGAO].[dbo].TBPERCURSO P
             ON P.COD_PERCURSO = ISNULL(Pedidos.COD_PERCURSO,'0')
        left join SATKFRANGAO.dbo.tbCondPgto CondPagamento
		       on CondPagamento.Cod_cond_pgto = Cliente.Cod_cond_pgto
		left join [SATKFRANGAO].[dbo].[tbFormaCob] FormaCob
		       on FormaCob.Cod_forma_cob = Cliente_COMP.Cod_forma_cob
        left join [SATKFRANGAO].[dbo].[tbBancoCaixa] BancoCaixa 
		       on BancoCaixa.Cod_banco_caixa  = Cliente_COMP.Cod_banco_caixa
	   left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
		       on grupo.Cod_grupo_limite = Cliente_COMP.Cod_grupo_limite
	    LEFT join [SATKFRANGAO].[dbo].TbVendedor Vendedor_Sup
		  	   on Cliente.Cod_cadastro = Vendedor_Sup.Cod_cadastro
	    LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Supervisor_cad
		  	   on Supervisor_cad.Cod_cadastro = Vendedor_Sup.Cod_supervisor_vda
        left join [SATKFRANGAO].[dbo].tbEntradas Notas
               on Pedidos.Chave_fato = Notas.Chave_fato_orig_un
              and Notas.Cod_docto = 'NE'
	   inner join [SATKFRANGAO].[dbo].tbEntradasItem Pedidos_Itens
	           on Pedidos.CHAVE_FATO = Pedidos_Itens.CHAVE_FATO
              and Pedidos_Itens.NUM_SUBITEM = 0
	   inner join [SATKFRANGAO].[dbo].TBPRODUTO Produtos 
	           ON Pedidos_Itens.COD_PRODUTO = Produtos.COD_PRODUTO
	    left join [SATKFRANGAO].[dbo].tbEntradasItem Notas_Itens
	           on Notas.CHAVE_FATO = Notas_Itens.CHAVE_FATO
			  and Pedidos_Itens.Cod_produto = Notas_Itens.Cod_produto
        left join [SATKFRANGAO].[dbo].tbCadastroGeral Vendedor
               on Vendedor.Cod_cadastro = Pedidos.Cod_vend_comp
	    LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Tranportador
		  	   on pedidos.Cod_transportador1 = Tranportador.Cod_cadastro

 where Pedidos.Cod_tipo_mv in ('T582','T583','T584','T587','T585','T558','T580')
   and Pedidos.Data_movto >= '20210101'
union all 
select Pedidos.Chave_Fato                           Chave_Fato,
       Notas.Num_docto                              Nro_Pedido,
       null					                        Nro_Romaneio,
       Pedidos.Num_docto                            Nro_Nota,
       Notas.Cod_tipo_mv                            TMV_Pedido,
       null                                         TMV_Romaneio,
	   COALESCE(
		CAST(Pedidos.Serie_carga AS VARCHAR) + '-' +
		CAST(Pedidos. Num_carga  AS VARCHAR),'')    AS CARGA, 
	   COALESCE(Pedidos.Placa1,'')                  AS PLACA,
	   coalesce(Tranportador.Cod_cadastro,'') cod_Transportador,
	   coalesce(Tranportador.Nome_cadastro,'') Transportador,
	   coalesce(Tranportador.Cpf_Cgc,'') cnpj_transportador,
       Pedidos.Cod_tipo_mv                          TMV_Nota,
	   case when Pedidos.Status = 'C'	            
	        then 'C - Cancelado'		            
			else 'A - Ativo'			            
			end                                     Status_Pedido,
       Pedidos.Cod_cli_for                          Cliente,
	   Cliente.Cpf_Cgc                              CPF_CNPJ,
	   Cliente.Nome_Cadastro                        Nome_Cliente,
       coalesce (Cast(BancoCaixa.Cod_banco_caixa as varchar)+ ' - ' + 
	             Cast(BancoCaixa.Nome_agencia    as varchar),
				 'Não Cadastrado')                  as "Banco Caixa",
	   case Cliente_COMP.Banco_caixa_fixo  
		     when 'S' then 'S - Sim'
			 when 'N' then 'N - Não'
			 else 'Não Cadastrado' 
			 end                                     as "Carterira Fixa",
       coalesce(Cast(FormaCob.Cod_forma_cob      as Varchar) + ' - ' + 
	            cast(Desc_forma_cob               as varchar) ,'Não Cadastrado') as "Forma Cobrança",
	   coalesce(Cast(CondPagamento.Cod_cond_pgto as Varchar) + ' - ' + 
	            cast(CondPagamento.Desc_cond_pgto as varchar) , 'Não Cadastrado') as "Condicao Pagamento",
	   isnull(Cliente_COMP.Cod_grupo_limite,0)      Id_GrupoEconomicoCliente,
	   isnull(Grupo.Nome, 'NAO INFORMADO')          Nm_GrupoEconomicoCliente,
       Pedidos.Cod_vend_comp                        Vendedor,
	   Vendedor.Nome_Cadastro                       Nome_Vendedor,
	   Supervisor_cad.Cod_Cadastro                  Supoervisor,
	   Supervisor_cad.Nome_cadastro                 Nome_Supervisor,
       case when Pedidos.Tipo_frete1 = 'C'          
	        then 'C - CIF'				            
			else 'F - FOB'				            
			end                                     Tipo_Frete_Pedido, 
       Notas.Data_movto                             Data_Movimento_Pedido,
       Notas.Data_hora                              Data_Movimento_Pedido,
       Notas.Data_v1                                Data_V1_Pedido,
       Notas.Valor_liquido                          Valor_liquido_Pedido,
       null					                        Data_Movimento_Romaneio,
       null					                        Data_V1_Romaneio,
       null					                        Valor_liquido_Romaneio,
	   null					                        PesoBruto_Romaneio,
	   null					                        PesoLiquido_Romaneio,
       Pedidos.Data_movto                           Data_Movimento_Nota,
       Pedidos.Data_v1                              Data_V1_Nota,
       Pedidos.Valor_liquido                        Valor_liquido_Nota,
	   Pedidos.Peso_bruto	                        PesoBruto_Nota,
	   Pedidos.Peso_liquido                         PesoLiquido_Nota,
	   Pedidos_Itens.Cod_produto		            Codigo_Produto,
	   Produtos.Desc_produto_nf                     Produto,
	   coalesce(Notas_Itens.Valor_total,0)          Valor_Pedido, 
	   coalesce(Pedidos_Itens.Valor_total,0)        Valor_Nota, 
	   coalesce(Notas_Itens.Qtde_pri,0)             Qtde_pri_Pedido, 
	   0                                            Qtde_pri_Romaneio, 
	   coalesce(Pedidos_Itens.Qtde_pri,0)           Qtde_pri_Nota, 
	   coalesce(Notas_Itens.Qtde_aux,0)             Qtde_aux_Pedido, 
	   0                                            Qtde_aux_Romaneio, 
	   coalesce(Notas_Itens.Qtde_aux,0)             Qtde_aux_Nota,
	   ISNULL(Cliente_COMP.Perc_desconto,0)         "Perc Desconto",
	   Case 
	     when ISNULL(Cliente_COMP.Perc_desconto,0) >0
		 then 'Sim'
		 else 'Não'
		 End                                         Rede,
	   case when Pedidos.Cod_cli_for = 52242
	        then coalesce(Notas_Itens.Valor_total,0) * 2 
			else coalesce(Notas_Itens.Valor_total,0)  
			end                                        VLR_Pedido_2, 
	   case when Pedidos.Cod_cli_for = 52242
	        then coalesce(Pedidos_Itens.Valor_total,0) * 2  
			else coalesce(Pedidos_Itens.Valor_total,0)
			end as                                      VLR_Nota_2,
       ISNULL(P.COD_PERCURSO,'99999') AS Cod_Percurso, 
	   ISNULL(P.DESCRICAO,'NAO INFORMADA') AS Rota 				

  from [SATKFRANGAO].[dbo].tbSaidas Pedidos
       inner join [SATKFRANGAO].[dbo].tbCadastroGeral Cliente
               on Cliente.Cod_cadastro = Pedidos.Cod_cli_for
        LEFT JOIN [SATKFRANGAO].[dbo].TBPERCURSO P
             ON P.COD_PERCURSO = ISNULL(Pedidos.COD_PERCURSO,'0')
	    LEFT join [SATKFRANGAO].[dbo].TbCliente Cliente_COMP 
		  	   on Cliente.Cod_cadastro = Cliente_COMP.Cod_cadastro
        left join SATKFRANGAO.dbo.tbCondPgto CondPagamento
		       on CondPagamento.Cod_cond_pgto = Cliente.Cod_cond_pgto
		left join [SATKFRANGAO].[dbo].[tbFormaCob] FormaCob
		       on FormaCob.Cod_forma_cob = Cliente_COMP.Cod_forma_cob
        left join [SATKFRANGAO].[dbo].[tbBancoCaixa] BancoCaixa 
		       on BancoCaixa.Cod_banco_caixa  = Cliente_COMP.Cod_banco_caixa
	   left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
		       on grupo.Cod_grupo_limite = Cliente_COMP.Cod_grupo_limite
	    LEFT join [SATKFRANGAO].[dbo].TbVendedor Vendedor_Sup
		  	   on Cliente.Cod_cadastro = Vendedor_Sup.Cod_cadastro
	    LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Supervisor_cad
		  	   on Supervisor_cad.Cod_cadastro = Vendedor_Sup.Cod_supervisor_vda
        left join [SATKFRANGAO].[dbo].tbSaidas Notas
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
	    LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Tranportador
		  	   on pedidos.Cod_transportador1 = Tranportador.Cod_cadastro
 where Pedidos.Cod_tipo_mv in ('T540')
   and Pedidos.Data_movto >= '20210101'
GO
