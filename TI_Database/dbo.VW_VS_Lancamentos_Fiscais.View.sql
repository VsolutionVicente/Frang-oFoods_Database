USE [TI_Database]
GO
/****** Object:  View [dbo].[VW_VS_Lancamentos_Fiscais]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[VW_VS_Lancamentos_Fiscais] as
                    SELECT 
						'Documento' as Documento,
                        Lote.Tipo_ES AS TIPO_ES,
                        Liv.Chave_fato AS ChaveFato,
                        Liv.Cod_lote as CodigoLoteDoLivro,
                        Liv.Cod_cli_for,
                        Liv.Data_emissao DataDeEmissaoDoLivro,
                        Liv.Data_ent_sai DataEntradaSaidaDoLivro,
                        Liv.Cod_docto as CodigoDoDocumentoDoLivro,
                        Liv.Serie,
                        Liv.Numero,
                        ISNULL(Liv.Valor_contabil,0) as Valor_contabil,
                        Liv.Nome_emitente as NomeParticipante,
                        Liv.CpfCgc_emitente,
                        Liv.Rg_IE,
                        Liv.Data_reg,
                        Liv.Cod_docFiscal,
                        Liv.Tipo_emissao_nf,
                        Liv.Chave_acesso_nfe,
                        Liv.Placa_veiculo,
                        ISNULL(Liv.Qtde_volumes,0) as Qtde_volumes,
                        ISNULL(Liv.Peso_bruto,0)  as Peso_bruto,
                        ISNULL(Liv.Peso_liquido,0) as Peso_liquido,
                        Liv.Uf_remetente,
                        Liv.Desc_mensagem1,
                        Liv.Desc_mensagem2,
                        Liv.Desc_mensagem3,
                        Liv.cod_tipo_mv,
                        Liv.NatOp,
                        ISNULL(prodref.Ncm,'') NCM,
                        ISNULL(prodref.Cod_produto_trib,'') COD_PRODUTO_TRIB,
                        ISNULL(prodref.Cod_grupoctbprod,'') COD_GRUPOCTBPROD,
                        RTRIM(LTRIM(item.cod_produto))+'-'+RTRIM(LTRIM(item.Cod_ref)) as CodigoProduto,
                        prod.Desc_produto_est as DescricaoProduto,
                        item.Num_item NumeroItem,
                        item.Cod_cfop as Cfop,
                        item.Cod_St as CodigoSituacaoTributaria ,
                        item.Valor_item ,
                        item.Observacao as ObservacaoDoItem,
                        ISNULL(item.Qtde_item,0) as Qtde_item,
                        ISNULL(item.Valor_frete,0) as ValorFreteDoItem,
                        ISNULL(item.Valor_encargos,0) as ValorDosEncargosItem,
                        ISNULL(item.Valor_desconto,0) as ValorDescontoItem,
						pl.Desc_conta as Nome_Cta0500,
                        item.Cod_Sit_ipi as CodigoStIPIIten,
                        item.Cod_Sit_cofins as CodigoStCOFINSIten,
                        item.Cod_Sit_pis as CodigoStPISIten,
                        item.Num_docto_orig NumeroDocumentoOrigem,
						item.Num_item_orig NumeroDoItemDeOrigem,
						ISNULL(item.Valor_unitario_item,0) as ValorUnitarioItem,
                        item.Cod_tab_operacoes as CodigoTabelaDeOperacao,
                        item.Cod_reduz_conta_aux as CodigoReduzidoContaAuxiliarItem,
                        item.Cod_ccusto as CodigoCentroDeCustoItem,
                        ITrb_ICMS.Cod_imposto AS ITrb_ICMS_Cod_imposto,
                        ITrb_ICMS.Situacao_trib AS ITrb_ICMS_Situacao_trib,
                        ITrb_ICMS.Cod_periodo AS ITrb_ICMS_Cod_periodo,
						ISNULL(ITrb_ICMS.Valor_base,0) AS ITrb_ICMS_Valor_base,
                        ISNULL(ITrb_ICMS.Perc_reducao,0) AS ITrb_ICMS_Perc_reducao,
						ISNULL(ITrb_ICMS.Perc_imposto,0) AS ITrb_ICMS_Perc_imposto,
						ISNULL(ITrb_ICMS.Valor_imposto,0) AS ITrb_ICMS_Valor_imposto,
						ISNULL(ITrb_ICMS.Valor_isentas,0) AS ITrb_ICMS_Valor_isentas,
						ISNULL(ITrb_ICMS.Valor_outras,0) AS ITrb_ICMS_Valor_outras

						--'tbFilial' as tbFilial,
      --                  filial.Cod_filial AS CODIGO_FILIAL,
      --                  filial.Cod_matriz AS CODIGO_MATRIZ,
      --                  filial.Cpf_Cgc AS CNPJ,
      --                  filial.Inscricao AS INSCRICAO,
      --                  filial.Nome_filial AS NomeFilial,
      --                  filial.Apelido_filial AS APELIDO_FILIAL,
                        --tbLivroRegES
                        --/*(liv.Cod_filial+'-'+liv.Cod_docto +'-'+ liv.Serie +'-'+ cast(liv.Numero as varchar)) as DocumentoCompleto,*/
                        --Liv.Cod_equiptoEcf,
                        --Liv.Cod_filial AS CodigoFilial,
                        --Liv.Uf as UF,
                        --Liv.Cod_cli_for as IDParticipante,
                        --Liv.Modelo as ModeloFiscal,
                        --Liv.Status,
                        --Liv.Tipo_frete,
                        --Liv.Data_reg DataRegistro,
                        --Liv.Status_ctb,
                        --Liv.Status_fin,
                        --Liv.Origem_lancto,
                        --Liv.Ind_Pgto,
                        --Liv.Endereco,
                        --Liv.Bairro,
                        --Liv.Cidade,
                        --Liv.Fone,
                        --Liv.Cep,
                        --Liv.Numero_Endereco,
                        --Liv.Cod_municipio,
                        --Liv.Observacao,
                        --Liv.Suframa,
                        --Liv.Cod_pais,
                        --Liv.Cod_propriedade,
                        --Liv.Status_nfe,
                        --Liv.Cod_localidade_orig,
                        --Liv.Cod_localidade_dest,
                        --Liv.Uf_veiculo,
                        --Liv.Cod_redespacho,
                        --Liv.Tipo_frete_redespacho,
                        --ISNULL(Liv.Valor_Sec_Cat,0) as Valor_Sec_Cat,
                        --ISNULL(Liv.Valor_despacho,0) as Valor_despacho,
                        --ISNULL(Liv.Valor_pedagio,0) as Valor_pedagio,
                        --ISNULL(Liv.Valor_outros,0) as Valor_outros,
                        --Liv.Num_despacho,
                        --Liv.Via_transp,
                        --Liv.Cod_municipio_orig,
                        --Liv.Nome_remetente,
                        --Liv.CpfCgc_remetente,
                        --Liv.RGIE_remetente,
                        --Liv.Nome_redespacho,
                        --Liv.CpfCgc_redespacho,
                        --Liv.RGIE_redespacho,
                        --Liv.Uf_redespacho,
                        --Liv.Cod_municipio_redespacho,
                        --Liv.Cod_cons,
                        --Liv.Chave_fato_orig_mercadoria,
                        --Liv.tpEmis,
                        --Liv.tpImp,
                        --Liv.nProt,
                        --Liv.Chave_fato_exportacao,
                        --Liv.Tipo_documento_complementar,
                        --Liv.Cod_mensagem1,
                        --Liv.Cod_mensagem2,
                        --Liv.Cod_mensagem3,
                        --Liv.Cod_mensagem4,
                        --Liv.Desc_mensagem4,
                        --Liv.Ind_Nat_frt,
                        --Liv.id,
                        --Liv.Chave_fato_orig,
                        --Liv.ID_Livro_Sefaz,
                        --Liv.Data_posto_fiscal,
                        --Liv.Documento_referenciado,
                        --Liv.ID_FechamentoC,
                        --Liv.ID_FechamentoI,
                        --Liv.Chave_acesso_NFSe,
                        --Liv.indObra,
                        --ISNULL(Liv.Valor_servicos,0) as Valor_servicos,
                        --Liv.Cod_municipio_dest,
                        --Liv.dhViagem,
                        --Liv.cod_sit,
                        --Liv.ObsCont,
                        ----tbLivroRegEsItem
                        --'Documento_item' as Documento_item,
                        --CASE
	                       -- WHEN prodpcp.Tipo_item_sped IS NOT NULL and prodpcp.Tipo_item_sped <> '' THEN prodpcp.Tipo_item_sped
	                       -- WHEN PROD.TIPO_ITEM IS NOT NULL THEN PROD.TIPO_ITEM
	                       -- WHEN PROD.TIPO_PRODUTO IS NULL THEN '99'
	                       -- WHEN PROD.TIPO_PRODUTO = 'PC' THEN '00'
	                       -- WHEN PROD.TIPO_PRODUTO = 'MP' THEN '01'
	                       -- WHEN PROD.TIPO_PRODUTO = 'EB' THEN '02'
	                       -- WHEN PROD.TIPO_PRODUTO = 'PP' THEN '03'
	                       -- WHEN PROD.TIPO_PRODUTO = 'PA' THEN '04'
	                       -- WHEN PROD.TIPO_PRODUTO = 'SG' THEN '05'
	                       -- WHEN PROD.TIPO_PRODUTO = 'PI' THEN '06'
	                       -- WHEN PROD.TIPO_PRODUTO = 'MC' THEN '07'
	                       -- WHEN PROD.TIPO_PRODUTO = 'AI' THEN '08'
	                       -- WHEN PROD.TIPO_PRODUTO = 'SE' THEN '09'
	                       -- WHEN PROD.TIPO_PRODUTO = 'OI' THEN '10'
	                       -- ELSE '99' END AS TIPOITEM0200,
                        --ISNULL(prodref.Cod_ref_trib,'') COD_REF_TRIB,
                        --,item.Chave_fato as ChaveFatoItem
                        --,item.Num_subitem NumeroSubItem
                        --,item.Cod_produto as CodigoProduto
                        --,item.Cod_ref as CodigoRef
                        --,item.Valor_item as ValorLiquido
                        --,ISNULL(item.Qtde_item,0) as Quantidade
                        --,ISNULL(item.Valor_seguro,0) as ValorSeguroItem
                        --,item.Cod_Cf
      --                  ,item.Status_item as StatusItem
      --                  ,ISNULL(item.Valor_item_contabil,0) as ValorContabil
      --                  ,item.Origem_lancto as OrigemLancamentoItem
      --                  ,item.Cod_filial as CodigoDaFilialItem
      --                  ,item.Num_item_orig NumeroDoItemDeOrigem
      --                  
      --                  ,ISNULL(item.Valor_unitario_item,0) as Valor_unitario_item
      --                  ,item.Cod_unid as CodigoUnidade
      --                  ,item.Cod_unid 
      --                  ,item.Cod_cta as CodigoContaItem

      --                  ,(pl.Data_alteracao) as Dt_Alt0500
						--,cast(coalesce(pl.Cod_nat,'') as varchar) as Cod_Nat_Cc0500
						--,cast(coalesce(Tipo_conta,'') as varchar) as Ind_Cta0500
						--,cast(Coalesce(Nivel_conta,'') as varchar) as Nivel0500
						--,cast(Coalesce(pl.Cod_reduz_conta,'') as varchar) as Cod_Cta0500
                        --,cast(Coalesce(pl.cod_conta_ref,'') as varchar) as Cod_conta_referencial_0500
                        --,cast(Coalesce(pl.cod_conta,'') as varchar) as Cod_conta_contabil_0500
                        --,item.Cod_Enq_ipi as CodigoEnquadramentoIPIItem
                        --,item.Chave_fato_orig_mercadoria as ChaveFatoOrigemDaMercadoriaItem
                        --,item.Cod_tipo_cred 
                        --,item.Natureza_bc_cred
                        --,item.Cod_cont_dif
                        --,item.id as IdDoItem
                        --,item.id_livroreges as IdDoLivroItem
                        --,item.Documento_referenciado as DocumentoReferenciadoItem
                        --,item.Num_item_referenciado as NumeroItemReferenciado
                        --,item.Num_subitem_referenciado as NumeroSubItemReferenciado
                        --,item.Cod_ccusto_aux as CodigoCentroDeCustoAuxiliarItem
                        --,item.Origem_produto as OrigemDoProdutoItem
                        --,item.ID_ClassificacaoServicos as IdDaClassificacaoDoServicoItem
                        --,ISNULL(item.Vl_mat_terc,0) as Vl_mat_terc
                        --,ISNULL(item.Vl_sub,0) as Vl_sub
                        --,item.Cod_inf_item
                        --,item.Cod_aj_bc
                        --,item.ID_NaturezaRendimentos as IdDaNaturezaDeRendimentosItem,                        
                        ----tbLivroRegESItemTrb
                        --'Documento_item_Trib' as Documento_item_Trib,
                        ----ITrb_ICMS.*,
                        --ITrb_ICMS.Chave_fato AS ITrb_ICMS_Chave_fato,
                        --ITrb_ICMS.Num_item AS ITrb_ICMS_Num_item,
                        --ITrb_ICMS.Num_subitem AS ITrb_ICMS_Num_subitem,
                        --ITrb_ICMS.Cod_filial AS ITrb_ICMS_Cod_filial,
                        --ISNULL(ITrb_ICMS.Perc_reducao,0) AS ITrb_ICMS_Perc_reducao,
                        --ITrb_ICMS.Atlz_saldo AS ITrb_ICMS_Atlz_saldo,
	  --                  ITrb_ICMS.Origem_lancto AS ITrb_ICMS_Origem_lancto,
      --                  ITrb_ICMS.Cod_mensagem AS ITrb_ICMS_Cod_mensagem,
      --                  ITrb_ICMS.Cod_aj AS ITrb_ICMS_Cod_aj,
      --                  ISNULL(ITrb_ICMS.Valor_imposto_calc,0) AS ITrb_ICMS_Valor_imposto_calc,
      --                  ITrb_ICMS.id AS ITrb_ICMS_id,
      --                  ITrb_ICMS.id_livroregesitem AS ITrb_ICMS_id_livroregesitem,
      --                  ISNULL(ITrb_ICMS.vICMSUFDest,0) AS ITrb_ICMS_vICMSUFDest,
      --                  ISNULL(ITrb_ICMS.pICMSUFDest,0) AS ITrb_ICMS_pICMSUFDest,
      --                  ISNULL(ITrb_ICMS.vICMSUFOrig,0) AS ITrb_ICMS_vICMSUFOrig,
      --                  ITrb_ICMS.cEnq AS ITrb_ICMS_cEnq,
      --                  ISNULL(ITrb_ICMS.Perc_imposto_diferido,0) AS ITrb_ICMS_Perc_imposto_diferido,
      --                  ISNULL(ITrb_ICMS.Valor_imposto_diferido,0) AS ITrb_ICMS_Valor_imposto_diferido,
      --                  ISNULL(ITrb_ICMS.Valor_imposto_devido,0) AS ITrb_ICMS_Valor_imposto_devido,
      --                  ISNULL(ITrb_ICMS.Perc_imposto_FCP,0) AS ITrb_ICMS_Perc_imposto_FCP,
      --                  ISNULL(ITrb_ICMS.Valor_imposto_FCP,0) AS ITrb_ICMS_Valor_imposto_FCP,
      --                  ISNULL(ITrb_ICMS.vICMSDeson,0) AS ITrb_ICMS_vICMSDeson,
      --                  ITrb_ICMS.motDesICMS AS ITrb_ICMS_motDesICMS,
      --                  ISNULL(ITrb_ICMS.Perc_reducao_interno,0) AS ITrb_ICMS_Perc_reducao_interno,
      --                  ISNULL(ITrb_ICMS.vBCUFDest,0) AS ITrb_ICMS_vBCUFDest,
      --                  ITrb_ICMS.Cod_reduz_conta_trb AS ITrb_ICMS_Cod_reduz_conta_trb,
      --                  ITrb_ICMS.Cod_reduz_conta_trbaux AS ITrb_ICMS_Cod_reduz_conta_trbaux,
      --                  ITrb_ICMS.Cod_ccusto_trb AS ITrb_ICMS_Cod_ccusto_trb,
      --                  ITrb_ICMS.Cod_ccusto_trbaux AS ITrb_ICMS_Cod_ccusto_trbaux,
      --                  ITrb_ICMS.Ind_Adicional_Servicos AS ITrb_ICMS_Ind_Adicional_Servicos,
      --                  ITrb_ICMS.Imposto_retido AS ITrb_ICMS_Imposto_retido,
      --                  ITrb_ICMS.Origem_valor_cod_aj_aux AS ITrb_ICMS_Origem_valor_cod_aj_aux,
      --                  ITrb_ICMS.cod_aj_aux AS ITrb_ICMS_cod_aj_aux,
      --                  ISNULL(ITrb_ICMS.Valor_pauta,0) AS ITrb_ICMS_Valor_pauta,
      --                  ISNULL(ITrb_ICMS.Perc_margem,0) AS ITrb_ICMS_Perc_margem,
      --                  ITrb_ICMS.cBenef AS ITrb_ICMS_cBenef,
      --                  ISNULL(ITrb_ICMS.vBCFCPUFDest,0) AS ITrb_ICMS_vBCFCPUFDest,
      --                  ISNULL(ITrb_ICMS.Perc_imposto_trib_media,0) AS ITrb_ICMS_Perc_imposto_trib_media,
      --                  ITrb_ICMS.Identificador AS ITrb_ICMS_Identificador,
      --                  ISNULL(ITrb_ICMS.vICMSDeson_Desc,0) AS ITrb_ICMS_vICMSDeson_Desc,
      --                  ITrb_ICMS.Formula_interna_uf AS ITrb_ICMS_Formula_interna_uf,
      --                  ISNULL(ITrb_ICMS.perc_reducao_deson,0) AS ITrb_ICMS_perc_reducao_deson,
      --                  --ITrb_ICMST.*,
      --                  ITrb_ICMST.Chave_fato AS ITrb_ICMST_Chave_fato,
      --                  ITrb_ICMST.Num_item AS ITrb_ICMST_Num_item,
      --                  ITrb_ICMST.Num_subitem AS ITrb_ICMST_Num_subitem,
      --                  ITrb_ICMST.Cod_imposto AS ITrb_ICMST_Cod_imposto,
      --                  ITrb_ICMST.Cod_filial AS ITrb_ICMST_Cod_filial,
      --                  ITrb_ICMST.Cod_periodo AS ITrb_ICMST_Cod_periodo,
      --                  ISNULL(ITrb_ICMST.Valor_base,0) AS ITrb_ICMST_Valor_base,
      --                  ISNULL(ITrb_ICMST.Perc_reducao,0) AS ITrb_ICMST_Perc_reducao,
      --                  ISNULL(ITrb_ICMST.Perc_imposto,0) AS ITrb_ICMST_Perc_imposto,
      --                  ISNULL(ITrb_ICMST.Valor_imposto,0) AS ITrb_ICMST_Valor_imposto,
      --                  ISNULL(ITrb_ICMST.Valor_isentas,0) AS ITrb_ICMST_Valor_isentas,
      --                  ISNULL(ITrb_ICMST.Valor_outras,0) AS ITrb_ICMST_Valor_outras,
      --                  ITrb_ICMST.Atlz_saldo AS ITrb_ICMST_Atlz_saldo,
      --                  ITrb_ICMST.Situacao_trib AS ITrb_ICMST_Situacao_trib,
      --                  ITrb_ICMST.Origem_lancto AS ITrb_ICMST_Origem_lancto,
      --                  ITrb_ICMST.Cod_mensagem AS ITrb_ICMST_Cod_mensagem,
      --                  ITrb_ICMST.Cod_aj AS ITrb_ICMST_Cod_aj,
      --                  ISNULL(ITrb_ICMST.Valor_imposto_calc,0) AS ITrb_ICMST_Valor_imposto_calc,
      --                  ITrb_ICMST.id AS ITrb_ICMST_id,
      --                  ITrb_ICMST.id_livroregesitem AS ITrb_ICMST_id_livroregesitem,
      --                  ISNULL(ITrb_ICMST.vICMSUFDest,0) AS ITrb_ICMST_vICMSUFDest,
      --                  ISNULL(ITrb_ICMST.pICMSUFDest,0) AS ITrb_ICMST_pICMSUFDest,
      --                  ISNULL(ITrb_ICMST.vICMSUFOrig,0) AS ITrb_ICMST_vICMSUFOrig,
      --                  ITrb_ICMST.cEnq AS ITrb_ICMST_cEnq,
      --                  ISNULL(ITrb_ICMST.Perc_imposto_diferido,0) AS ITrb_ICMST_Perc_imposto_diferido,
      --                  ISNULL(ITrb_ICMST.Valor_imposto_diferido,0) AS ITrb_ICMST_Valor_imposto_diferido,
      --                  ISNULL(ITrb_ICMST.Valor_imposto_devido,0) AS ITrb_ICMST_Valor_imposto_devido,
      --                  ISNULL(ITrb_ICMST.Perc_imposto_FCP,0) AS ITrb_ICMST_Perc_imposto_FCP,
      --                  ISNULL(ITrb_ICMST.Valor_imposto_FCP,0) AS ITrb_ICMST_Valor_imposto_FCP,
      --                  ISNULL(ITrb_ICMST.vICMSDeson,0) AS ITrb_ICMST_vICMSDeson,
      --                  ITrb_ICMST.motDesICMS AS ITrb_ICMST_motDesICMS,
      --                  ISNULL(ITrb_ICMST.Perc_reducao_interno,0) AS ITrb_ICMST_Perc_reducao_interno,
      --                  ISNULL(ITrb_ICMST.vBCUFDest,0) AS ITrb_ICMST_vBCUFDest,
      --                  ITrb_ICMST.Cod_reduz_conta_trb AS ITrb_ICMST_Cod_reduz_conta_trb,
      --                  ITrb_ICMST.Cod_reduz_conta_trbaux AS ITrb_ICMST_Cod_reduz_conta_trbaux,
      --                  ITrb_ICMST.Cod_ccusto_trb AS ITrb_ICMST_Cod_ccusto_trb,
      --                  ITrb_ICMST.Cod_ccusto_trbaux AS ITrb_ICMST_Cod_ccusto_trbaux,
      --                  ITrb_ICMST.Ind_Adicional_Servicos AS ITrb_ICMST_Ind_Adicional_Servicos,
      --                  ITrb_ICMST.Imposto_retido AS ITrb_ICMST_Imposto_retido,
      --                  ITrb_ICMST.Origem_valor_cod_aj_aux AS ITrb_ICMST_Origem_valor_cod_aj_aux,
      --                  ITrb_ICMST.cod_aj_aux AS ITrb_ICMST_cod_aj_aux,
      --                  ISNULL(ITrb_ICMST.Valor_pauta,0)AS ITrb_ICMST_Valor_pauta,
      --                  ISNULL(ITrb_ICMST.Perc_margem,0) AS ITrb_ICMST_Perc_margem,
      --                  ITrb_ICMST.cBenef AS ITrb_ICMST_cBenef,
      --                  ISNULL(ITrb_ICMST.vBCFCPUFDest,0) AS ITrb_ICMST_vBCFCPUFDest,
      --                  ISNULL(ITrb_ICMST.Perc_imposto_trib_media,0) AS ITrb_ICMST_Perc_imposto_trib_media,
      --                  ITrb_ICMST.Identificador AS ITrb_ICMST_Identificador,
      --                  ISNULL(ITrb_ICMST.vICMSDeson_Desc,0) AS ITrb_ICMST_vICMSDeson_Desc,
      --                  ITrb_ICMST.Formula_interna_uf AS ITrb_ICMST_Formula_interna_uf,
      --                  ISNULL(ITrb_ICMST.perc_reducao_deson,0) AS ITrb_ICMST_perc_reducao_deson,
      --                  --ITrb_PIS.*,
      --                  ITrb_PIS.Chave_fato AS ITrb_PIS_Chave_fato,
      --                  ITrb_PIS.Num_item AS ITrb_PIS_Num_item,
      --                  ITrb_PIS.Num_subitem AS ITrb_PIS_Num_subitem,
      --                  ITrb_PIS.Cod_imposto AS ITrb_PIS_Cod_imposto,
      --                  ITrb_PIS.Cod_filial AS ITrb_PIS_Cod_filial,
      --                  ITrb_PIS.Cod_periodo AS ITrb_PIS_Cod_periodo,
      --                  ISNULL(ITrb_PIS.Valor_base,0) AS ITrb_PIS_Valor_base,
      --                  ISNULL(ITrb_PIS.Perc_reducao,0) AS ITrb_PIS_Perc_reducao,
      --                  ISNULL(ITrb_PIS.Perc_imposto,0) AS ITrb_PIS_Perc_imposto,
      --                  ISNULL(ITrb_PIS.Valor_imposto,0) AS ITrb_PIS_Valor_imposto,
      --                  ISNULL(ITrb_PIS.Valor_isentas,0) AS ITrb_PIS_Valor_isentas,
      --                  ISNULL(ITrb_PIS.Valor_outras,0) AS ITrb_PIS_Valor_outras,
      --                  ITrb_PIS.Atlz_saldo AS ITrb_PIS_Atlz_saldo,
      --                  ITrb_PIS.Situacao_trib AS ITrb_PIS_Situacao_trib,
      --                  ITrb_PIS.Origem_lancto AS ITrb_PIS_Origem_lancto,
      --                  ITrb_PIS.Cod_mensagem AS ITrb_PIS_Cod_mensagem,
      --                  ITrb_PIS.Cod_aj AS ITrb_PIS_Cod_aj,
      --                  ISNULL(ITrb_PIS.Valor_imposto_calc,0) AS ITrb_PIS_Valor_imposto_calc,
      --                  ITrb_PIS.id AS ITrb_PIS_id,
      --                  ITrb_PIS.id_livroregesitem AS ITrb_PIS_id_livroregesitem,
      --                  ISNULL(ITrb_PIS.vICMSUFDest,0) AS ITrb_PIS_vICMSUFDest,
      --                  ISNULL(ITrb_PIS.pICMSUFDest,0) AS ITrb_PIS_pICMSUFDest,
      --                  ISNULL(ITrb_PIS.vICMSUFOrig,0) AS ITrb_PIS_vICMSUFOrig,
      --                  ITrb_PIS.cEnq AS ITrb_PIS_cEnq,
      --                  ISNULL(ITrb_PIS.Perc_imposto_diferido,0) AS ITrb_PIS_Perc_imposto_diferido,
      --                  ISNULL(ITrb_PIS.Valor_imposto_diferido,0) AS ITrb_PIS_Valor_imposto_diferido,
      --                  ISNULL(ITrb_PIS.Valor_imposto_devido,0) AS ITrb_PIS_Valor_imposto_devido,
      --                  ISNULL(ITrb_PIS.Perc_imposto_FCP,0) AS ITrb_PIS_Perc_imposto_FCP,
      --                  ISNULL(ITrb_PIS.Valor_imposto_FCP,0) AS ITrb_PIS_Valor_imposto_FCP,
      --                  ISNULL(ITrb_PIS.vICMSDeson,0) AS ITrb_PIS_vICMSDeson,
      --                  ITrb_PIS.motDesICMS AS ITrb_PIS_motDesICMS,
      --                  ISNULL(ITrb_PIS.Perc_reducao_interno,0) AS ITrb_PIS_Perc_reducao_interno,
      --                  ISNULL(ITrb_PIS.vBCUFDest,0) AS ITrb_PIS_vBCUFDest,
      --                  ITrb_PIS.Cod_reduz_conta_trb AS ITrb_PIS_Cod_reduz_conta_trb,
      --                  ITrb_PIS.Cod_reduz_conta_trbaux AS ITrb_PIS_Cod_reduz_conta_trbaux,
      --                  ITrb_PIS.Cod_ccusto_trb AS ITrb_PIS_Cod_ccusto_trb,
      --                  ITrb_PIS.Cod_ccusto_trbaux AS ITrb_PIS_Cod_ccusto_trbaux,
      --                  ITrb_PIS.Ind_Adicional_Servicos AS ITrb_PIS_Ind_Adicional_Servicos,
      --                  ITrb_PIS.Imposto_retido AS ITrb_PIS_Imposto_retido,
      --                  ITrb_PIS.Origem_valor_cod_aj_aux AS ITrb_PIS_Origem_valor_cod_aj_aux,
      --                  ITrb_PIS.cod_aj_aux AS ITrb_PIS_cod_aj_aux,
      --                  ISNULL(ITrb_PIS.Valor_pauta,0) AS ITrb_PIS_Valor_pauta,
      --                  ISNULL(ITrb_PIS.Perc_margem,0) AS ITrb_PIS_Perc_margem,
      --                  ITrb_PIS.cBenef AS ITrb_PIS_cBenef,
      --                  ISNULL(ITrb_PIS.vBCFCPUFDest,0) AS ITrb_PIS_vBCFCPUFDest,
      --                  ISNULL(ITrb_PIS.Perc_imposto_trib_media,0) AS ITrb_PIS_Perc_imposto_trib_media,
      --                  ITrb_PIS.Identificador AS ITrb_PIS_Identificador,
      --                  ISNULL(ITrb_PIS.vICMSDeson_Desc,0) AS ITrb_PIS_vICMSDeson_Desc,
      --                  ITrb_PIS.Formula_interna_uf AS ITrb_PIS_Formula_interna_uf,
      --                  ISNULL(ITrb_PIS.perc_reducao_deson,0) AS ITrb_PIS_perc_reducao_deson,
      --                  --ITrb_COFINS.*,
      --                  ITrb_COFINS.Chave_fato AS ITrb_COFINS_Chave_fato,
      --                  ITrb_COFINS.Num_item AS ITrb_COFINS_Num_item,
      --                  ITrb_COFINS.Num_subitem AS ITrb_COFINS_Num_subitem,
      --                  ITrb_COFINS.Cod_imposto AS ITrb_COFINS_Cod_imposto,
      --                  ITrb_COFINS.Cod_filial AS ITrb_COFINS_Cod_filial,
      --                  ITrb_COFINS.Cod_periodo AS ITrb_COFINS_Cod_periodo,
      --                  ISNULL(ITrb_COFINS.Valor_base,0) AS ITrb_COFINS_Valor_base,
      --                  ISNULL(ITrb_COFINS.Perc_reducao,0) AS ITrb_COFINS_Perc_reducao,
      --                  ISNULL(ITrb_COFINS.Perc_imposto,0) AS ITrb_COFINS_Perc_imposto,
      --                  ISNULL(ITrb_COFINS.Valor_imposto,0) AS ITrb_COFINS_Valor_imposto,
      --                  ISNULL(ITrb_COFINS.Valor_isentas,0) AS ITrb_COFINS_Valor_isentas,
      --                  ISNULL(ITrb_COFINS.Valor_outras,0) AS ITrb_COFINS_Valor_outras,
      --                  ITrb_COFINS.Atlz_saldo AS ITrb_COFINS_Atlz_saldo,
      --                  ITrb_COFINS.Situacao_trib AS ITrb_COFINS_Situacao_trib,
      --                  ITrb_COFINS.Origem_lancto AS ITrb_COFINS_Origem_lancto,
      --                  ITrb_COFINS.Cod_mensagem AS ITrb_COFINS_Cod_mensagem,
      --                  ITrb_COFINS.Cod_aj AS ITrb_COFINS_Cod_aj,
      --                  ISNULL(ITrb_COFINS.Valor_imposto_calc,0) AS ITrb_COFINS_Valor_imposto_calc,
      --                  ITrb_COFINS.id AS ITrb_COFINS_id,
      --                  ITrb_COFINS.id_livroregesitem AS ITrb_COFINS_id_livroregesitem,
      --                  ISNULL(ITrb_COFINS.vICMSUFDest,0) AS ITrb_COFINS_vICMSUFDest,
      --                  ISNULL(ITrb_COFINS.pICMSUFDest,0) AS ITrb_COFINS_pICMSUFDest,
      --                  ISNULL(ITrb_COFINS.vICMSUFOrig ,0)AS ITrb_COFINS_vICMSUFOrig,
      --                  ITrb_COFINS.cEnq AS ITrb_COFINS_cEnq,
      --                  ISNULL(ITrb_COFINS.Perc_imposto_diferido,0) AS ITrb_COFINS_Perc_imposto_diferido,
      --                  ISNULL(ITrb_COFINS.Valor_imposto_diferido,0) AS ITrb_COFINS_Valor_imposto_diferido,
      --                  ISNULL(ITrb_COFINS.Valor_imposto_devido,0) AS ITrb_COFINS_Valor_imposto_devido,
      --                  ISNULL(ITrb_COFINS.Perc_imposto_FCP,0) AS ITrb_COFINS_Perc_imposto_FCP,
      --                  ISNULL(ITrb_COFINS.Valor_imposto_FCP,0) AS ITrb_COFINS_Valor_imposto_FCP,
      --                  ISNULL(ITrb_COFINS.vICMSDeson,0) AS ITrb_COFINS_vICMSDeson,
      --                  ITrb_COFINS.motDesICMS AS ITrb_COFINS_motDesICMS,
      --                  ISNULL(ITrb_COFINS.Perc_reducao_interno,0) AS ITrb_COFINS_Perc_reducao_interno,
      --                  ISNULL(ITrb_COFINS.vBCUFDest,0) AS ITrb_COFINS_vBCUFDest,
      --                  ITrb_COFINS.Cod_reduz_conta_trb AS ITrb_COFINS_Cod_reduz_conta_trb,
      --                  ITrb_COFINS.Cod_reduz_conta_trbaux AS ITrb_COFINS_Cod_reduz_conta_trbaux,
      --                  ITrb_COFINS.Cod_ccusto_trb AS ITrb_COFINS_Cod_ccusto_trb,
      --                  ITrb_COFINS.Cod_ccusto_trbaux AS ITrb_COFINS_Cod_ccusto_trbaux,
      --                  ITrb_COFINS.Ind_Adicional_Servicos AS ITrb_COFINS_Ind_Adicional_Servicos,
      --                  ITrb_COFINS.Imposto_retido AS ITrb_COFINS_Imposto_retido,
      --                  ITrb_COFINS.Origem_valor_cod_aj_aux AS ITrb_COFINS_Origem_valor_cod_aj_aux,
      --                  ITrb_COFINS.cod_aj_aux AS ITrb_COFINS_cod_aj_aux,
      --                  ISNULL(ITrb_COFINS.Valor_pauta,0) AS ITrb_COFINS_Valor_pauta,
      --                  ISNULL(ITrb_COFINS.Perc_margem,0) AS ITrb_COFINS_Perc_margem,
      --                  ITrb_COFINS.cBenef AS ITrb_COFINS_cBenef,
      --                  ISNULL(ITrb_COFINS.vBCFCPUFDest,0) AS ITrb_COFINS_vBCFCPUFDest,
      --                  ISNULL(ITrb_COFINS.Perc_imposto_trib_media,0) AS ITrb_COFINS_Perc_imposto_trib_media,
      --                  ITrb_COFINS.Identificador AS ITrb_COFINS_Identificador,
      --                  ISNULL(ITrb_COFINS.vICMSDeson_Desc,0) AS ITrb_COFINS_vICMSDeson_Desc,
      --                  ITrb_COFINS.Formula_interna_uf AS ITrb_COFINS_Formula_interna_uf,
      --                  ISNULL(ITrb_COFINS.perc_reducao_deson,0) AS ITrb_COFINS_perc_reducao_deson,
      --                  --ITrb_IPI.*,
      --                  ITrb_IPI.Chave_fato AS ITrb_IPI_Chave_fato,
      --                  ITrb_IPI.Num_item AS ITrb_IPI_Num_item,
      --                  ITrb_IPI.Num_subitem AS ITrb_IPI_Num_subitem,
      --                  ITrb_IPI.Cod_imposto AS ITrb_IPI_Cod_imposto,
      --                  ITrb_IPI.Cod_filial AS ITrb_IPI_Cod_filial,
      --                  ITrb_IPI.Cod_periodo AS ITrb_IPI_Cod_periodo,
      --                  ISNULL(ITrb_IPI.Valor_base,0) AS ITrb_IPI_Valor_base,
      --                  ISNULL(ITrb_IPI.Perc_reducao,0) AS ITrb_IPI_Perc_reducao,
      --                  ISNULL(ITrb_IPI.Perc_imposto,0) AS ITrb_IPI_Perc_imposto,
      --                  ISNULL(ITrb_IPI.Valor_imposto,0) AS ITrb_IPI_Valor_imposto,
      --                  ISNULL(ITrb_IPI.Valor_isentas,0) AS ITrb_IPI_Valor_isentas,
      --                  ISNULL(ITrb_IPI.Valor_outras,0) AS ITrb_IPI_Valor_outras,
      --                  ITrb_IPI.Atlz_saldo AS ITrb_IPI_Atlz_saldo,
      --                  ITrb_IPI.Situacao_trib AS ITrb_IPI_Situacao_trib,
      --                  ITrb_IPI.Origem_lancto AS ITrb_IPI_Origem_lancto,
      --                  ITrb_IPI.Cod_mensagem AS ITrb_IPI_Cod_mensagem,
      --                  ITrb_IPI.Cod_aj AS ITrb_IPI_Cod_aj,
      --                  ISNULL(ITrb_IPI.Valor_imposto_calc,0) AS ITrb_IPI_Valor_imposto_calc,
      --                  ITrb_IPI.id AS ITrb_IPI_id,
      --                  ITrb_IPI.id_livroregesitem AS ITrb_IPI_id_livroregesitem,
      --                  ISNULL(ITrb_IPI.vICMSUFDest,0) AS ITrb_IPI_vICMSUFDest,
      --                  ISNULL(ITrb_IPI.pICMSUFDest,0) AS ITrb_IPI_pICMSUFDest,
      --                  ISNULL(ITrb_IPI.vICMSUFOrig,0) AS ITrb_IPI_vICMSUFOrig,
      --                  ITrb_IPI.cEnq AS ITrb_IPI_cEnq,
      --                  ISNULL(ITrb_IPI.Perc_imposto_diferido,0) AS ITrb_IPI_Perc_imposto_diferido,
      --                  ISNULL(ITrb_IPI.Valor_imposto_diferido,0) AS ITrb_IPI_Valor_imposto_diferido,
      --                  ISNULL(ITrb_IPI.Valor_imposto_devido,0) AS ITrb_IPI_Valor_imposto_devido,
      --                  ISNULL(ITrb_IPI.Perc_imposto_FCP,0) AS ITrb_IPI_Perc_imposto_FCP,
      --                  ISNULL(ITrb_IPI.Valor_imposto_FCP,0) AS ITrb_IPI_Valor_imposto_FCP,
      --                  ISNULL(ITrb_IPI.vICMSDeson,0) AS ITrb_IPI_vICMSDeson,
      --                  ITrb_IPI.motDesICMS AS ITrb_IPI_motDesICMS,
      --                  ISNULL(ITrb_IPI.Perc_reducao_interno,0) AS ITrb_IPI_Perc_reducao_interno,
      --                  ISNULL(ITrb_IPI.vBCUFDest,0) AS ITrb_IPI_vBCUFDest,
      --                  ITrb_IPI.Cod_reduz_conta_trb AS ITrb_IPI_Cod_reduz_conta_trb,
      --                  ITrb_IPI.Cod_reduz_conta_trbaux AS ITrb_IPI_Cod_reduz_conta_trbaux,
      --                  ITrb_IPI.Cod_ccusto_trb AS ITrb_IPI_Cod_ccusto_trb,
      --                  ITrb_IPI.Cod_ccusto_trbaux AS ITrb_IPI_Cod_ccusto_trbaux,
      --                  ITrb_IPI.Ind_Adicional_Servicos AS ITrb_IPI_Ind_Adicional_Servicos,
      --                  ITrb_IPI.Imposto_retido AS ITrb_IPI_Imposto_retido,
      --                  ITrb_IPI.Origem_valor_cod_aj_aux AS ITrb_IPI_Origem_valor_cod_aj_aux,
      --                  ITrb_IPI.cod_aj_aux AS ITrb_IPI_cod_aj_aux,
      --                  ISNULL(ITrb_IPI.Valor_pauta,0) AS ITrb_IPI_Valor_pauta,
      --                  ISNULL(ITrb_IPI.Perc_margem,0) AS ITrb_IPI_Perc_margem,
      --                  ITrb_IPI.cBenef AS ITrb_IPI_cBenef,
      --                  ISNULL(ITrb_IPI.vBCFCPUFDest,0) AS ITrb_IPI_vBCFCPUFDest,
      --                  ISNULL(ITrb_IPI.Perc_imposto_trib_media,0) AS ITrb_IPI_Perc_imposto_trib_media,
      --                  ITrb_IPI.Identificador AS ITrb_IPI_Identificador,
      --                  ISNULL(ITrb_IPI.vICMSDeson_Desc,0) AS ITrb_IPI_vICMSDeson_Desc,
      --                  ITrb_IPI.Formula_interna_uf AS ITrb_IPI_Formula_interna_uf,
      --                  ISNULL(ITrb_IPI.perc_reducao_deson,0) AS ITrb_IPI_perc_reducao_deson,
      --                  --ITrb_out.*
      --                  ITrb_out.Chave_fato AS ITrb_OUTRO_Chave_fato,
      --                  ITrb_out.Num_item AS ITrb_OUTRO_Num_item,
      --                  ITrb_out.Num_subitem AS ITrb_OUTRO_Num_subitem,
      --                  ITrb_out.Cod_imposto AS ITrb_OUTRO_Cod_imposto,
      --                  ITrb_out.Cod_filial AS ITrb_OUTRO_Cod_filial,
      --                  ITrb_out.Cod_periodo AS ITrb_OUTRO_Cod_periodo,
      --                  ISNULL(ITrb_out.Valor_base,0) AS ITrb_OUTRO_Valor_base,
      --                  ISNULL(ITrb_out.Perc_reducao,0) AS ITrb_OUTRO_Perc_reducao,
      --                  ISNULL(ITrb_out.Perc_imposto,0) AS ITrb_OUTRO_Perc_imposto,
      --                  ISNULL(ITrb_out.Valor_imposto,0) AS ITrb_OUTRO_Valor_imposto,
      --                  ISNULL(ITrb_out.Valor_isentas,0) AS ITrb_OUTRO_Valor_isentas,
      --                  ISNULL(ITrb_out.Valor_outras,0) AS ITrb_OUTRO_Valor_outras,
      --                  ITrb_out.Atlz_saldo AS ITrb_OUTRO_Atlz_saldo,
      --                  ITrb_out.Situacao_trib AS ITrb_OUTRO_Situacao_trib,
      --                  ITrb_out.Origem_lancto AS ITrb_OUTRO_Origem_lancto,
      --                  ITrb_out.Cod_mensagem AS ITrb_OUTRO_Cod_mensagem,
      --                  ITrb_out.Cod_aj AS ITrb_OUTRO_Cod_aj,
      --                  ISNULL(ITrb_out.Valor_imposto_calc,0) AS ITrb_OUTRO_Valor_imposto_calc,
      --                  ITrb_out.id AS ITrb_OUTRO_id,
      --                  ITrb_out.id_livroregesitem AS ITrb_OUTRO_id_livroregesitem,
      --                  ISNULL(ITrb_out.vICMSUFDest,0) AS ITrb_OUTRO_vICMSUFDest,
      --                  ISNULL(ITrb_out.pICMSUFDest,0) AS ITrb_OUTRO_pICMSUFDest,
      --                  ISNULL(ITrb_out.vICMSUFOrig,0) AS ITrb_OUTRO_vICMSUFOrig,
      --                  ITrb_out.cEnq AS ITrb_OUTRO_cEnq,
      --                  ISNULL(ITrb_out.Perc_imposto_diferido,0) AS ITrb_OUTRO_Perc_imposto_diferido,
      --                  ISNULL(ITrb_out.Valor_imposto_diferido,0) AS ITrb_OUTRO_Valor_imposto_diferido,
      --                  ISNULL(ITrb_out.Valor_imposto_devido,0) AS ITrb_OUTRO_Valor_imposto_devido,
      --                  ISNULL(ITrb_out.Perc_imposto_FCP,0) AS ITrb_OUTRO_Perc_imposto_FCP,
      --                  ISNULL(ITrb_out.Valor_imposto_FCP,0) AS ITrb_OUTRO_Valor_imposto_FCP,
      --                  ISNULL(ITrb_out.vICMSDeson,0) AS ITrb_OUTRO_vICMSDeson,
      --                  ITrb_out.motDesICMS AS ITrb_OUTRO_motDesICMS,
      --                  ISNULL(ITrb_out.Perc_reducao_interno,0) AS ITrb_OUTRO_Perc_reducao_interno,
      --                  ISNULL(ITrb_out.vBCUFDest,0) AS ITrb_OUTRO_vBCUFDest,
      --                  ITrb_out.Cod_reduz_conta_trb AS ITrb_OUTRO_Cod_reduz_conta_trb,
      --                  ITrb_out.Cod_reduz_conta_trbaux AS ITrb_OUTRO_Cod_reduz_conta_trbaux,
      --                  ITrb_out.Cod_ccusto_trb AS ITrb_OUTRO_Cod_ccusto_trb,
      --                  ITrb_out.Cod_ccusto_trbaux AS ITrb_OUTRO_Cod_ccusto_trbaux,
      --                  ITrb_out.Ind_Adicional_Servicos AS ITrb_OUTRO_Ind_Adicional_Servicos,
      --                  ITrb_out.Imposto_retido AS ITrb_OUTRO_Imposto_retido,
      --                  ITrb_out.Origem_valor_cod_aj_aux AS ITrb_OUTRO_Origem_valor_cod_aj_aux,
      --                  ITrb_out.cod_aj_aux AS ITrb_OUTRO_cod_aj_aux,
      --                  ISNULL(ITrb_out.Valor_pauta,0) AS ITrb_OUTRO_Valor_pauta,
      --                  ISNULL(ITrb_out.Perc_margem,0) AS ITrb_OUTRO_Perc_margem,
      --                  ITrb_out.cBenef AS ITrb_OUTRO_cBenef,
      --                  ISNULL(ITrb_out.vBCFCPUFDest,0) AS ITrb_OUTRO_vBCFCPUFDest,
      --                  ISNULL(ITrb_out.Perc_imposto_trib_media,0) AS ITrb_OUTRO_Perc_imposto_trib_media,
      --                  ITrb_out.Identificador AS ITrb_OUTRO_Identificador,
      --                  ISNULL(ITrb_out.vICMSDeson_Desc,0) AS ITrb_OUTRO_vICMSDeson_Desc,
      --                  ITrb_out.Formula_interna_uf AS ITrb_OUTRO_Formula_interna_uf,
      --                  ISNULL(ITrb_out.perc_reducao_deson,0) AS ITrb_OUTRO_perc_reducao_deson
                        from [SATKFRANGAO].[dbo].tbLivroRegES Liv 
		            	left join [SATKFRANGAO].[dbo].tbFilial filial 
		            		on  Liv.Cod_filial = filial.Cod_filial
		            	inner join [SATKFRANGAO].[dbo].tbLivroRegEsItem item
		            		on  Liv.Chave_fato = Item.Chave_fato and
		            			(charindex('C', isnull(liv.status, 'F') + isnull(item.status_item, 'F')) = 0)
		            	left join [SATKFRANGAO].[dbo].tbProduto prod
		            		on  item.Cod_produto = prod.Cod_produto
		            	left join [SATKFRANGAO].[dbo].tbProdutoRef prodref
		            		on  item.Cod_produto = prodref.Cod_produto and
		            			item.Cod_ref = prodref.Cod_ref
		            	left join [SATKFRANGAO].[dbo].tbProdutoPcp prodpcp
		            		on  liv.Cod_filial = prodpcp.Cod_filial and
		            			prodref.Cod_produto = prodpcp.Cod_produto and
		            			prodref.Cod_ref = prodpcp.Cod_ref
		            	inner join [SATKFRANGAO].[dbo].tbLoteEscrita Lote 
		            		on  Liv.Cod_lote = Lote.Cod_lote and
		            			Liv.Cod_filial = Lote.Cod_filial
		            	left  join [SATKFRANGAO].[dbo].tbLivroRegESItemTrb ITrb_ICMS
		            		on  item.chave_fato   = ITrb_ICMS.chave_fato and
		            			item.num_item     = ITrb_ICMS.num_item and
		            			item.num_subitem  = ITrb_ICMS.num_subitem and
		            			ITrb_ICMS.Cod_imposto  = 'ICMS'
		            	left  join [SATKFRANGAO].[dbo].tbLivroRegESItemTrb ITrb_ICMST
		            		on  item.chave_fato   = ITrb_ICMST.chave_fato and
		            			item.num_item     = ITrb_ICMST.num_item and
		            			item.num_subitem  = ITrb_ICMST.num_subitem and
		            			ITrb_ICMST.Cod_imposto  = 'ICMST'
		            	left  join [SATKFRANGAO].[dbo].tbLivroRegESItemTrb ITrb_PIS
		            		on  item.chave_fato   = ITrb_PIS.chave_fato and
		            			item.num_item     = ITrb_PIS.num_item and
		            			item.num_subitem  = ITrb_PIS.num_subitem and
		            			ITrb_PIS.Cod_imposto  = 'PIS'
		            	left  join [SATKFRANGAO].[dbo].tbLivroRegESItemTrb ITrb_COFINS
		            		on  item.chave_fato   = ITrb_COFINS.chave_fato and
		            			item.num_item     = ITrb_COFINS.num_item and
		            			item.num_subitem  = ITrb_COFINS.num_subitem and
		            			ITrb_COFINS.Cod_imposto  = 'COFINS'
		            	left  join [SATKFRANGAO].[dbo].tbLivroRegESItemTrb ITrb_IPI
		            		on  item.chave_fato   = ITrb_IPI.chave_fato and
		            			item.num_item     = ITrb_IPI.num_item and
		            			item.num_subitem  = ITrb_IPI.num_subitem and
		            			ITrb_IPI.Cod_imposto  = 'IPI'
		            	--left  join [SATKFRANGAO].[dbo].tbLivroRegESItemTrb ITrb_out
		            	--	on  item.chave_fato   = ITrb_out.chave_fato and
		            	--		item.num_item     = ITrb_out.num_item and
		            	--		item.num_subitem  = ITrb_out.num_subitem and
		            	--		ITrb_out.Cod_imposto  = 'ISSQN'
                        left  join [SATKFRANGAO].[dbo].tbPlanoConta pl on item.Cod_cta = pl.Cod_reduz_conta
                    WHERE 															         			            
			            liv.data_reg > = (cast(dateadd(d,-120,getdate()) as date))
                    and liv.cod_filial IN('100')
GO
