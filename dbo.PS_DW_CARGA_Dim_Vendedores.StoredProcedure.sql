USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_DW_CARGA_Dim_Vendedores]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PS_DW_CARGA_Dim_Vendedores] 
AS
begin 
	merge into DW_TI.dbo.Dim_Vendedores as Dim_Vendedores
	USING
		 (select Vendedores.Cod_cadastro                              AS Id_Vendedor, 
                 ISNULL(Vendedores.NOME_CADASTRO, 'Ñ INFORMADO')      AS Nm_Vendedor, 
	             ISNULL(tbEndereco.email, 'Ñ INFORMADO')              AS Gn_EmailVendedor,
				 1 pc,											      
				 Coalesce(Supervisor.Cod_cadastro,80039)              as Id_Supervisor,
				 Coalesce(Supervisor.NOME_CADASTRO,'ALEX RODRIGUES')  as Nm_Supervisor
	        from [SATKFRANGAO].[dbo].TBCADASTROGERAL Vendedores
	              left join [SATKFRANGAO].[dbo].tbEndereco 
			             on Vendedores.Cod_cadastro = tbEndereco.Cod_cadastro
				  left join  [SATKFRANGAO].[dbo].[tbVendedor] tbVendedor
				         on tbVendedor.Cod_cadastro = Vendedores.Cod_cadastro
				  left join  [SATKFRANGAO].[dbo].TBCADASTROGERAL Supervisor
				         on Supervisor.Cod_cadastro = tbVendedor.Cod_supervisor_vda
	       where Vendedores.Tipo_cadastro = 'V'
	         and tbEndereco.Tipo_endereco = 'C' 
		)VW on (VW.Id_Vendedor = Dim_Vendedores.Id_Vendedor)  
	WHEN MATCHED THEN  
		 UPDATE SET Nm_Vendedor       = vw.Nm_Vendedor,
					Gn_EmailVendedor  = vw.Gn_EmailVendedor,
					Id_Supervisor     = vw.Id_Supervisor, 
					Nm_Supervisor     = vw.Nm_Supervisor
	WHEN NOT MATCHED THEN
			 INSERT  (Id_Vendedor,
					  Nm_Vendedor,
					  Gn_EmailVendedor,
					  Id_Supervisor, 
					  Nm_Supervisor)
			  VALUES (VW.Id_Vendedor,
					  VW.Nm_Vendedor,
					  VW.Gn_EmailVendedor,
					  VW.Id_Supervisor, 
					  VW.Nm_Supervisor );
end;
GO
