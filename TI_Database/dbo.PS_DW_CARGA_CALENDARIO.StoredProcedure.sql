USE [TI_Database]
GO
/****** Object:  StoredProcedure [dbo].[PS_DW_CARGA_CALENDARIO]    Script Date: 20/06/2022 18:58:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[PS_DW_CARGA_CALENDARIO] 
	@DataFinal DATE = null
AS

SET LANGUAGE Português
declare @data		    DATE 
declare @Mes_Corrente   INT 
declare @Dia_Corrente   VARCHAR  
DECLARE @MENS_ERRO  VARCHAR(4000)
begin 
	BEGIN TRY
		SET NOCOUNT ON
		set @MENS_ERRO = 'Definindo a data final';
		if @DataFinal is null 
		begin
			set @DataFinal = cast(getdate()-1 as date);
		end; 

		set @MENS_ERRO = 'Pegando a ultima data do calendario';
		SELECT @data  = COALESCE(MAX(DT_TRANSACAO),'20200801') 
		  FROM DW_TI.dbo.Calendario;
		
		set @Data = dateadd(dd,1,@Data);
		set @Mes_Corrente = Month(@Data);
		set @Dia_Corrente = day (@Data);
		  
		while @Data <=@DataFinal
		begin
			set @MENS_ERRO = 'Entrando no loop de datas';
			set @Mes_Corrente = month(@data);
			set @Dia_Corrente =   day(@data);

			set @MENS_ERRO = 'Inserindo na tabela Calendario';

			insert into DW_TI.dbo.Fat_Metas (
	               Dt_Transacao,
                   Qn_VendaDiariaMeta,
				   Vl_VendaDiariaMeta,
				   Vl_MixDiarioMeta) 
		   values (@Data,
		           100000,
				   500000,
				   5);


			insert into DW_TI.dbo.Calendario (
					Dt_Transacao,
					Nr_Ano,
					Nr_Semestre,
					Nm_Semestre,
					Nr_Trimestre,
					Nm_Trimestre,
					Nr_EstacaoAno,
					Nm_EstacaoAno,
					Nr_Bimestre,
					Nm_Bimestre,
					Nr_Mes,
					Nm_Mes,
					Nm_MesAbreviado,
					Nr_SemanaAno,
					Nm_SemanaAno,
					Nr_SemanaMes,
					Nm_SemanaMes,
					Nr_Dia,
					Nr_DiaSemana,
					Nm_DiaSemana,
					Nr_DiaAno,
					Nm_MesAno,
					Nr_ClassificacaoMesAno	)

				select @Data								as Dt_Transacao,
					   YEAR(@data)							as Nr_Ano, 
					   case when MONTH(@data) <=6 
							then 1 
							else 2 
							end								as Nr_Semestre,
					   case when @Mes_Corrente <=6 
							then '1º Semestre'	 
							else '2º Semestre' 
							end								as Nm_Semestre,
					  CASE 
							WHEN @Mes_Corrente IN(1,2,3)    THEN 1 
							WHEN @Mes_Corrente IN(4,5,6)    THEN 2 
							WHEN @Mes_Corrente IN(7,8,9)    THEN 3 
							WHEN @Mes_Corrente IN(10,11,12) THEN 4 
							END								as Nr_Trimestre, 
						CASE 
						WHEN @Mes_Corrente IN(1,2,3)     THEN '1º Trimestre' 
						WHEN @Mes_Corrente IN(4,5,6)     THEN '2º Trimestre' 
						WHEN @Mes_Corrente IN(7,8,9)     THEN '3º Trimestre' 
						WHEN @Mes_Corrente IN(10,11,12)  THEN '4º Trimestre' 
						END									as Nm_Trimestre,
						CASE 
						WHEN (MONTH(@data)=12 AND DAY(@data) >=21) 
							OR MONTH(@data) IN(1,2)
							OR(MONTH(@data) =3 AND DAY(@data) <21) THEN 2 
						WHEN (MONTH(@data) =3 AND DAY(@data) >=21)
							OR MONTH(@data) IN(4,5)
							OR(MONTH(@data) =6 AND DAY(@data) <21) THEN 3 
						WHEN(MONTH(@data) =6 AND DAY(@data) >=21)
							OR MONTH(@data) IN(7,8)
							OR(MONTH(@data) =9 AND DAY(@data) <21) THEN 4
						WHEN(MONTH(@data) =9 AND DAY(@data) >=21)
							OR MONTH(@data) IN(10,11)
							OR(MONTH(@data) =12 AND DAY(@data) <21) THEN 1 
						END														as Nr_EstacaoAno,
						CASE 
							WHEN(MONTH(@data) =12 AND DAY(@data) >=21)
								OR MONTH(@data) IN(1,2)
								OR(MONTH(@data) =3 AND DAY(@data) <21)       THEN 'Verão' 
							WHEN(MONTH(@data) =3 AND DAY(@data) >=21)
								OR MONTH(@data) IN(4,5)
								OR(MONTH(@data) =6 AND DAY(@data) <21)       THEN 'Outono' 
							WHEN(MONTH(@data) =6 AND DAY(@data) >=21)
								OR MONTH(@data) IN(7,8)
								OR(MONTH(@data) =9 AND DAY(@data) <21)       THEN 'Inverno' 
							WHEN(MONTH(@data) =9 AND DAY(@data) >=21)
								OR MONTH(@data) IN(10,11)
								OR(MONTH(@data) =12 AND DAY(@data) <21)      THEN 'Primavera' 
							END													as Nm_EstacaoAno,
							CASE 
							WHEN @Mes_Corrente IN(1,2)   THEN 1 
							WHEN @Mes_Corrente IN(3,4)   THEN 2 
							WHEN @Mes_Corrente IN(5,6)   THEN 3 
							WHEN @Mes_Corrente IN(7,8)   THEN 4 
							WHEN @Mes_Corrente IN(9,10)  THEN 5 
							WHEN @Mes_Corrente IN(11,12) THEN 6 
							END													as Nr_Bimestre, 
							CASE 
							WHEN @Mes_Corrente IN(1,2)   THEN '1º Bimestre' 
							WHEN @Mes_Corrente IN(3,4)   THEN '2º Bimestre' 
							WHEN @Mes_Corrente IN(5,6)   THEN '3º Bimestre' 
							WHEN @Mes_Corrente IN(7,8)   THEN '4º Bimestre' 
							WHEN @Mes_Corrente IN(9,10)  THEN '5º Bimestre' 
							WHEN @Mes_Corrente IN(11,12) THEN '6º Bimestre' 
							END													as Nm_Bimestre, 
							MONTH(@data)										as Nr_Mes,
							DATENAME (m,@data)									as Nm_Mes,
							substring(DATENAME (m,@data), 1,3)					as Nm_MesAbreviado,
							datepart(week,@data)								as Nr_SemanaAno,
							'Semana '+  
							  right('0'+cast(datepart(week,@data)as varchar),2)	as Nm_SemanaAno,
							ceiling(day(@data)/7)+1								as Nr_SemanaMes,
							'Semana ' + 
									 cast(ceiling(day(@data)/7)+1 as varchar)	as Nm_SemanaMes,
							DAY(@data)											as Nr_Dia,
							datepart(Dw, @data)									as Nr_DiaSemana,
							DATENAME(weekday, @data)							as Nr_DiaSemana,
							DATENAME(dayofyear, @data)							as Nr_DiaAno,
							substring(DATENAME (m,@data), 1,3) + '-' + 
									  CAST(YEAR(@data) as varchar)				as Nr_MesAno, 
							(YEAR(@data)*100)+ Month(@data)						as Nr_ClassificacaoMesAno;
			
			set @MENS_ERRO = 'Proximo dia data';
			set @Data = dateadd(dd,1,@Data)
		 end 
	END TRY 
	BEGIN CATCH
		/* GERAMOS UMA EXCEÇÃO BASEADA NO ERRO ORIGINAL */
		set @MENS_ERRO = 'PS_DW_CARGA_CALENDARIO '  + @MENS_ERRO + ' - ';
		RAISERROR(@MENS_ERRO , 16, 1)		
	END CATCH
end
GO
