ALTER View [dbo].[FF_VS_ListagemCadastroCliente] as
select   CASE Clientes.Cod_situacao 
              WHEN 'A' THEN 'ATIVO'
			  WHEN 'I' THEN 'INATIVO'
 			  ELSE 'OUTROS'
	     END                                                 AS STATUS,
         Clientes.Cod_cadastro                               AS Id_Cliente, 
		 ISNULL(Clientes.NOME_CADASTRO, 'Ñ INFORMADO')       AS Nm_Cliente, 
		 Clientes.Apelido                                    AS Apelido_cliente,
		 ISNULL(tbEndereco.email, 'Ñ INFORMADO')             AS EmailCliente,
		 Clientes.Cpf_Cgc                                    AS CPF_CNPJ,
		 Clientes.Rg_IE                                      as Rg_IE, 
		 tbEndereco.Uf										 as Estado,	
		 tbEndereco.Cidade                                   AS Nm_CidadeCliente,
		 tbEndereco.Endereco	                             as Rua,
		 tbEndereco.Numero		                             as Numero, 
		 tbEndereco.Bairro	                                 as Bairro,
		 tbEndereco.Cep	                                     as CEP,
		 tbEndereco.Fone                                     as Fone,                       	
		 tbEndereco.Latitude	                             as Latitude, 
		 tbEndereco.Longitude	                             as Longitude,
		 format(Clientes.Data_cadastro,'dd/MM/yyy','pt-br')  AS Data_cadastro,
		 format(Clientes.Data_alteracao,'dd/MM/yyy','pt-br') AS Data_alteracao,
		 isnull(Cliente.Cod_grupo_limite,0)                  AS Id_GrupoEconomicoCliente,
		 isnull(grupo.Nome, 'NAO INFORMADO')                 AS Nm_GrupoEconomicoCliente,
         Vendedor.Cod_cadastro                               AS Vendedor,
	     Vendedor.Nome_Cadastro                              AS Nome_Vendedor,
	     Supervisor_cad.Cod_Cadastro                         AS Supoervisor,
	     Supervisor_cad.Nome_cadastro                        AS Nome_Supervisor,
		 ISNULL(Cliente.Perc_desconto,0)                     AS Desc_Redes,
		 ISNULL(Cliente.Cod_lista,0)                         AS Tabela_Preco,
		 Clientes.Cod_cond_pgto                              as Cod_cond_pgto,
		 tbCondPgto.Desc_cond_pgto                           as Desc_cond_pgto,
		 Cliente.Data_ultima_compra                          AS Data_ultima_compra,
		 Cliente.Vlr_ultima_compra                           AS Vlr_ultima_compra,
		 Cliente.Vlr_maior_compra							 AS Vlr_maior_compra,
		 Cliente.Limite_credito                              AS Limite_credito,
		 tbEndereco.Observacao	

    from [SATKFRANGAO].[dbo].TBCADASTROGERAL Clientes
		 inner join [SATKFRANGAO].[dbo].TbCliente Cliente 
				 on Cliente.Cod_cadastro = Clientes.Cod_cadastro
	     left  join [SATKFRANGAO].[dbo].tbEndereco 
		  	     on Clientes.Cod_cadastro = tbEndereco.Cod_cadastro
	     left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
		         on grupo.Cod_grupo_limite = Cliente.Cod_grupo_limite
	      LEFT join [SATKFRANGAO].[dbo].TbVendedor Vendedor_Sup
		         on Cliente.Cod_cadastro = Vendedor_Sup.Cod_cadastro
          left join [SATKFRANGAO].[dbo].tbCadastroGeral Vendedor
                 on Vendedor.Cod_cadastro = Cliente.Cod_vendedor
	      LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Supervisor_cad
		         on Supervisor_cad.Cod_cadastro = Vendedor_Sup.Cod_supervisor_vda
		  left join [SATKFRANGAO].[dbo].tbCondPgto tbCondPgto
		         on tbCondPgto.Cod_cond_pgto=Clientes.Cod_cond_pgto
   where Clientes.Tipo_cadastro in ('C','Z')
	 and tbEndereco.Tipo_endereco = 'C'
GO


