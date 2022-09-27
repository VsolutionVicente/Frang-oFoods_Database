ALTER PROCEDURE [dbo].[PS_Carga_DW_Dim]
as
begin 
    /*Dimensão DIM_Empresas*/
     merge into Dim_Empresas
        using (select ID_EMPRESA      as ID_Empresa,
                      NOME_FANTASIA   as NM_Empresa, 
                      EMPRESA         as Sg_Empresa
                 From [MIMS].[DBO].SCT_EMPRESA) vw on (TRIM(VW.Sg_Empresa) = TRIM(DIM_EMPRESAS.Sg_Empresa))
    when MATCHED then
                update 
                    set Dim_Empresas.Id_Empresa = vw.ID_Empresa,
                        Dim_Empresas.Nm_Empresa = vw.NM_Empresa
    when not MATCHED THEN 
                INSERT (Id_Empresa,
                        Nm_Empresa, 
                        Sg_Empresa)
                VALUES (VW.ID_Empresa,
                        VW.NM_Empresa,
                        VW.Sg_Empresa);

    /*Dimensão Dim_Filiais */
    merge into Dim_Filiais 
          using (select ID_FILIAL     as Id_Filial,
                        NOME_FANTASIA as Nm_Filial,
                        Filial        as Sg_Filial
                   from [MIMS].[DBO].SCT_FILIAL    
                  ) VW ON (VW.Id_Filial = Dim_Filiais.Id_Filial)
    when MATCHED then
            update 
                set Dim_Filiais.Nm_Filial = VW.Nm_Filial,
                    Dim_Filiais.Sg_Filial = VW.Sg_Filial
    when not MATCHED then     
                Insert (Id_Filial,
                        Nm_Filial,
                        Sg_Filial)
                values (vw.Id_Filial,
                        vw.Nm_Filial,
                        vw.Sg_Filial);

    /*Dimensão DIM_Usuários*/
    merge into Dim_Usuarios 
          using (select	SCT_Usuario.ID_USUARIO,
                        Sistema_usuario.ID_USUASIST,  
                        SCT_Usuario.NOME_USUARIO
                  from	[MIMS].[DBO].SCT_USUARIO SCT_Usuario
                  join	[MIMS].[DBO].SISTEMA_USUARIO  Sistema_usuario on (SCT_Usuario.ID_USUARIO = Sistema_usuario.ID_USUARIO)      
                  ) VW ON (VW.ID_USUARIO = Dim_Usuarios.Id_Usuario)
    when MATCHED then
            update 
                set Dim_Usuarios.Id_UsuaSist = VW.ID_USUASIST,
                    Dim_Usuarios.Nm_Usuario  = VW.NOME_USUARIO
    when not MATCHED then     
            Insert (Id_Usuario,
                    Id_UsuaSist,
                    Nm_Usuario)
            values (VW.ID_USUARIO,
                    VW.ID_USUASIST,  
                    VW.NOME_USUARIO);

    /*Dimensão Dim_Localidades*/
    merge into Dim_Localidades
        using   (select Cidade.ID_CIDADE as id_Cidade,
                        Cidade.NM_CIDADE as Nm_Cidade, 
                        Estado.ID_ESTADO as Id_Estado,
                        Estado.NM_ESTADO as Nm_Estado,
                        Estado.SG_ESTADO as Sg_UF,
                        Regiao_Geografica.ID_REGIGEOG as Id_RegiaoGeografica,
                        Regiao_Geografica.NM_REGIGEOG as Nm_RegiaoGeografica,
                        Regiao_Geografica.SG_REGIGEOG as Sg_RegiaoGeografica,
                        Pais.ID_PAIS as Id_Pais,
                        Pais.NM_PAIS as Nm_Pais
                   from [MIMS].[DBO].PAIS Pais
                   join [MIMS].[DBO].ESTADO Estado on (Pais.ID_PAIS = Estado.ID_PAIS)
                   join [MIMS].[DBO].REGIAO_GEOGRAFICA Regiao_Geografica on (Estado.ID_REGIGEOG = Regiao_Geografica.ID_REGIGEOG)
                   Join [MIMS].[DBO].CIDADE Cidade on (Estado.ID_ESTADO = Cidade.ID_ESTADO)) VW ON (VW.id_Cidade = Dim_Localidades.Id_Cidade)
    when MATCHED then
                update  
                    SET Dim_Localidades.Nm_Cidade            = VW.Nm_Cidade          ,
                        Dim_Localidades.Id_Estado            = VW.Id_Estado          ,
                        Dim_Localidades.Nm_Estado            = VW.Nm_Estado          ,
                        Dim_Localidades.Sg_UF                = VW.Sg_UF              ,
                        Dim_Localidades.Id_RegiaoGeografica  = VW.Id_RegiaoGeografica,
                        Dim_Localidades.Nm_RegiaoGeografica  = VW.Nm_RegiaoGeografica,
                        Dim_Localidades.Sg_RegiaoGeografica  = VW.Sg_RegiaoGeografica,
                        Dim_Localidades.Id_Pais              = VW.Id_Pais            ,
                        Dim_Localidades.Nm_Pais              = VW.Nm_Pais            
    when not MATCHED then
                Insert (Id_Cidade,
                        Nm_Cidade,
                        Id_Estado,
                        Nm_Estado,
                        Sg_UF,
                        Id_RegiaoGeografica,
                        Nm_RegiaoGeografica,
                        Sg_RegiaoGeografica,
                        Id_Pais,
                        Nm_Pais)
                values (VW.id_Cidade,
                        VW.Nm_Cidade, 
                        VW.Id_Estado,
                        VW.Nm_Estado,
                        VW.Sg_UF,
                        VW.Id_RegiaoGeografica,
                        VW.Nm_RegiaoGeografica,
                        VW.Sg_RegiaoGeografica,
                        VW.Id_Pais,
                        VW.Nm_Pais);  

    /*Dimensão Dim_Veiculos*/
    merge into Dim_Veiculos
        using (select DISTINCT 
					  GN_PLACVEICTRAN as Gn_PlacaVeiculo
				 FROM [MIMS].[DBO].TRANSPORTADOR_VEICULO) VW on (vw.Gn_PlacaVeiculo = Dim_Veiculos.GN_PlacaVeiculo)
    when not MATCHED then 
        insert (Id_Veiculo,
				GN_PlacaVeiculo)
        values (@@IDENTITY,
                VW.Gn_PlacaVeiculo);

    /*Dimensão Dim_Produto*/                
    merge into Dim_Produtos
        using (select ID_MATEEMBA         AS Id_Produto ,
                	  ID_PRODMATEEMBA     AS Id_CodigoProduto,
                      IE_MATEEMBA         AS Id_CodigoExternoProduto,
					  NM_PRODMATEEMBA     AS Nm_Produto,
					  NM_PRODREDUMATEEMBA AS  Nm_ReduzidoProduto,
					  CASE WHEN QN_CAPAPADRMATEEMBA <> 0 THEN 'PR'ELSE 'PM' END AS FL_PesoPadraoProduto,
					  CASE WHEN QN_CAPAPADRMATEEMBA <> 0 THEN QN_CAPAPADRMATEEMBA ELSE QN_CAPAMEDIMATEEMBA END AS Ps_Produto
				 from [MIMS].[DBO].VW_MATERIAL_EMBALAGEM MATERIAL_EMBALAGEM) VW ON (VW.Id_Produto = Dim_Produtos.Id_Produto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos.Id_CodigoProduto		 = VW.Id_CodigoProduto		 ,
                    Dim_Produtos.Id_CodigoExternoProduto = VW.Id_CodigoExternoProduto,
					Dim_Produtos.Nm_Produto				 = VW.Nm_Produto			 ,
					Dim_Produtos.Nm_ReduzidoProduto		 = VW.Nm_ReduzidoProduto	 ,
					Dim_Produtos.FL_PesoPadraoProduto	 = VW.FL_PesoPadraoProduto	 ,
					Dim_Produtos.Ps_Produto				 = VW.Ps_Produto				
    when not MATCHED then
            insert (Id_Produto,
					Id_CodigoProduto,
					Id_CodigoExternoProduto,
					Nm_Produto,
					Nm_ReduzidoProduto,
					FL_PesoPadraoProduto,
					Ps_Produto)
            values (VW.Id_Produto ,
					VW.Id_CodigoProduto,
					VW.Id_CodigoExternoProduto,
					VW.Nm_Produto,
					VW.Nm_ReduzidoProduto,
					VW.FL_PesoPadraoProduto,
					VW.Ps_Produto);

    /*Dimensão Dim_Produtos_Categorias*/                
    merge into Dim_Produtos_Categorias
        using (select ID_CATEMATE    as Id_CategoriaProduto,
                      nm_cATEMATE    as Nm_CategoriaProduto
				  FROM [MIMS].[DBO].MATERIAL_CATEGORIA) VW ON (VW.Id_CategoriaProduto = Dim_Produtos_Categorias.Id_CategoriaProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_Categorias.Nm_CategoriaProduto = VW.Nm_CategoriaProduto		
    when not MATCHED then
 			insert (Id_CategoriaProduto,
					Nm_CategoriaProduto)
            values (VW.Id_CategoriaProduto,
					VW.Nm_CategoriaProduto);

    /*Dimensão Dim_Produtos_Subcategorias*/
    merge into Dim_Produtos_Subcategorias
        using (select ID_SUBCMATE    as Id_SubcategoriaProduto,
                      NM_SUBCMATE    as Nm_SubcategoriaProduto
				 from [MIMS].[DBO].MATERIAL_SUBCATEGORIA)VW ON (VW.Id_SubcategoriaProduto = Dim_Produtos_Subcategorias.Id_SubcategoriaProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_Subcategorias.Nm_SubcategoriaProduto = VW.Nm_SubcategoriaProduto		
    when not MATCHED then
			insert (Id_SubcategoriaProduto,
					Nm_SubcategoriaProduto)
			VALUES (VW.Id_SubcategoriaProduto,
					VW.Nm_SubcategoriaProduto);

    /*Dimensão Dim_Produtos_Tipos*/
    merge into Dim_Produtos_Tipos
        using (select ID_TIPOMATE    as Id_TipoProduto,
					  NM_TIPOMATE    as Nm_TipoProduto
				 from [MIMS].[DBO].MATERIAL_TIPO)VW ON (VW.Id_TipoProduto = Dim_Produtos_Tipos.Id_TipoProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_Tipos.Nm_TipoProduto = VW.Nm_TipoProduto		
    when not MATCHED then
			insert (Id_TipoProduto,
					Nm_TipoProduto)
            values (vw.Id_TipoProduto,
					vw.Nm_TipoProduto);

    /*Dimensão Dim_Produtos_Grupos*/
    merge into Dim_Produtos_Grupos
        using (select   ID_GRUPMATE    as Id_GrupoProduto,
						NM_GRUPMATE    as Nm_GrupoProduto
				   from [MIMS].[DBO].MATERIAL_GRUPO)VW ON (VW.Id_GrupoProduto = Dim_Produtos_Grupos.Id_GrupoProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_Grupos.Nm_GrupoProduto = VW.Nm_GrupoProduto		
    when not MATCHED then
			insert (Id_GrupoProduto,
					Nm_GrupoProduto)
            values (vw.Id_GrupoProduto,
					vw.Nm_GrupoProduto);

    /*Dimensão Dim_Produtos_Classificacoes*/
    merge into Dim_Produtos_Classificacoes
        using (select   ID_CLASMATE     as Id_ClassificacaoProduto, 	
                        NM_CLASMATE     as Nm_ClassificacaoProduto
				   from [MIMS].[DBO].MATERIAL_CLASSIFICACAO)VW ON (VW.Id_ClassificacaoProduto = Dim_Produtos_Classificacoes.Id_ClassificacaoProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_Classificacoes.Nm_ClassificacaoProduto = VW.Nm_ClassificacaoProduto		
    when not MATCHED then
			insert (Id_ClassificacaoProduto,
					Nm_ClassificacaoProduto)
            values (vw.Id_ClassificacaoProduto, 	
					vw.Nm_ClassificacaoProduto);

    /*Dimensão Dim_Produtos_Familias*/
    merge into Dim_Produtos_Familias
        using (select   ID_FAMIPROD     as Id_FamiliaProduto, 	
						NM_FAMIPROD     as Nm_FamiliaProduto
				   from [MIMS].[DBO].PRODUTO_FAMILIA)VW ON (VW.Id_FamiliaProduto = Dim_Produtos_Familias.Id_FamiliaProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_Familias.Nm_FamiliaProduto = VW.Nm_FamiliaProduto		
    when not MATCHED then
			insert (Id_FamiliaProduto,
					Nm_FamiliaProduto)
            values (vw.Id_FamiliaProduto, 	
					vw.Nm_FamiliaProduto);

    /*Dimensão Dim_Produtos_Marcas*/
    merge into Dim_Produtos_Marcas
        using (select ID_MARCA AS Id_MarcaProduto,
					  NM_MARCA AS Nm_MarcaProduto
				from [MIMS].[DBO].MARCA)VW ON (VW.Id_MarcaProduto = Dim_Produtos_Marcas.Id_MarcaProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_Marcas.Nm_MarcaProduto = VW.Nm_MarcaProduto		
    when not MATCHED then
			insert (Id_MarcaProduto,
					Nm_MarcaProduto)
			values (vw.Id_MarcaProduto,
					vw.Nm_MarcaProduto);

    /*Dimensão Dim_Produtos_RegrasValidade*/
    merge into Dim_Produtos_RegrasValidade
        using (select   ID_VALIMATEEMBA as Id_RegraValidadeProduto,
						NM_VALIMATEEMBA as Nm_RegraValidadeProduto
			       from [MIMS].[DBO].MATERIAL_EMBALAGEM_VALIDADE)VW ON (VW.Id_RegraValidadeProduto = Dim_Produtos_RegrasValidade.Id_RegraValidadeProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_RegrasValidade.Nm_RegraValidadeProduto = VW.Nm_RegraValidadeProduto		
    when not MATCHED then
			insert (Id_RegraValidadeProduto,
					Nm_RegraValidadeProduto)
            values (vw.Id_RegraValidadeProduto,
					vw.Nm_RegraValidadeProduto);

    /*Dimensão Dim_Materiais*/
    merge into Dim_Materiais
        using (select   ID_MATERIAL as Id_Material,
						NM_MATERIAL as Nm_Material
				   from [MIMS].[DBO].MATERIAL)VW ON (VW.Id_Material = Dim_Materiais.Id_Material)
    when MATCHED THEN 
        UPDATE SET  Dim_Materiais.Nm_Material = VW.Nm_Material		
    when not MATCHED then
			Insert (Id_Material,	
					Nm_Material)
            values (vw.Id_Material,
					vw.Nm_Material);

    /*Dimensão Dim_Materiais_Tipos*/
    merge into Dim_Materiais_Tipos
        using (select   ID_TIPOMATE as Id_TipoMaterial,
						NM_TIPOMATE as Nm_TipoMaterial
				   from [MIMS].[DBO].MATERIAL_TIPO)VW ON (VW.Id_TipoMaterial = Dim_Materiais_Tipos.Id_TipoMaterial)
    when MATCHED THEN 
        UPDATE SET  Dim_Materiais_Tipos.Nm_TipoMaterial = VW.Nm_TipoMaterial		
    when not MATCHED then
			insert (Id_TipoMaterial,
					Nm_TipoMaterial)
			values (vw.Id_TipoMaterial,
					vw.Nm_TipoMaterial);

    /*Dimensão Dim_Embalagens_Tipos*/
    merge into Dim_Embalagens_Tipos
        using (select   ID_TIPOEMBA as Id_TipoEmbalagem,
						NM_TIPOEMBA as Nm_TipoEmbalagem
				   from [MIMS].[DBO].EMBALAGEM_TIPO)VW ON (VW.Id_TipoEmbalagem = Dim_Embalagens_Tipos.Id_TipoEmbalagem)
    when MATCHED THEN 
        UPDATE SET  Dim_Embalagens_Tipos.Nm_TipoEmbalagem = VW.Nm_TipoEmbalagem		
    when not MATCHED then
			insert (Id_TipoEmbalagem,
					Nm_TipoEmbalagem)
            values (vw.Id_TipoEmbalagem,
					vw.Nm_TipoEmbalagem);

    /*Dimensão Dim_Animais_Tipos*/
    merge into Dim_Animais_Tipos
        using (select   ID_TIPOAVE  as Id_TipoAnimal,
						NM_TIPOAVE  as Nm_TipoAnimal
				   FROM [MIMS].[DBO].AVE_TIPO)VW ON (VW.Id_TipoAnimal = Dim_Animais_Tipos.Id_TipoAnimal)
    when MATCHED THEN 
        UPDATE SET  Dim_Animais_Tipos.Nm_TipoAnimal = VW.Nm_TipoAnimal		
    when not MATCHED then
			insert (Id_TipoAnimal,
					Nm_TipoAnimal)
            values (vw.Id_TipoAnimal,
                    vw.Nm_TipoAnimal);

    /*Dimensão Dim_Animais_Produtos*/
    merge into Dim_Animais_Produtos
        using (select   ID_MATERIAL    as Id_ProdutoAnimal,
						NM_MATERIAL    as Nm_ProdutoAnimal
					from [MIMS].[DBO].Material 
					where Material.FL_AVEVIVAMATE = 'S')VW ON (VW.Id_ProdutoAnimal = Dim_Animais_Produtos.Id_ProdutoAnimal)
    when MATCHED THEN 
        UPDATE SET  Dim_Animais_Produtos.Nm_ProdutoAnimal = VW.Nm_ProdutoAnimal		
    when not MATCHED then
			insert (Id_ProdutoAnimal,
					Nm_ProdutoAnimal)
			values (vw.Id_ProdutoAnimal,
					vw.Nm_ProdutoAnimal);

    /*Dimensão Dim_Animais_Linhagens*/
    merge into Dim_Animais_Linhagens
        using (select   ID_LINHAVE as Id_LinhagemAnimal,
						NM_LINHAVE as Nm_LinhagemAnimal
					from [MIMS].[DBO].AVE_LINHAGEM)VW ON (VW.Id_LinhagemAnimal = Dim_Animais_Linhagens.Id_LinhagemAnimal)
    when MATCHED THEN 
        UPDATE SET  Dim_Animais_Linhagens.Nm_LinhagemAnimal = VW.Nm_LinhagemAnimal		
    when not MATCHED then
			insert (Id_LinhagemAnimal,
					Nm_LinhagemAnimal)
            values (vw.Id_LinhagemAnimal,
					vw.Nm_LinhagemAnimal);

    /*Dimensão Dim_Animais_Partes*/
    merge into Dim_Animais_Partes
        using (select 	ID_PARTAVE as Id_ParteAnimal,
						NM_PARTAVE as Nm_ParteAnimal
					from [MIMS].[DBO].AVE_PARTE 
					WHERE NM_PARTAVE NOT LIKE('CP - %'))VW ON (VW.Id_ParteAnimal = Dim_Animais_Partes.Id_ParteAnimal)
    when MATCHED THEN 
        UPDATE SET  Dim_Animais_Partes.Nm_ParteAnimal = VW.Nm_ParteAnimal		
    when not MATCHED then
			insert (Id_ParteAnimal,
					Nm_ParteAnimal)
            values (vw.Id_ParteAnimal,
					vw.Nm_ParteAnimal);

    /*Dimensão Dim_Equipamentos*/
    merge into Dim_Equipamentos
        using (	select  ID_EQUIPAMENTO as Id_Equipamento,
                        NM_EQUIPAMENTO as Nm_Equipamento,
                        COALESCE(FL_ATIVEQUI,'S') AS Fl_EquipamentoAtivo
				from [MIMS].[DBO].EQUIPAMENTO)VW ON (VW.Id_Equipamento = Dim_Equipamentos.Id_Equipamento)
    when MATCHED THEN 
        UPDATE SET  Dim_Equipamentos.Nm_Equipamento = VW.Nm_Equipamento,
                     Dim_Equipamentos.Fl_EquipamentoAtivo = vw.Fl_EquipamentoAtivo
    when not MATCHED then
			insert (Id_Equipamento,
					Nm_Equipamento,
					Fl_EquipamentoAtivo)
			values (vw.Id_Equipamento,
					vw.Nm_Equipamento,
					vw.Fl_EquipamentoAtivo);                    

/*
    --Dimensão Dim_Equipamentos_Tipos
    merge into Dim_Equipamentos_Tipos
        using (SELECT   Id_TipoEquipamento,
                        Nm_TipoEquipamento
				  FROM [MIMS].[DBO].EQUIPAMENTO_TIPO)VW ON (VW.Id_TipoEquipamento = Dim_Equipamentos_Tipos.Id_TipoEquipamento)
    when MATCHED THEN 
        UPDATE SET  Dim_Equipamentos_Tipos.Nm_TipoEquipamento = VW.Nm_TipoEquipamento
    when not MATCHED then
			INSERT (Id_TipoEquipamento,
					Nm_TipoEquipamento)
			values (vw.Id_TipoEquipamento,
					vw.Nm_TipoEquipamento);
*/                    

    /*Dimensão Dim_EquipamentosMotivosParadas*/
    merge into Dim_EquipamentosMotivosParadas
        using (select   ID_MOTIPARAEQUI	as Id_MotivoParadaEquipamento,
						NM_MOTIPARAEQUI as Nm_MotivoParadaEquipamento
					FROM [MIMS].[DBO].EQUIPAMENTO_PARADA_MOTIVO)VW ON (VW.Id_MotivoParadaEquipamento = Dim_EquipamentosMotivosParadas.Id_MotivoParadaEquipamento)
    when MATCHED THEN 
        UPDATE SET  Dim_EquipamentosMotivosParadas.Nm_MotivoParadaEquipamento = VW.Nm_MotivoParadaEquipamento
    when not MATCHED then
			insert (Id_MotivoParadaEquipamento,
					Nm_MotivoParadaEquipamento)
            values (vw.Id_MotivoParadaEquipamento,
					vw.Nm_MotivoParadaEquipamento);        

    /*Dimensão Dim_Integrados*/
    merge into Dim_Integrados
        using (SELECT   DISTINCT
                        ID_FORNECEDOR_INTEGRADO	as idIntegrado,
						NM_FORNECEDOR as Nm_Integrado
					FROM [MIMS].[DBO].GRANJA_PROPRIEDADE
                    JOIN [MIMS].[DBO].FORNECEDOR 
                         ON FORNECEDOR.ID_FORNECEDOR = GRANJA_PROPRIEDADE.ID_FORNECEDOR_INTEGRADO)VW ON (VW.idIntegrado = Dim_Integrados.Id_Integrado)
    when MATCHED THEN 
        UPDATE SET  Dim_Integrados.Nm_Integrado = VW.Nm_Integrado
    when not MATCHED then
			insert (Id_Integrado,
					Nm_Integrado)
            values (vw.idIntegrado,
					vw.Nm_Integrado);

      /*Dimensão Dim_Motoristas*/
    merge into Dim_Motoristas
        using (select   TM.ID_MOTOTRAN as Id_Motorista,
						TM.NM_MOTOTRAN      as Nm_Motorista
				  from  [MIMS].[DBO].Transportador_Motorista TM )VW ON (VW.Id_Motorista = Dim_Motoristas.Id_Motorista)
    when MATCHED THEN 
        UPDATE SET  Dim_Motoristas.Nm_Motorista = VW.Nm_Motorista
    when not MATCHED then
			insert (Id_Motorista,
					Nm_Motorista)
            values (vw.Id_Motorista,
					vw.Nm_Motorista);

    /*Dimensão Dim_LinhasProcessos*/
    merge into Dim_LinhasProcessos
        using (select   ID_PROCLINH as 	Id_LinhaProcesso,
						NM_PROCLINH as 	Nm_LinhaProcesso,
						FL_TIPOPROCLINH as 	Fl_TipoLinhaProcesso
					from [MIMS].[DBO].LINHA_PROCESSAMENTO)VW ON (VW.Id_LinhaProcesso = Dim_LinhasProcessos.Id_LinhaProcesso)
    when MATCHED THEN 
        UPDATE SET  Dim_LinhasProcessos.Nm_LinhaProcesso     = VW.Nm_LinhaProcesso,
                    Dim_LinhasProcessos.Fl_TipoLinhaProcesso = VW.Fl_TipoLinhaProcesso
    when not MATCHED then
			insert (Id_LinhaProcesso,
					Nm_LinhaProcesso,
					Fl_TipoLinhaProcesso)
            values (vw.Id_LinhaProcesso,
					vw.Nm_LinhaProcesso,
					vw.Fl_TipoLinhaProcesso);

    /*Dimensão DIM_PONTOSREGISTRO*/
    merge into DIM_PONTOSREGISTRO
        using (select   ID_PONTPROD    as ID_PONTOREGISTRO,
						NM_PONTPROD    as NM_PONTOREGISTRO
					from [MIMS].[DBO].PRODUCAO_PONTO)VW ON (VW.ID_PONTOREGISTRO = DIM_PONTOSREGISTRO.ID_PONTOREGISTRO)
    when MATCHED THEN 
        UPDATE SET  DIM_PONTOSREGISTRO.NM_PONTOREGISTRO = VW.NM_PONTOREGISTRO
    when not MATCHED then
			insert (ID_PONTOREGISTRO,
					NM_PONTOREGISTRO)
            VALUES (VW.ID_PONTOREGISTRO,
					VW.NM_PONTOREGISTRO);

    /*Dimensão Dim_Transportadores*/
    merge into Dim_Transportadores
        using ((SELECT  DISTINCT Transportador_Veiculo.id_VEICTRAN as Id_Transportador, 
                        Fornecedor.NM_FORNECEDOR          as Nm_Transportador
                   FROM [MIMS].[DBO].TRANSPORTADOR_VEICULO Transportador_Veiculo
				   Join [MIMS].[DBO].FORNECEDOR Fornecedor
						   ON Fornecedor.ID_FORNECEDOR= Transportador_Veiculo.ID_FORNECEDOR_TRANSPORTADOR
)
    )VW ON (VW.Id_Transportador = Dim_Transportadores.Id_Transportador)
    when MATCHED THEN 
        UPDATE SET  Dim_Transportadores.Nm_Transportador = VW.Nm_Transportador
    when not MATCHED then
			insert (Id_Transportador,
					Nm_Transportador)
            VALUES (VW.Id_Transportador, 
					VW.Nm_Transportador);

    /*Dimensão Dim_Veiculos_Tipos*/
    merge into Dim_Veiculos_Tipos
        using (SELECT  DISTINCT ID_TIPOVEIC	Id_TipoVeiculo,
                                NM_TIPOVEIC Nm_TipoVeiculo 
                   FROM [MIMS].[DBO].VEICULO_TIPO Veiculo_Tipo
			  )VW ON (VW.Id_TipoVeiculo = Dim_Veiculos_Tipos.Id_TipoVeiculo)
    when MATCHED THEN 
        UPDATE SET  Dim_Veiculos_Tipos.Nm_TipoVeiculo = VW.Nm_TipoVeiculo
    when not MATCHED then
			insert (Id_TipoVeiculo,
					Nm_TipoVeiculo)
            VALUES (VW.Id_TipoVeiculo, 
					VW.Nm_TipoVeiculo);




    /*Dimensão Dim_Producao_Turnos*/
    merge into Dim_Producao_Turnos
        using (SELECT distinct
					  GN_SEQUTURNPROD as Nm_TurnoProducao
                 FROM [MIMS].[DBO].PRODUCAO_TURNO)VW ON (VW.Nm_TurnoProducao = Dim_Producao_Turnos.Nm_TurnoProducao)
    when not MATCHED then
			insert (Id_TurnoProducao,
					Nm_TurnoProducao)
            values (@@IDENTITY,
                    VW.Nm_TurnoProducao);


    /*Dimensão Dim_Clientes*/
    merge into Dim_Clientes
        using (SELECT ID_CLIENTE  as Id_Cliente,
					  NM_CLIENTE  as Nm_Cliente,
					  IE_CLIENTE  AS Ie_Cliente
                 FROM [MIMS].[DBO].Cliente_GERAL)VW ON (VW.ID_CLIENTE = Dim_Clientes.Id_Cliente)
    when not MATCHED then
			insert (Id_Cliente,
					Nm_Cliente,
					Id_CodigoExternoCliente)
            values (vw.Id_Cliente,
                    vw.Nm_Cliente,
					vw.Ie_Cliente)
	when Matched then
	      update 
			 set Nm_Cliente = vw.Nm_Cliente,
			     Id_CodigoExternoCliente = vw.Ie_Cliente;


    /*Dimensão Dim_MotivosDescartes*/
    merge into Dim_MotivosDescartes
        using (select   ID_MOTIDESCPROD as Id_MotivoDescarte,
                        NM_MOTIDESCPROD as Nm_MotivoDescarte
				   FROM [MIMS].[DBO].PRODUCAO_DESCARTE_MOTIVO)VW ON (VW.Id_MotivoDescarte = Dim_MotivosDescartes.Id_MotivoDescarte)
    when MATCHED THEN 
        UPDATE SET  Dim_MotivosDescartes.Nm_MotivoDescarte = VW.Nm_MotivoDescarte
    when not MATCHED then
			insert (Id_MotivoDescarte,
					Nm_MotivoDescarte)
            values (VW.Id_MotivoDescarte,
					VW.Nm_MotivoDescarte);

    /*Dimensão Dim_Producao_Setores*/
    merge into Dim_Producao_Setores
        using (select   ID_SETOPROD as Id_SetorProducao,
						NM_SETOPROD as Nm_SetorProducao
					FROM [MIMS].[DBO].Producao_Setor)VW ON (VW.Id_SetorProducao = Dim_Producao_Setores.Id_SetorProducao)
    when MATCHED THEN 
        UPDATE SET  Dim_Producao_Setores.Nm_SetorProducao = VW.Nm_SetorProducao
    when not MATCHED then
			insert (Id_SetorProducao,
					Nm_SetorProducao)
            values (VW.Id_SetorProducao,
					VW.Nm_SetorProducao);

    /*Dimensão Dim_Departamentos*/
    merge into Dim_Departamentos
        using (SELECT   ID_DEPARTAMENTO as Id_Departamento,
						NM_DEPARTAMENTO as Nm_Departamento
					from [MIMS].[DBO].DEPARTAMENTO)VW ON (VW.Id_Departamento = Dim_Departamentos.Id_Departamento)
    when MATCHED THEN 
        UPDATE SET  Dim_Departamentos.Nm_Departamento = VW.Nm_Departamento
    when not MATCHED then
			INSERT (Id_Departamento,
					Nm_Departamento)
            values (VW.Id_Departamento,
					VW.Nm_Departamento);

    /*Dimensão Dim_Almoxarifados*/
    merge into Dim_Almoxarifados
        using (select   ID_ALMOXARIFADO as Id_Almoxarifado,
						NM_ALMOXARIFADO as Nm_Almoxarifado
					 from [MIMS].[DBO].ALMOXARIFADO)VW ON (VW.Id_Almoxarifado = Dim_Almoxarifados.Id_Almoxarifado)
    when MATCHED THEN 
        UPDATE SET  Dim_Almoxarifados.Nm_Almoxarifado = VW.Nm_Almoxarifado
    when not MATCHED then
			insert (Id_Almoxarifado,
					Nm_Almoxarifado)
            values (VW.Id_Almoxarifado,
					VW.Nm_Almoxarifado);

    /*Dimensão Dim_MotivosDesbloqueios*/
    merge into Dim_MotivosDesbloqueios
        using (select   ID_MOTIDESBPESA as Id_MotivoDesbloqueio,
                        NM_MOTIDESBPESA as Nm_MotivoDesbloqueio
					FROM [MIMS].[DBO].PESAGEM_DESBLOQUEIO_MOTIVO)VW ON (VW.Id_MotivoDesbloqueio = Dim_MotivosDesbloqueios.Id_MotivoDesbloqueio)
    when MATCHED THEN 
        UPDATE SET  Dim_MotivosDesbloqueios.Nm_MotivoDesbloqueio = VW.Nm_MotivoDesbloqueio
    when not MATCHED then
			insert (Id_MotivoDesbloqueio,
					Nm_MotivoDesbloqueio)
            values (VW.Id_MotivoDesbloqueio,
					VW.Nm_MotivoDesbloqueio);

    /*Dimensão Dim_EquipesApanha*/
    merge into Dim_EquipesApanha
        using (select IE_EQUIAPAN AS Id_EquipeApanha,
                      IE_EQUIAPAN + ' - '+	NM_EQUIAPAN as Nm_EquipeApanha
                 from [MIMS].[DBO].APANHA_EQUIPE) VW ON (VW.ID_EquipeApanha = Dim_EquipesApanha.ID_EquipeApanha)
    when not MATCHED then
			insert (Id_EquipeApanha,
					Nm_EquipeApanha)
            values (VW.Id_EquipeApanha,
                    vw.Nm_EquipeApanha);

    /*Dimensão Dim_Propriedades*/
    merge into Dim_Propriedades
        using (SELECT DISTINCT
                        ID_PROPGRAN	as Id_Propriedade,
						NM_PROPGRAN as Nm_Propriedade
					FROM [MIMS].[DBO].GRANJA_PROPRIEDADE
                )VW ON (VW.Id_Propriedade = Dim_Propriedades.Id_Propriedade)
    when MATCHED THEN 
        UPDATE SET  Dim_Propriedades.Nm_Propriedade = VW.Nm_Propriedade
    when not MATCHED then
			insert (Id_Propriedade,
					Nm_Propriedade)
            values (vw.Id_Propriedade,
					vw.Nm_Propriedade);

    /*Dimensão Dim_Produtos_Linhas*/
    merge into Dim_Produtos_Linhas
        using (SELECT FL_LINHPROD  Id_LinhaProduto,	
		              NM_LINHPROD  NM_LinhaProduto
					FROM [MIMS].[DBO].Produtos_linha
                )VW ON (VW.Id_LinhaProduto = Dim_Produtos_Linhas.Id_LinhaProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_Linhas.NM_LinhaProduto = VW.NM_LinhaProduto
    when not MATCHED then
			insert (Id_LinhaProduto,
					NM_LinhaProduto)
            values (vw.Id_LinhaProduto,
					vw.NM_LinhaProduto);

    /*Dimensão Dim_Produtos_SubLinhas*/
	merge into Dim_Produtos_SubLinhas
        using (SELECT ID_SUBLINHPROD  Id_SubLinhaProduto,	
		              NM_SUBLINHPROD  NM_SubLinhaProduto
					FROM [MIMS].[DBO].PRODUTO_SUBLINHA
                )VW ON (VW.Id_SubLinhaProduto = Dim_Produtos_SubLinhas.Id_SubLinhaProduto)
    when MATCHED THEN 
        UPDATE SET  Dim_Produtos_SubLinhas.NM_SubLinhaProduto = VW.NM_SubLinhaProduto
    when not MATCHED then
			insert (Id_SubLinhaProduto,
					NM_SubLinhaProduto)
            values (vw.Id_SubLinhaProduto,
					vw.NM_SubLinhaProduto);

end;


GO



