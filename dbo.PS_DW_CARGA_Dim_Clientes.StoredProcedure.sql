USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_DW_CARGA_Dim_Clientes]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PS_DW_CARGA_Dim_Clientes] 
AS
begin 
	merge into DW_TI.dbo.Dim_Clientes as Dim_Clientes
	USING
		 (select   Clientes.Cod_cadastro                           AS Id_Cliente, 
				   ISNULL(Clientes.NOME_CADASTRO, 'Ñ INFORMADO')   AS Nm_Cliente, 
				   ISNULL(tbEndereco.email, 'Ñ INFORMADO')         AS Gn_EmailCliente,
				   tbEndereco.Cidade                               AS Nm_CidadeCliente,
				   Isnull(Cliente.Perc_desconto,0)                 AS Pc_DescontoCliente,
				   isnull(Cliente.Cod_grupo_limite,0)              AS Id_GrupoEconomicoCliente,
				   isnull(grupo.Nome, 'NAO INFORMADO')             AS Nm_GrupoEconomicoCliente
			  from [SATKFRANGAO].[dbo].TBCADASTROGERAL Clientes
				   inner join [SATKFRANGAO].[dbo].TbCliente Cliente 
						   on Cliente.Cod_cadastro = Clientes.Cod_cadastro
				   left  join [SATKFRANGAO].[dbo].tbEndereco 
						   on Clientes.Cod_cadastro = tbEndereco.Cod_cadastro
				   left  join [SATKFRANGAO].[dbo].TBGRUPOLIMITE  Grupo 
						   on grupo.Cod_grupo_limite = Cliente.Cod_grupo_limite
			 where Clientes.Tipo_cadastro = 'C'
			   and tbEndereco.Tipo_endereco = 'C'
		)VW on (VW.Id_Cliente = Dim_Clientes.Id_Cliente)  
	WHEN MATCHED THEN  
		 UPDATE SET Nm_Cliente                 = vw.Nm_Cliente,              
					Gn_EmailCliente            = vw.Gn_EmailCliente,         
					Nm_CidadeCliente		   = vw.Nm_CidadeCliente,
					Id_GrupoEconomicoCliente   = vw.Id_GrupoEconomicoCliente,
					Nm_GrupoEconomicoCliente   = vw.Nm_GrupoEconomicoCliente,
					Pc_DescontoCliente         = vw.PC_DescontoCliente
	WHEN NOT MATCHED THEN
			 INSERT  (Id_Cliente,
			          Nm_Cliente,              
			 		  Gn_EmailCliente,         
			 		  Nm_CidadeCliente,	
					  PC_DescontoCliente,
			 		  Id_GrupoEconomicoCliente,
			 		  Nm_GrupoEconomicoCliente)
			  VALUES (vw.Id_Cliente,
			          vw.Nm_Cliente,              
			 		  vw.Gn_EmailCliente,         
			 		  vw.Nm_CidadeCliente,	
					  vw.PC_DescontoCliente,
			 		  vw.Id_GrupoEconomicoCliente,
			 		  vw.Nm_GrupoEconomicoCliente);
end;
GO
