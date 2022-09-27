ALTER VIEW [dbo].[VW_PRODUCAO_PROG_MULT_TOTA_VICENTE] AS
with cte  as
(SELECT ID_MULTPROGPROD,
                                 ROW_NUMBER() OVER (PARTITION BY ID_ESTRUNIDABAT,
                                                                 DT_MULTPROGPROD,                     
                                                                 ID_PRODMATEEMBA,                     
                                                                 NR_SEQUTURN,
                                                                 ID_ETIQUETA,
																 GN_TAGMULTPROGPROD  
                                                        ORDER BY CASE WHEN FL_BLOQPRODEXCEMULTPROGPROD = 'N' THEN 10000000000
                                                                    ELSE 0
                                                                  END + NR_PRIOMULTPROGPROD ASC) NR_POSIMULTPROGPROD,
                                 COUNT(ID_MULTPROGPROD) OVER (PARTITION BY ID_ESTRUNIDABAT,
                                                                               DT_MULTPROGPROD,                     
                                                                               ID_PRODMATEEMBA,                     
                                                                               NR_SEQUTURNMULTPROGPROD,
                                                                               ID_ETIQUETA,
																			   GN_TAGMULTPROGPROD) NR_ULTIPOSIMULTPROGPROD
                            FROM PRODUCAO_PROGRAMACAO_MULTIPLA)
SELECT VW.EMPRESA,
       VW.FILIAL,
       VW.ID_MULTPROGPROD,                                                    
       VW.ID_ESTRUNIDABAT,
       VW.ID_PRODMATEEMBA,
       VW.DT_MULTPROGPROD,
       VW.NR_PRIOMULTPROGPROD,
       VW.ID_CLIENTE,
       VW.ID_PEDIVEND,
       VW.GN_TAGMULTPROGPROD,
       VW.ID_ETIQUETA,
       VW.QN_ALERANTEEXPRMULTPROGPROD,
       VW.FL_BLOQPRODEXCEMULTPROGPROD,
       VW.FL_EXIBPAINCONTMULTPROGPROD,
       VW.FL_ALERANTEEXPRMULTPROGPROD,
       VW.FX_MULTPROGPROD,
       VW.ID_UNIDABAT,
       VW.NR_SEQUTURNMULTPROGPROD,
       VW.ID_SIMUPROGPROD,
       VW.QN_CAIXMULTPROGPROD,
	   CASE WHEN VW.FL_ULTIREGIMULTPROGPROD <> 'S'
             AND VW.QN_CAIXTOTAREGIPROD >= VW.QN_CAIXACUMMULTPROGPROD THEN VW.QN_CAIXMULTPROGPROD
          WHEN VW.QN_CAIXTOTAREGIPROD <= (VW.QN_CAIXACUMMULTPROGPROD - VW.QN_CAIXMULTPROGPROD) THEN 0
          ELSE VW.QN_CAIXTOTAREGIPROD - (VW.QN_CAIXACUMMULTPROGPROD - VW.QN_CAIXMULTPROGPROD)
        END QN_CAIXATENMULTPROGPROD,       
       VW.QN_PESOMULTPROGPROD,
       CASE WHEN VW.FL_ULTIREGIMULTPROGPROD <> 'S'
             AND VW.QN_PESOTOTAREGIPROD >= VW.QN_PESOACUMMULTPROGPROD THEN VW.QN_PESOMULTPROGPROD
          WHEN VW.QN_PESOTOTAREGIPROD <= (VW.QN_PESOACUMMULTPROGPROD - VW.QN_PESOMULTPROGPROD) THEN 0
          ELSE VW.QN_PESOTOTAREGIPROD - (VW.QN_PESOACUMMULTPROGPROD - VW.QN_PESOMULTPROGPROD)
        END QN_PESOATENMULTPROGPROD       
  FROM (SELECT PPM.EMPRESA,
               PPM.FILIAL,
               PPM.ID_MULTPROGPROD,
               PPM.ID_ESTRUNIDABAT,
               PPM.ID_PRODMATEEMBA,
               PPM.DT_MULTPROGPROD,
               PPM.NR_PRIOMULTPROGPROD,
               PPM.ID_CLIENTE,
               PPM.ID_PEDIVEND,
               PPM.GN_TAGMULTPROGPROD, 
               PPM.ID_ETIQUETA,
               PPM.QN_ALERANTEEXPRMULTPROGPROD,
               PPM.FL_BLOQPRODEXCEMULTPROGPROD,
               PPM.FL_EXIBPAINCONTMULTPROGPROD,
               PPM.FL_ALERANTEEXPRMULTPROGPROD,
               CASE WHEN VW.NR_POSIMULTPROGPROD = VW.NR_ULTIPOSIMULTPROGPROD THEN 'S'
                  ELSE 'N'
                END FL_ULTIREGIMULTPROGPROD,
               PPM.FX_MULTPROGPROD,            
               PPM.ID_UNIDABAT,                                               
               PPM.NR_SEQUTURNMULTPROGPROD,
               PPM.ID_SIMUPROGPROD,                               
               COALESCE(PPM.QN_CAIXMULTPROGPROD, 0) QN_CAIXMULTPROGPROD,
			   COALESCE((SELECT SUM(COALESCE(VW_INTE.QN_CAIXMULTPROGPROD, 0))
                           FROM PRODUCAO_PROGRAMACAO_MULTIPLA VW_INTE
                          WHERE VW_INTE.ID_ESTRUNIDABAT = PPM.ID_ESTRUNIDABAT
                            AND VW_INTE.DT_MULTPROGPROD = PPM.DT_MULTPROGPROD                                  
                            AND VW_INTE.ID_PRODMATEEMBA = PPM.ID_PRODMATEEMBA
                            AND COALESCE(VW_INTE.NR_SEQUTURNMULTPROGPROD, 0) = COALESCE(PPM.NR_SEQUTURNMULTPROGPROD, 0)            
                            AND COALESCE(VW_INTE.ID_ETIQUETA, 0) = COALESCE(PPM.ID_ETIQUETA, 0) 
							AND COALESCE(VW_INTE.GN_TAGMULTPROGPROD, '') = COALESCE(PPM.GN_TAGMULTPROGPROD, '')
                            AND CASE WHEN VW_INTE.FL_BLOQPRODEXCEMULTPROGPROD = 'N' THEN 10000000000
                                   ELSE 0
                                 END + VW_INTE.NR_PRIOMULTPROGPROD <= CASE WHEN PPM.FL_BLOQPRODEXCEMULTPROGPROD = 'N' THEN 10000000000
                                                                         ELSE 0
                                                                       END + PPM.NR_PRIOMULTPROGPROD), 0) QN_CAIXACUMMULTPROGPROD,   
               COALESCE(PRT.QN_TOTAREGIPROD, 0) QN_CAIXTOTAREGIPROD,    
               COALESCE(PPM.QN_PESOMULTPROGPROD, 0) QN_PESOMULTPROGPROD,
               COALESCE((SELECT SUM(COALESCE(VW_INTE.QN_PESOMULTPROGPROD, 0))
                           FROM PRODUCAO_PROGRAMACAO_MULTIPLA VW_INTE
                          WHERE VW_INTE.ID_ESTRUNIDABAT                      = PPM.ID_ESTRUNIDABAT
                            AND VW_INTE.DT_MULTPROGPROD                      = PPM.DT_MULTPROGPROD                                  
                            AND VW_INTE.ID_PRODMATEEMBA                      = PPM.ID_PRODMATEEMBA
                            AND VW_INTE.NR_SEQUTURN                          = PPM.NR_SEQUTURN            
                            AND VW_INTE.ID_ETIQUETA_                         = PPM.ID_ETIQUETA_
							AND VW_INTE.GN_TAGMULTPROGPROD_                  = PPM.GN_TAGMULTPROGPROD_
                            AND CASE WHEN VW_INTE.FL_BLOQPRODEXCEMULTPROGPROD = 'N' THEN 10000000000
                                   ELSE 0
                                 END + VW_INTE.NR_PRIOMULTPROGPROD <= CASE WHEN PPM.FL_BLOQPRODEXCEMULTPROGPROD = 'N' THEN 10000000000
                                                                         ELSE 0
                                                                       END + PPM.NR_PRIOMULTPROGPROD), 0) QN_PESOACUMMULTPROGPROD,  
               COALESCE(PRT.QN_PESOTOTAREGIPROD, 0) QN_PESOTOTAREGIPROD
          FROM PRODUCAO_PROGRAMACAO_MULTIPLA PPM
                   Cross apply
					  (SELECT ID_MULTPROGPROD,
                              NR_POSIMULTPROGPROD,
                              NR_ULTIPOSIMULTPROGPROD
                            FROM cte  
							where PPM.ID_MULTPROGPROD = ID_MULTPROGPROD ) VW
               LEFT JOIN PRODUCAO_REGISTRO_TOTAL PRT
                      ON PPM.ID_ESTRUNIDABAT    = PRT.ID_ESTRUNIDABAT
                     AND PPM.DT_MULTPROGPROD    = PRT.DT_PADRTOTAREGIPROD
                     AND PPM.ID_PRODMATEEMBA    = PRT.ID_PRODMATEEMBA
                     AND PPM.NR_SEQUTURN        = PRT.NR_SEQUTURN
                     AND PPM.ID_ETIQUETA_       = PRT.ID_ETIQUETA_
					 AND PPM.GN_TAGMULTPROGPROD_= PRT.GN_TAGTOTAREGIPROD_) VW


GO


