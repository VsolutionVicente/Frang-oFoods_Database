USE [TI_Database]
GO

/****** Object:  View [dbo].[VW_VS_FF_Listagem_Clientes]    Script Date: 29/09/2022 18:26:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER view [dbo].[VW_VS_FF_Listagem_Clientes] as
select   CASE Clientes.Cod_situacao 
              WHEN 'A' THEN 'ATIVO'
			  WHEN 'I' THEN 'INATIVO'
 			  ELSE 'OUTROS'
	     END                                                 AS STATUS,
         Clientes.Cod_cadastro                               AS Id_Cliente, 
		 ISNULL(Clientes.NOME_CADASTRO, '? INFORMADO')       AS Nm_Cliente, 
		 ISNULL(tbEndereco.email, '? INFORMADO')             AS Gn_EmailCliente,
		 Clientes.Cpf_Cgc                                    AS CPF_CNPJ,
		 tbEndereco.Cidade                                   AS Nm_CidadeCliente,
		 format(Clientes.Data_cadastro,'dd/MM/yyy','pt-br')  AS Data_cadastro,
		 format(Clientes.Data_alteracao,'dd/MM/yyy','pt-br') AS Data_alteracao,
		 isnull(Cliente.Cod_grupo_limite,0)                  AS Id_GrupoEconomicoCliente,
		 isnull(grupo.Nome, 'NAO INFORMADO')                 AS Nm_GrupoEconomicoCliente,
         Vendedor.Cod_cadastro                               AS Vendedor,
	     Vendedor.Nome_Cadastro                              AS Nome_Vendedor,
	     Supervisor_cad.Cod_Cadastro                         AS Supoervisor,
	     Supervisor_cad.Nome_cadastro                        AS Nome_Supervisor,
		 ISNULL(Cliente.Perc_desconto,0)                     AS "Desc Redes",
         ISNULL(P.COD_PERCURSO,'99999')                      AS Cod_Percurso, 
	     ISNULL(P.DESCRICAO,'NAO INFORMADA')                 AS Rota 
    from [SATKFRANGAO].[dbo].TBCADASTROGERAL Clientes
		 inner join [SATKFRANGAO].[dbo].TbCliente Cliente 
				 on Cliente.Cod_cadastro = Clientes.Cod_cadastro
	     left  join [SATKFRANGAO].[dbo].tbEndereco 
		  	     on Clientes.Cod_cadastro = tbEndereco.Cod_cadastro
	     left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
		         on grupo.Cod_grupo_limite = Cliente.Cod_grupo_limite
	      --LEFT join [SATKFRANGAO].[dbo].TbVendedor Vendedor_Sup
		     --    on Cliente.Cod_cadastro = Vendedor_Sup.Cod_cadastro
          left join [SATKFRANGAO].[dbo].tbCadastroGeral Vendedor
                 on Vendedor.Cod_cadastro = Cliente.Cod_vendedor
	      LEFT join [SATKFRANGAO].[dbo].TbVendedor Vendedor_Sup
		         on Vendedor.Cod_cadastro = Vendedor_Sup.Cod_cadastro
	      LEFT join [SATKFRANGAO].[dbo].tbCadastroGeral Supervisor_cad
		         on Supervisor_cad.Cod_cadastro = Vendedor_Sup.Cod_supervisor_vda
		  LEFT JOIN [SATKFRANGAO].[dbo].TBPERCURSO P
             ON P.COD_PERCURSO = ISNULL(Clientes.COD_PERCURSO,'0')
   where Clientes.Tipo_cadastro = 'C'
	 and tbEndereco.Tipo_endereco = 'C'
GO


