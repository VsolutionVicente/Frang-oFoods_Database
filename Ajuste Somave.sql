use MIMS_DW
go

select * from Calendario

ALTER TABLE FAT_PRODUCAO ADD Sk_SubLinhaProduto numeric(10,0)

use Mims
go

Create Table PRODUTO_SUBLINHA (
	ID_SUBLINHPROD numeric(10,0) not null,
	NM_SUBLINHPROD varchar(50)   not null, 
	ID_LINHPROD    NUMERIC(10,0) NOT NULL, 
	CONSTRAINT PK_SUBLINHPROD PRIMARY KEY(ID_SUBLINHPROD),
	CONSTRAINT fk_SUBLINH_LINHPROD FOREIGN KEY (ID_LINHPROD) REFERENCES PRODUTOS_LINHA(ID_LINHPROD))
//

CREATE INDEX idx_SUBLINH_LINHPROD on PRODUTO_SUBLINHA(ID_LINHPROD)
//

Insert Into PRODUTO_SUBLINHA values (1,'Frango',2)
Insert Into PRODUTO_SUBLINHA values (2,'Galinha',2)
Insert Into PRODUTO_SUBLINHA values (3,'Galo',2)
Insert Into PRODUTO_SUBLINHA values (4,'Sub-Produtos',4)
//

ALTER TABLE AVE_TIPO add ID_SUBLINHPROD numeric(10,0) 
//

ALTER TABLE AVE_TIPO add 
      CONSTRAINT Fk_AVETIPO_SUBLINHPROD 
	  FOREIGN KEY (ID_SUBLINHPROD) REFERENCES PRODUTO_SUBLINHA(ID_SUBLINHPROD)
//

CREATE INDEX idx_AVETIPO_SUBLINH on AVE_TIPO(ID_SUBLINHPROD)
//


select ID_TIPOAVE ,NM_TIPOAVE from AVE_TIPO
Insert Into PRODUTO_SUBLINHA values (1,'Frango',2)   -- ID_TIPOAVE 2 6 9
Insert Into PRODUTO_SUBLINHA values (2,'Galinha',2)  -- 4 , 8, 10,13,13,16,17
Insert Into PRODUTO_SUBLINHA values (3,'Galo',2)     -- 3 , 7, 11
Insert Into PRODUTO_SUBLINHA values (4,'Sub-Produtos',4) 5 
//


update AVE_TIPO set id_SubLinhProd = 1 where ID_TIPOAVE in(2,6,9)
update AVE_TIPO set id_SubLinhProd = 2 where ID_TIPOAVE in(4 , 8, 10,13,13,16,17)
update AVE_TIPO set id_SubLinhProd = 3 where ID_TIPOAVE in(3 , 7, 11)
update AVE_TIPO set id_SubLinhProd = 4 where ID_TIPOAVE in(5)
