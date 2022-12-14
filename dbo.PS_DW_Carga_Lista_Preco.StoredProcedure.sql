USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_DW_Carga_Lista_Preco]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[PS_DW_Carga_Lista_Preco]
	@data date = null
as
begin
	if @Data is null 
	begin
		set @Data = cast(getdate()-1 as date);
	end; 

	delete from DW_TI.dbo.Fat_ListaPreco where Dt_Transacao = @Data;
	insert into DW_TI.dbo.Fat_ListaPreco(
			   Dt_Transacao, 
			   Id_ListaPreco,
			   Sk_Produto, 
			   Vl_PrecoMinimoListaPreco, 
			   Vl_PrecoTabelaListaPreco)
		SELECT @Data DT_TRANSACAO,
			   LP.COD_LISTA,
			   Prod.Sk_Produto,
			   PRECO_MINIMO, 
			   PRECO_V1 
		  FROM [SATKFRANGAO].DBO.TBLISTAPRECO LP
			   INNER JOIN [SATKFRANGAO].DBO.TBLISTAPRECOITEM LPI
					   ON LP.COD_LISTA = LPI.COD_LISTA
			   INNER JOIN DW_TI.dbo.Dim_Produtos Prod
					   on prod.Id_Produto = LPI.Cod_produto
		  WHERE LPI.PRECO_V1 >0.001

end
GO
