USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_DW_CARGA_Fat_Producao]    Script Date: 10/06/2021 09:29:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PS_DW_CARGA_Fat_Producao]
	@Data DATE = null
AS
DECLARE @MENS_ERRO  VARCHAR(4000)
begin 
	BEGIN TRY
		SET NOCOUNT ON
		set @MENS_ERRO = 'Definindo a data de Processamento';
		if @Data is null 
		begin
			set @Data = cast(getdate()-1 as date);
		end; 

		set @MENS_ERRO = 'Apagamos os Dados na tabela Fato Fat_Producao';
		/*Apagamos dados da tabela de Produção*/
		DELETE DW_TI.dbo.Fat_Producao WHERE Dt_Transacao = @DATA;
	
		/*Tabela Fat_Producao*/
		set @MENS_ERRO = '/*Tabela Fat_Producao*/';
    Insert into DW_TI.dbo.Fat_Producao(
	                         Sk_Produto,
							 Dt_Transacao,
							 Dt_Producao,
							 Qn_CaixasProducao,
							 Ps_PadraoProducao, 
							 Fl_GrupoRendProducao
	                         )
	 				 select DIM_PRODUTOS.Sk_Produto, 
							VW.DATA_ESTOQUE Dt_Transacao,
							VW.DATA_ESTOQUE Dt_Producao,
							VW.QTDE_AUX Qn_CaixasProducao,
							VW.QTDE_PRI Ps_PadraoProducao,
							vw.COD_GRUPO_REND 
					   FROM [SATKFRANGAO].[dbo].[VWATAK4NET_RENDIMENTODADESOSSA] VW
							inner join DW_TI.dbo.Dim_Produtos 
									ON Dim_Produtos.id_Produto = VW.COD_PRODUTO
					  WHERE DATA_ESTOQUE = @Data;

	END TRY 
	BEGIN CATCH
		/* GERAMOS UMA EXCEÇÃO BASEADA NO ERRO ORIGINAL */
		set @MENS_ERRO = 'PS_DW_CARGA_Fat_Producao '  + @MENS_ERRO + ' - ';
		RAISERROR(@MENS_ERRO , 16, 1)		
	END CATCH
end
GO
