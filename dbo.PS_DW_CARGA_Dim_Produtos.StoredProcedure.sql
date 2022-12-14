USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_DW_CARGA_Dim_Produtos]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PS_DW_CARGA_Dim_Produtos] 
AS
begin 
	merge into DW_TI.Dbo.Dim_Produtos
	USING
		 (SELECT Produto.Cod_produto,
				 Produto.Desc_produto_est,
				 Substring(Trim(Produto.Cod_produto),1,2) Tipo_produto, 
				 ProdutoRef.Peso_liquido_padrao Ps_PadraoProduto, 
				 ProdutoRef.Status Fl_StatusProduto
			FROM [SATKFRANGAO].[dbo].[TBPRODUTO] Produto
			     INNER JOIN [SATKFRANGAO].[dbo].[TBPRODUTOREF] ProdutoRef
				         on Produto.Cod_Produto = ProdutoRef.Cod_Produto
		   WHERE Tipo_produto IN( 'PA','MP')
		)VW on (VW.Cod_produto = Dim_Produtos.Id_Produto)  
	WHEN MATCHED THEN  
		 UPDATE SET Nm_Produto       = vw.Desc_produto_est,
					Fl_TipoProduto   = vw.Tipo_produto,
					Ps_PadraoProduto = vw.Ps_PadraoProduto,
					Fl_StatusProduto = vw.Fl_StatusProduto
	WHEN NOT MATCHED THEN
			 INSERT  (Id_Produto,
					  Nm_Produto,
					  Fl_TipoProduto,
					  Ps_PadraoProduto, 
					  Fl_StatusProduto)
			  VALUES (VW.Cod_produto,
					  VW.Desc_produto_est,
					  VW.Tipo_produto, 
					  vw.Ps_PadraoProduto,
					  vw.Fl_StatusProduto);
end;
GO
