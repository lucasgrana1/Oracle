--# INFORMACOES UTEIS
908,800 linhas = 1,024.00 MB
 88,750 linhas = 100 MB

--# VER TAMANHO DA TABELA
COL SIZE_MB  FOR 999,990
SELECT SUM(BYTES)/1024/1024 AS SIZE_MB FROM DBA_SEGMENTS WHERE SEGMENT_NAME = 'TABELA' ;

--# CRIAR A TABELA
------------------
CREATE TABLE LUCASM.DADOS (
    TEXTO VARCHAR2(4000)
) TABLESPACE TS_TESTES ;

--# ALIMENTAR A TABELA
----------------------
DECLARE
I INTEGER := 0 ;
BEGIN
    FOR I IN 1..908800 LOOP
        BEGIN
            INSERT INTO LUCASM.DADOS (TEXTO) VALUES ('LOREM IPSUM DOLOR SIT AMET, CONSECTETUR ADIPISCING ELIT. CURABITUR A TRISTIQUE QUAM. ETIAM CONSECTETUR SEM NON DUI RUTRUM CONDIMENTUM. SED FELIS ORCI, FRINGILLA EGET TINCIDUNT A, TEMPUS EGET NIBH. UT SCELERISQUE SEM SED TURPIS ULTRICES, ID MATTIS MI SODALES. INTEGER VITAE LIBERO NEC METUS FRINGILLA SAGITTIS. PRAESENT FAUCIBUS AUGUE A MAXIMUS SCELERISQUE. CURABITUR IN URNA SOLLICITUDIN, FEUGIAT MASSA QUIS, CURSUS NUNC. SED VITAE MOLLIS ENIM. ALIQUAM BIBENDUM RUTRUM HENDRERIT. SUSPENDISSE FINIBUS ULLAMCORPER MASSA, VEL LAOREET QUAM SUSCIPIT HENDRERIT. MORBI LOBORTIS, DOLOR AT ULTRICES HENDRERIT, PURUS DUI SOLLICITUDIN TURPIS, UT SAGITTIS NISI NUNC VITAE LEO. SUSPENDISSE VEHICULA CURSUS NISI, ID ACCUMSAN EX SAGITTIS SED. NULLAM A LECTUS SED SAPIEN FACILISIS TINCIDUNT. PELLENTESQUE QUIS EROS NEC NISI PULVINAR CONDIMENTUM. VESTIBULUM ID LACINIA FELIS. MORBI ID MI MOLLIS, PHARETRA TELLUS EGESTAS, ALIQUAM PURUS. MAURIS A DIAM UT NISI VEHICULA VOLUTPAT AC IN LIGULA. VESTIBULUM LAOREET EST SOLLICITUDIN ANTE MASSA NUNC') ;
            COMMIT ;
        END ;
    END LOOP ;
END ;
/
