--# QUANDO HOUVER ALTERACOES QUE PRECISA REINICIAR A BASE SEMPRE FAZER BACKUP DO SPFILE EM UM PFILE
--  assim pode-se voltar como estava antes da alteracao e subir a base normalmente (rollback)
---------------------------------------------------------------------------------------------------


--# 1. criar um backup do SPFILE (diretório padrão $ORACLE_HOME/dbs):
create pfile from spfile ;


--# 2. alterar o parâmetro:
alter system set processes = 850 scope = both ;


--# 3. baixar a base:
shutdown immediate ;


-- 4. subir a base:
startup ;


--# LIBERAR PARA CLIENTE VALIDAR OS SISTEMAS.
ERRO ! ao subir ou cliente reporta problemas


--# *5. caso apresente erros ao subir a base, subir com PFILE que foi criado antes (pegar caminho/arquivo correto):
startup pfile=/oracle11/product/11.2/db_p4/dbs/init.ora


--# *6. criar um SPFILE a partir da memória (PFILE):
create spfile from memory ;


--# *7. baixar a base:
shutdown immediate ;


--# *8. subir a base normalmente, como estava antes (process=700):
startup ;
