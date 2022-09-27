

select cast(Entradas.Data_hora as date) as Data_Lancamento,
   	   cast(Entradas.Data_hora as Time) as Hora_Lancamento,
	   Entradas.Cod_tipo_mv,
	   'Despesa' as "R/D",
	   Entradas.cod_docto,
	   CliFor.Nome_cadastro, 
	   cast(Entradas.Num_docto as varchar) + '/' + cast(EntradasParc.Num_parcela as varchar) Nf_DOC_PARC,
	   Entradas.Data_movto,
	   EntradasParc.Data_emissao,	
	   EntradasParc.Data_vencto,	
	   EntradasParc.Data_vencto_util as Data_vencto_util_Sistema,
	   CASE DATEPART(DW, EntradasParc.Data_vencto) 
			WHEN 1 THEN DATEADD(D,1,EntradasParc.Data_vencto)  
			WHEN 7 THEN DATEADD(D,2,EntradasParc.Data_vencto)  
			ELSE EntradasParc.Data_vencto
			END AS Data_vencto_util_calculado,
	   datename(weekday,EntradasParc.Data_vencto)"Dia Vencimento",
	   EntradasParc.Prazo,
	   EntradasParc.Valor * EntradasItens.PC_Valor as Valor, 
	   Filial.Apelido_filial as Empresa,
	   isnull(CC.Cod_ccusto ,0) Cod_ccusto,
	   isnull(Cod_ccusto_plano + ' ' +cc.Nome_ccusto, 'Não Informado') Centro_Custo,
	   IsNull(P.Cod_reduz_conta,0) Cod_PlanoConta,
	   isNull(Cod_conta + ' ' + Desc_conta,  'Não Informado') PlanoConta,
	   EntradasParc.Valor valor_ParcelaConferencia, *
  from [SATKFRANGAO].[dbo].TBEntradas Entradas
  INNER JOIN (select ENTRADAS.CHAVE_FATO,
                     EntradasItens.Cod_ccusto, 
                     EntradasItens.Cod_reduz_conta, 
		             Entradas.Valor_total,
		             dbo.fn_divizero(sum(EntradasItens.Valor_total), Entradas.Valor_total) PC_Valor
                from [SATKFRANGAO].[dbo].TBEntradas Entradas
                     INNER JOIN [SATKFRANGAO].[dbo].TBENTRADASITEM EntradasItens 
                             ON ENTRADAS.CHAVE_FATO = EntradasItens.CHAVE_FATO AND 
			                    EntradasItens.NUM_SUBITEM=0 AND 
			                    ISNULL(EntradasItens.STATUS_ITEM,'F') <> 'C' 
               group by 
                     ENTRADAS.CHAVE_FATO,
                     EntradasItens.Cod_ccusto, 
                     EntradasItens.Cod_reduz_conta, 
                     Entradas.Valor_total) EntradasItens
          ON ENTRADAS.CHAVE_FATO = EntradasItens.CHAVE_FATO
  inner join [SATKFRANGAO].[dbo].tbCadastroGeral CliFor
          on CliFor.Cod_cadastro = Entradas.Cod_cli_for
  inner join [SATKFRANGAO].[dbo].tbFilial Filial 
		  on Filial.Cod_filial = Entradas.Cod_filial
  Inner join [SATKFRANGAO].[dbo].tbEntradasParc EntradasParc
          on Entradas.Chave_fato = EntradasParc.Chave_fato  
  inner join [SATKFRANGAO].[dbo].tbMovtoFin MovtoFin 
		  on EntradasParc.Chave_fato = MovtoFin.Chave_fato
		 and EntradasParc.Num_parcela = MovtoFin.Num_parcela
		 and EntradasParc.Cod_filial = MovtoFin.Cod_filial
  left  join [SATKFRANGAO].[dbo].tbCentroCusto CC 
		  on EntradasItens.Cod_ccusto = cc.Cod_ccusto  /*item*/
  left  join [SATKFRANGAO].[dbo].TBPLANOCONTA P 
		  on EntradasItens.COD_REDUZ_CONTA = P.COD_REDUZ_CONTA /* item*/
where Entradas.Data_movto = '20220810'-->= cast((getdate()-10) as date)
  and Entradas.Cod_tipo_mv <> 'T584'
  and Entradas.Num_docto = 100510