USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_VS_FF_Cadastro_Produto]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_VS_FF_Cadastro_Produto] as
select tbProduto.Cod_produto                Codigo,
       tbProduto.Desc_produto_est           Nome, 
	   tbProduto.Cod_unidade_pri	        "Und. Pri",
	   tbProduto.Cod_unidade_aux            "Unid Aux", 
	   tbProduto.Tipo_produto               Tipo,
       tbProduto.Cod_divisao1	            Seção,
	   tbProduto.Cod_divisao2	            Grupo,
	   tbProduto.Cod_divisao3               SubGrupo,
	   tbProdutoRef.Ncm                     Ncm,
	   tbProdutoRef.Status                  Status,
	   tbProdutoRef.Cod_grupoctbprod        Cod_Perfil_Contabil ,
	   tbGrupoCtbProd.Desc_grupoCtbProd     Perfil_Contabil,
	   tbProdutoRef.Cod_produto_trib,
	   produtoDoItemTributario.Desc_produto_est NomeDoItemTributario
  from [SATKFRANGAO].[dbo].[tbProduto]
       inner join [SATKFRANGAO].[dbo].[tbProdutoRef] 
	           on tbProdutoRef.Cod_produto = tbProduto.Cod_produto
        LEFT join [SATKFRANGAO].[dbo].[tbGrupoCtbProd]  tbGrupoCtbProd
	           on tbProdutoRef.Cod_grupoctbprod = tbGrupoCtbProd.Cod_grupoctbprod
        left join [SATKFRANGAO].[dbo].[tbProdutoRef] perfilTributario 
		       on tbProdutoRef.Cod_produto_trib = perfilTributario.Cod_produto and tbProdutoRef.cod_ref_trib = perfiltributario.cod_ref
        left join [SATKFRANGAO].[dbo].[tbProduto] produtoDoItemTributario 
		       on perfilTributario.Cod_produto = produtoDoItemTributario.Cod_produto
  WHERE tbProduto.Cod_produto IS NOT NULL
    AND tbProduto.Tipo_produto <> 'LP'

GO
