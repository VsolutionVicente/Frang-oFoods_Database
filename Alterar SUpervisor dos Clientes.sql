update tbVendedor 
   set Cod_supervisor_vda  = 80322 
 where Cod_Cadastro in (select Cod_Cadastro 
                          from tbcliente 
						 where Cod_vendedor in (80016,80291, 80350));