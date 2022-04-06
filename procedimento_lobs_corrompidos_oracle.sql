'---------------------------------
--# Procedimento lobs corrompidos
---------------------------------'

-> Exemplo de erro encontrado: ORA-01555: snapshot too old: rollback segment number with name "" too small


--# Avaliar campos LOB na tabela com problemas
DESC "SAPIENS"."USU_TE120IPD";


--# Criar uma estrutura simples para analisar os LOBs
DROP TABLE corrupt_lobs;

TRUNCATE TABLE corrupt_lobs;

CREATE TABLE corrupt_lobs (corrupt_rowid rowid, err_num NUMBER, tabela varchar2(50), coluna varchar2(50));




--# Executar em cada coluna LOB da tabela, substituindo as informacoes do SELECT
SET timing ON
DECLARE
error_1578 exception;
error_1555 exception;
error_22922 exception;
pragma exception_init(error_1578,-1578);
pragma exception_init(error_1555,-1555);
pragma exception_init(error_22922,-22922);
num NUMBER;
BEGIN
  FOR cursor_lob IN (SELECT rowid linha, 'USU_TE120IPD' AS tabela, 'campo_lob' AS coluna, DS_XMLCTE FROM SAPIENS.USU_TE120IPD) loop
  BEGIN
    num := dbms_lob.instr (cursor_lob.DS_XMLCTE, hextoraw('889911'));
  exception
    WHEN error_1578 THEN
      INSERT INTO corrupt_lobs VALUES (cursor_lob.linha, 1578, cursor_lob.tabela, cursor_lob.coluna);
      commit;
    WHEN error_1555 THEN
      INSERT INTO corrupt_lobs VALUES (cursor_lob.linha, 1555, cursor_lob.tabela, cursor_lob.coluna);
      commit;
    WHEN error_22922 THEN
      INSERT INTO corrupt_lobs VALUES (cursor_lob.linha, 22922, cursor_lob.tabela, cursor_lob.coluna);
      commit;
    END;
  END loop;
END;
/



--# Exibir registros corrompidos
SET pages 1000
SET LINES 190
SELECT tabela, coluna, corrupt_rowid, err_num
FROM corrupt_lobs
ORDER BY 1,2,3;





--# Listar demais colunas da tabela, pra auxiliar o cliente a identificar o registro
SET pages 1000
SET LINES 190
col DT_EMISSAO FOR a30
col DS_RAZAOSOCIALEMIT FOR a45
SELECT rowid, ID_DOC, ID_EMPRESA, NU_NCT, DT_EMISSAO, DS_CNPJEMIT, ID_CHAVE, DS_RAZAOSOCIALEMIT--, campo_lob
FROM SAPIENS.USU_TE120IPD
WHERE rowid IN (SELECT corrupt_rowid FROM corrupt_lobs WHERE tabela = 'USU_TE120IPD' AND coluna = 'campo_lob');




--# Limpar a coluna LOB para evitar erros na consulta/backup
UPDATE SAPIENS.USU_TE120IPD
SET campo_lob = EMPTY_CLOB()
WHERE ROWID IN ('AASFcCAAHAAIjztAAH','AASFcCAAHAAIjztAAI','AASFcCAAHAAIjztAAG','AASFcCAAHAAIjztAAJ','AASFcCAAHAAIjztAAK');

--# Confirmar
commit;

--# Apagar tabela auxiliar
DROP TABLE corrupt_lobs;



---------------------------------------
--# Informativo ao cliente



Bom dia suporte,
tudo bem?

Esta noite ocorreu novamente falha no backup lógico desta tabela.
Após uma análise mais detalhada, foram identificadas 5 linhas com campo CLOB corrompido, provavelmente ocasionadas pela queda de energia na 3a.feira.
Toda vez que tentamos consultar o campo o banco gera um erro "ORA-01555: snapshot too old".
A informação contida neste campo está corrompida, e portanto atribuimos NULL neste campo para as 5 linhas para evitar a geração do erro nas consultas e no backup.

Owner:  SAPIENS
Tabela: USU_TE120IPD
Coluna: CAMPO_LOB

Abaixo segue as 5 Linhas com problema, pra ajudar você a identificá-las no sistema e deixar registrado que o campo CAMPO_LOB foi atribuído com NULL:

ROWID                  ID_DOC ID_EMPRESA     NU_NCT DT_EMISSAO                     DS_CNPJEMIT    ID_CHAVE                                     DS_RAZAOSOCIALEMIT
------------------ ---------- ---------- ---------- ------------------------------ -------------- -------------------------------------------- ---------------------------------------------
AASFcCAAHAAIjztAAH     170303         22    8695553 27-JUL-21 09.00.32.000000 PM   48740351002109 35210748740351002109570000086955531419595552 BRASPRESS TRANSPORTES URGENTES LTDA
AASFcCAAHAAIjztAAI     170304         22    1193353 27-JUL-21 08.57.16.000000 PM   48740351007097 50210748740351007097570000011933531760452175 BRASPRESS TRANSPORTES URGENTES LTDA
AASFcCAAHAAIjztAAG     170302         22    8695549 27-JUL-21 09.00.21.000000 PM   48740351002109 35210748740351002109570000086955491269597366 BRASPRESS TRANSPORTES URGENTES LTDA
AASFcCAAHAAIjztAAJ     170305         22     417039 27-JUL-21 08.34.16.000000 PM   95591723014330 50210795591723014330570000004170391827190291 TNT MERCURIO C E E EXS LTDA
AASFcCAAHAAIjztAAK     170306         22     417038 27-JUL-21 08.33.38.000000 PM   95591723014330 50210795591723014330570000004170381213184911 TNT MERCURIO C E E EXS LTDA

Atenciosamente, obrigado.
