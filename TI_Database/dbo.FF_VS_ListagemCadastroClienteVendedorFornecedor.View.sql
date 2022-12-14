USE [TI_Database]
GO
/****** Object:  View [dbo].[FF_VS_ListagemCadastroClienteVendedorFornecedor]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   View [dbo].[FF_VS_ListagemCadastroClienteVendedorFornecedor] as
select tbCadastroGeral.Cod_cadastro Cod_cliente , 
       tbCadastroGeral.Nome_cadastro Nome_cliente, 
	   tbCadastroGeral.Apelido Apelido_cliente,
	   tbEndereco.Email as EmailCliente,
	   tbCadastroGeral.Cpf_Cgc, 
	   tbCadastroGeral.Rg_IE, 
	   isnull(tbCliente.Cod_grupo_limite,0) CodGrupoEconomico,
	   isnull(grupo.Nome, 'NAO INFORMADO') GrupoEconomico,
	   tbCliente.Cod_lista as Tabela_Preco,
       Vendedor.Cod_cadastro Cod_Vendedor , 
       Vendedor.Nome_cadastro Nome_Vendedor, 
	   Vendedor.Apelido Apelido_Vendedor
  from [SATKFRANGAO].[dbo].[tbCadastroGeral]
             join [SATKFRANGAO].[dbo].[tbCliente] on tbCliente.Cod_cadastro = tbCadastroGeral.Cod_cadastro
			 join [SATKFRANGAO].[dbo].[tbCadastroGeral] Vendedor on tbCliente.Cod_vendedor = Vendedor.Cod_cadastro
			 join [SATKFRANGAO].[dbo].[tbEndereco] on (tbCadastroGeral.Cod_cadastro = tbEndereco.Cod_cadastro)
	   left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo on grupo.Cod_grupo_limite = tbCliente.Cod_grupo_limite
 where tbCadastroGeral.Tipo_cadastro in ('C' ,'F')
   and tbEndereco.Tipo_endereco = 'C'
GO
