
Create table Rel_Cliente_UltimasVendas (
		Cod_Cliente            int, 
		Data_Ultima_compra     datetime,
		Peso_Ultima_compra     decimal(15,3),
		Valor_Ultima_compra    decimal(15,3),
		Data_Penultima_compra  datetime,
		Peso_Penultima_compra  decimal(15,3),
		Valor_Penultima_compra decimal(15,3),
		flag_Processado        bit default (0),
		constraint PkCliente primary key (Cod_Cliente));
go

create or alter procedure ps_UltimasVendas 
as
begin 
declare @VCliente int

declare @tb_Vendas table (id      int not null,
                          data_v1 datetime,
                          Peso    decimal(15,3),
						  Valor   decimal(15,3),
						  Cod_Cliente int)

	insert into Rel_Cliente_UltimasVendas (Cod_Cliente)
	select Cod_Cadastro from [SATKFRANGAO].[dbo].[tbCadastroGeral] 
	 where Tipo_cadastro = 'C' 
	   and Cod_Cadastro not in (select Cod_Cliente from Rel_Cliente_UltimasVendas)

	update Rel_Cliente_UltimasVendas 
	   set flag_Processado        = 0    ,
	       Data_Ultima_compra	  = null ,
		   Peso_Ultima_compra	  = null ,
		   Valor_Ultima_compra	  = null ,
		   Data_Penultima_compra  =	null ,
		   Peso_Penultima_compra  =	null ,
		   Valor_Penultima_compra = null
	  where flag_Processado = 1;

	while (select count(flag_Processado) 
	         from Rel_Cliente_UltimasVendas 
			where flag_Processado = 0) >0
	begin
		select top 1 
		       @VCliente = Cod_Cliente 
		  from Rel_Cliente_UltimasVendas
		 where flag_Processado = 0;

		insert into @tb_Vendas(id, data_v1, Peso,Valor, Cod_Cliente)
			select top 2
			       ROW_NUMBER() OVER(ORDER BY S.Data_v1 DESC) AS Row, 
				   S.Data_v1,
				   S.Peso_liquido,
				   S.Valor_produtos, 
				   s.Cod_cli_for
			  from [SATKFRANGAO].[dbo].tbSaidas S
				   INNER JOIN [SATKFRANGAO].[dbo].TBTIPOMVESTOQUE TMV 
						 ON TMV.COD_TIPO_MV = S.COD_TIPO_MV
			  where TMV.CLASSE = '5'
				  AND S.STATUS_CTB = 'S'
				  AND S.STATUS <> 'C'
				  AND S.COD_DOCTO = 'NE'
				  AND S.Cod_cli_for = @VCliente
			ORDER BY 
				  S.Data_v1 DESC;
			
			update Rel_Cliente_UltimasVendas 
			   set Data_Ultima_compra      = vendas.data_v1,
				   Peso_Ultima_compra      = vendas.Peso,
				   Valor_Ultima_compra     = vendas.Valor
			  from Rel_Cliente_UltimasVendas
 			       join @tb_Vendas vendas on vendas.Cod_Cliente = Rel_Cliente_UltimasVendas.Cod_Cliente
              where Vendas.id = 1				   

			update Rel_Cliente_UltimasVendas 
			   set Data_Penultima_compra      = vendas.data_v1,
				   Peso_Penultima_compra      = vendas.Peso,
				   Valor_Penultima_compra     = vendas.Valor
			  from Rel_Cliente_UltimasVendas
 			       join @tb_Vendas vendas on vendas.Cod_Cliente = Rel_Cliente_UltimasVendas.Cod_Cliente
              where Vendas.id = 2;				   

			  delete from @tb_Vendas;	

		update Rel_Cliente_UltimasVendas set flag_Processado = 1  where Cod_Cliente = @VCliente;
	end
end 


exec ps_UltimasVendas