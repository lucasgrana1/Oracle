--# CRIAR ARQUIVO 'usuarios.sh'
$ vi usuarios.sh
DIR=/home/oracle/suporte/20210707-HCL
ARQUIVO=${DIR}/usuarios.lst
$ORACLE_HOME/bin/sqlplus -s "/ as sysdba" << EOF
whenever sqlerror exit sql.sqlcode ;
SET LINES 169 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
spool ${ARQUIVO}
select 'CONN "' || upper(u.username) || '"/"' || lower(u.username) || '"' || chr(10) || 'SHOW USER' || chr(10) ||
       'CONN "' || upper(u.username) || '"/"' || upper(u.username) || '"' || chr(10) || 'SHOW USER'
from  dba_users U
where account_status = 'OPEN'
order by username ;
spool off ;
quit
EOF


--# PERMISSÃO EXECUTAVEL
chmod +x usuarios.sh


--# RODAR ARQUIVO 'usuarios.sh'
$ sh usuarios.sh

-- EDITAR O ARQUIVO 'usuarios.lst'
$ vi usuarios.lst

--# REMOVER CABECALHO

--# COLOCAR SLEEP A CADA 500 LINHAS

--# COLOCAR EXIT NA ULTIMA LINHA
exec dbms_lock.sleep(5) ;

exit

--# CRIAR ARQUIVO 'lista.sh'
$ vi lista.sh
sqlplus / as sysdba @usuarios.lst
exit


--# PERMISSÃO EXECUTAVEL
chmod +x lista.sh


--# RODAR O SCRIPT EM BACKGROUND E ACOMPANHAR EXECUCAO
$ nohup sh lista.sh &
$ tail -100f nohup.out

--# LISTA DOS USUARIOS QUE CONECTARAM COM SUCESSO
$ cat nohup.out | grep -v "USER is "'""' | grep "USER is "
