[TI_Database]
create view vw_vs_ff_Ultimas_Vendas as
select tbCadastroGeral.Cod_cadastro         as Cod_Cliente , 
       tbCadastroGeral.Nome_cadastro        as Nome_Cliente, 
	   tbCadastroGeral.Apelido              as Apelido_Cliente,
	   tbEndereco.Email                     as Email_Cliente,
	   isnull(tbCliente.Cod_grupo_limite,0) as Cod_Grupo_Economico,
	   isnull(grupo.Nome, 'NAO INFORMADO')  as Grupo_Economico,
	   tbCliente.Cod_lista                  as Tabela_Preco,
       Vendedor.Cod_cadastro                as Cod_Vendedor , 
       Vendedor.Nome_cadastro               as Nome_Vendedor, 
	   Vendedor.Apelido                     as Apelido_Vendedor,
	   tbVendedor.Cod_supervisor_vda        as Cod_Supervisor,
	   tbSupervisor.Nome_cadastro           as Nome_Supervisor,
	   Vendas.Data_Ultima_compra	        as Data_Ultima_compra,
	   Vendas.Peso_Ultima_compra	        as Peso_Ultima_compra,
	   Vendas.Valor_Ultima_compra	        as Valor_Ultima_compra,
	   Vendas.Data_Penultima_compra         as Data_Penultima_compra,
	   Vendas.Peso_Penultima_compra         as Peso_Penultima_compra,
	   Vendas.Valor_Penultima_compra        as Valor_Penultima_compra
  from [SATKFRANGAO].[dbo].[tbCadastroGeral]
             join [SATKFRANGAO].[dbo].[tbCliente] 
			   on tbCliente.Cod_cadastro = tbCadastroGeral.Cod_cadastro
			 join [DWFRANGAO].[dbo].[Rel_Cliente_UltimasVendas] Vendas
			   on Vendas.cod_cliente = tbCadastroGeral.Cod_cadastro
			 join [SATKFRANGAO].[dbo].[tbCadastroGeral] Vendedor 
			   on tbCliente.Cod_vendedor = Vendedor.Cod_cadastro
			 join [SATKFRANGAO].[dbo].[tbEndereco] 
			   on (tbCadastroGeral.Cod_cadastro = tbEndereco.Cod_cadastro)
	   left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
	           on grupo.Cod_grupo_limite = tbCliente.Cod_grupo_limite
	   left  join [SATKFRANGAO].[dbo].[tbVendedor] tbVendedor 
	           on tbCliente.Cod_vendedor = tbVendedor.Cod_cadastro
	   left  join [SATKFRANGAO].[dbo].[tbCadastroGeral] tbSupervisor 
	           on tbSupervisor.Cod_cadastro = tbVendedor.Cod_supervisor_vda
 where tbCadastroGeral.Tipo_cadastro = 'C' 
   and tbEndereco.Tipo_endereco = 'C'
GO


