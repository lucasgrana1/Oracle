--# DIMINUIR TAMANHO DATAFILE (RESIZE PRA BAIXO) -- marca dagua
COL TABLESPACE FOR A30
COL FILE_NAME  FOR A60
COL MENOR_MB   FOR 9,999,990
COL ATUAL_MB   FOR 9,999,990
COL GANHO_MB   FOR 9,999,990
COL CMD        FOR A237
BREAK ON REPORT
COMP SUM LABEL 'GANHO_TOTAL' OF GANHO_MB ON REPORT
DEFINE TABLESPACE = "SAPIENS_DATA"
select x.tablespace, x.file_id, x.file_name, x.menor_mb, x.atual_mb, x.ganho_mb
from (select a.tablespace_name as TABLESPACE, a.file_id, a.file_name
           , round((nvl(c.hwm,1)*b.block_size)/1024/1024, 2) as MENOR_MB
           , round(a.blocks*b.block_size/1024/1024, 2)       as ATUAL_MB
           , round(((a.blocks*b.block_size/1024/1024) -
               ((nvl(c.hwm,1)*b.block_size)/1024/1024)), 2) as GANHO_MB
       from  dba_data_files  A
           , dba_tablespaces B
           , (select e.file_id, max(e.block_id+e.blocks-1) as HWM
              from   dba_extents E where e.tablespace_name in ('&TABLESPACE')
              group by e.file_id) C
      where a.file_id = c.file_id(+) and a.tablespace_name = b.tablespace_name
      and a.tablespace_name in ('&TABLESPACE')
) X where x.ganho_mb > 0 ;

select 'ALTER DATABASE DATAFILE ''' || x.file_name || ''' RESIZE ' || round((nvl(x.HWM,1)*x.block_size)/1024/1024, 2) || 'M ;' as CMD
from (select a.file_id, a.file_name, b.block_size, c.hwm
           , round(((a.blocks*b.block_size) - (nvl(c.hwm,1)*b.block_size))/1024/1024, 2) as GANHO_MB
      from   dba_data_files  A
           , dba_tablespaces B
           , (select e.file_id, max(e.block_id+e.blocks-1) as HWM
              from   dba_extents E where e.tablespace_name in ('&TABLESPACE')
              group by e.file_id) C
      where a.file_id = c.file_id(+) and a.tablespace_name = b.tablespace_name
      and a.tablespace_name in ('&TABLESPACE')
) X where x.ganho_mb > 1 order by 1 ;


--TABLESPACES SIMPLES
SET PAGES 1000 LINES 169 LONG 10000;
COL TABLESPACE_NAME FOR A15;
COL STATUS FOR A6;
COL CONTENTS FOR A9;
COL BIGFILE FOR A7;
SELECT TABLESPACE_NAME,
STATUS,
CONTENTS,
BIGFILE FROM DBA_TABLESPACES;


--#LISTAR TABLESPACES SIMPLES
SET PAGES 1000 LINES 190 LONG 10000;
COL TABLESPACE_NAME FOR A15;
COL STATUS FOR A6;
COL BLOCK_SIZE FOR 9999999999;
COL CONTENTS FOR A9;
COL GERENCIADO FOR A10;
COL TIPO_ALOCACAO FOR A13;
select tablespace_name,
block_size,
status,
contents,
extent_management as gerenciado,
allocation_type as tipo_alocacao from dba_tablespaces;


--#LISTAR DATAFILES SIMPLES
SET PAGES 1000 LINES 190 LONG 10000;
COL NAME FOR A45;
COL FILE# FOR 99;
COL BLOCK_SIZE FOR 9999;
COL BYTES FOR 9999999999;
COL STATUS FOR A6;
COL CREATION_TIME FOR A13;
COL LAST_TIME FOR A16;
COL ENABLED FOR A10;
select name, file#,
block_size, bytes,
status,
creation_time,
to_char(last_time,'yyyy/mm/dd hh24:mi') as last_time,
enabled from v$datafile;


--#JOIN LISTAR DATAFILES SIMPLES
SET PAGES 1000 LINES 190 LONG 10000;
COL TABLESPACE FOR A15;
COL FILE_NAME FOR A45;
COL BLOCK_SIZE FOR 9999;
COL BYTES FOR 9999999999;
COL STATUS FOR A6;
COL CONTENTS FOR A10;
select dt.tablespace_name,
df.file_name,
dt.block_size,
df.bytes,
dt.status,
dt.contents from dba_tablespaces dt inner join dba_data_files df on dt.tablespace_name = df.tablespace_name;



--#MOSTRAR O QUE ESTÁ OCUPANDO A TABLESPACE SYSAUX
set lines 190 pages 10000 long 100000
col occupant_name for a30
col owner for a20
col usado '999,999,990'
select occupant_name, schema_name as owner, (space_usage_kbytes/1024) as usado
from v$sysaux_occupants;



--#COLOCAR A TABLESPACE EM BEGIN BACKUP (FROZEN)
ALTER TABLESPACE tbs_01 BEGIN BACKUP;



--#RETIRAR A TABLESPACE DE BEGIN BACKUP PARA CONTINUAR
ALTER TABLESPACE tbs_01 END BACKUP;



--# VERIFICAR QUOTAS DAS TABLESPACES DO USUARIO
-----------------------------------------------
SET LINES 169 PAGES 1000 LONG 100000 FEED 1 ECHO ON TI ON TIMI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
COL DROPPED     FOR A7
COL USUARIO     FOR A30
COL TABLESPACE  FOR A30
COL USADO_MB    FOR 9,999,990
COL QUOTA_MB    FOR 9,999,990
COL USADO_PCT   FOR 9990.00  HEA "USADO_%"
COL LIVRE_PCT   FOR 9990.00  HEA "LIVRE_%"
select q.username as USUARIO, q.tablespace_name as TABLESPACE, ceil(q.bytes/1024/1024) as USADO_MB
    , case q.max_bytes when -1 then -1 else ceil(q.max_bytes/1024/1024) end as QUOTA_MB
    , case q.max_bytes when -1 then -1 else round((q.bytes/q.max_bytes)*100, 2) end as USADO_PCT
    , case q.max_bytes when -1 then -1 else 100-round((q.bytes/q.max_bytes)*100, 2) end as LIVRE_PCT, q.dropped
from  dba_ts_quotas Q
where q.username in ('USUARIO')
  and q.tablespace_name in ('TABLESPACE')
order by 1, 2 ;


--# QUOTAS E UTILIZAÇÃO DA TABLESPACE
SET pages 1000 LINES 190 LONG 10000
col username format a25
col usado_mb format '999,999,990'
col limite_mb format '999,999,990'
col perc_usado format '990.00'
SELECT username, tablespace_name,
 (max_bytes/1024/1024) AS limite_mb,
 (bytes/1024/1024) AS usado_mb,
 round(CASE WHEN max_bytes > 0 THEN bytes*1000/max_bytes ELSE 0 END,2) AS perc_usado
FROM dba_ts_quotas
--where username in ('NOME_OWNER')
ORDER BY perc_usado DESC, username, tablespace_name;


--#DATAFILES DA TABLESPACE
SET PAGES 1000 LINES 169 LONG 10000
COL TABLESPACE FOR A15
COL CONTEUDO FOR A10
COL FILE_NAME FOR A60
COL TAMANHO_MB FOR 999990.00
COL AUTOEXTEND FOR A10
COL INCREMENTO_MB FOR 999990.00
COL MAX_MB FOR 999990.00
COL BIGFILE FOR A7
select dt.tablespace_name,
dt.contents as conteudo,
df.file_name,round(df.bytes / 1024 / 1024,2) as tamanho_mb,
df.autoextensible as autoextend,
round (df.increment_by*dt.block_size / 1024 / 1024,2) as incremento_mb,
round(df.maxbytes / 1024 / 1024,2) as max_mb,
dt.bigfile
from dba_data_files df
inner join dba_tablespaces dt on dt.tablespace_name = df.tablespace_name
where dt.tablespace_name = 'RELATORIOS';


--DATAFILES TABLESPACE TEMP
SET PAGES 1000 LINES 169 LONG 10000
COL TABLESPACE FOR A15
COL CONTEUDO FOR A10
COL FILE_NAME FOR A45
COL TAMANHO_MB FOR 999990.00
COL AUTOEXTEND FOR A10
COL MAX_MB FOR 999990.00
COL BIGFILE FOR A7
select dt.tablespace_name,
dt.contents as conteudo,
tf.file_name,
round(tf.bytes / 1024 / 1024,2) as tamanho_mb,
tf.autoextensible as autoextend,
round(tf.maxbytes /1024 / 1024) as max_mb,
dt.bigfile
from dba_temp_files tf
inner join dba_tablespaces dt on dt.tablespace_name = tf.tablespace_name
WHERE dt.tablespace_name LIKE 'TEMP%';



--RESIZE DATAFILE
alter database datafile '+DGDADOS/kprd11/datafile/sapiens_data_03.dbf' resize 31G;



--#REMOVER AUTOEXTEND DE DATAFILE
alter database datafile '/oraint/oradata/dat/oicprd01.dbf' autoextend off;



--#RESIZE DE TABLESPACE BIGFILE
alter tablespace teste resize 2G;



-- ADICIONAR DATAFILE
alter tablespace SYSTEXTIL_INDEX add datafile '/cnf_br_dados/cnfbr/systextil_index12.dbf' size 16G;



--CRIAR DATAFILE COM AUTOEXTEND
alter tablespace SYSTEXTIL_DADOS add datafile '/hmg-orabases-4800/oradata/dmlhbr/devmlhbr/systextil_dados_08.dbf' size 15G autoextend on next 64M maxsize 30G;



--# ALTERAR DATAFILE PARA AUTOEXTEND
alter database datafile '/caminho/completo/DATAFILE.dbf' autoextend on next 64M maxsize 31G ;





----------------------
--# RENOMEAR DATAFILE
----------------------

shutdown immediate;


startup mount;


# alter database rename file '/ora01/oradata/rvtst/urenauxviewtreino_01.dbf' to '/ora02/oradata/rvtst/urenauxviewtreino_01.dbf' ;


alter database open;





------------------------------------
--#AUMENTAR THRESHOLD TABLESPACE --
------------------------------------



--# CONSULTA DOS THRESHOLDS
select * from luzadm.luz_tablespaces order by 1 ;



--#AJUSTAR THRESHOLD
update luzadm.luz_tablespaces
set    alerta  = 99999999,
       critico = 99999999
where  nome    = 'TABLESPACE' ;



--#CRIAR THRESHOLD
insert into luzadm.luz_tablespaces (nome, alerta, critico)
values ('TS_AUDIT', 90, 95) ;



--# VER TABLESPACES ONDE OWNER TEM OBJETOS / QUAIS OWNERS TEM OBJETOS NA TABLESPACE
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL TABLESPACE  FOR A30
COL OWNER       FOR A30
COL SIZE_MB     FOR 999,990
select s.owner as OWNER, s.tablespace_name as TABLESPACE, ceil(sum(s.bytes/1024/1024)) as SIZE_MB
from  dba_segments S
where s.owner           in ('PROCESSPRD','PROCESSLOG')
--or s.tablespace_name in ('TABLESPACE')
group by s.owner, s.tablespace_name
order by 1, 2 ;



--# ATIVAR A OPCAO TABLESPACE EM FORCE LOGGIN
ALTER DATABASE force logging;
SET pages 1000
SET LINES 190
SELECT 'alter tablespace '||TABLESPACE_NAME||' force logging;'
FROM dba_tablespaces
WHERE contents IN ('PERMANENT')
AND force_logging = 'NO'
ORDER BY 1;



--# CRIAR TABLESPACE SEM AUTOEXTEND
CREATE TABLESPACE NOME_TABLESPACE
LOGGING DATAFILE 'u01/apporacle/oradata/RHINO/ts_lucasg01.dbf' -- EXEMPLO-- -- LOCALIZAÇAO VAI MUDAR--
SIZE 100M AUTOEXTEND OFF;



--# CRIAR TABLESPACE REUTILIZANDO UM DATAFILE

CREATE TABLESPACE TEST DATAFILE '/u01/oradata/DB01/ts_teste1.dbf' REUSE;




--# ALTERAR O DATABASE PARA FORCE LOGGING
ALTER DATABASE FORCE LOGGING;



--# ALTERAR A TABLESPACE PARA FORCE LOGGING
ALTER TABLESPACE tablespace_name FORCE LOGGING;




--# CRIAR TABLESPACE COM AUTOEXTEND
CREATE TABLESPACE NOME_TABLESPACE
LOGGING DATAFILE 'caminho/completo/DATAFILE.dbf'
SIZE 50M
autoextend on
next 100M
maxsize 31G extent management local segment space management auto;




--#CRIAR UMA TABLESPACE UNDO:
CREATE UNDO TABLESPACE undo1
DATAFILE '/u01/oradata/undodb01.dbf'
SIZE 20m;



--#PARA ALTERNANCIA DINAMICA ENTRE TABLESPACES UNDO**
ALTER SYSTEM SET UNDO_TABLESPACE=UNDOTBS2;



--#ELIMINA UM TABLESPACE UNDO:
DROP TABLESPACE UNDOTBS1;



--# ELIMINAR TABLESPACES E DATAFILES
drop tablespace TABLESPACE including contents and datafiles



--#CRIANDO TABLESPACE BIGFILE
create bigfile tablespace TESTE
datafile '/ora01/oradata/DB04/teste.dbf' size 1G;




--# MOVIMENTAR INDICES PARA OUTRA TABLESPACE
ALTER INDEX PEMAZA.TBDEVOLMOTDEF_INDEX01 rebuild tablespace I_PEMAZA online;



--# MOVIMENTAR TABELA PARA OUTRA TABLESPACE
ALTER TABLE TABELA_TESTE MOVE TABLESPACE TESTE;





--# LISTAR TABLESPACES (DE DENTRO DO CDB)
set line 200 pages 999
column name for a10
column tablespace_name for a20
column "MAXSIZE (MB)" format 9,999,990.00
column "ALLOC (MB)" format 9,999,990.00
column "USED (MB)" format 9,999,990.00
column "PERC_USED" format 99.00
select a.con_id,c.name,b.tablespace_name,a.bytes_alloc/(10241024) "MAXSIZE (MB)", nvl(a.physical_bytes,0)/(1024*1024) "ALLOC (MB)" ,nvl(b.tot_used,0)/(1024*1024) "USED (MB)" ,(nvl(b.tot_used,0)/a.bytes_alloc)/100 "PERC_USED"
from
(select con_id,tablespace_name, sum(bytes) physical_bytes,sum(decode(autoextensible,'NO',bytes,'YES',maxbytes)) bytes_alloc
from cdb_data_files group by con_id,tablespace_name ) a,
(select con_id,tablespace_name, sum(bytes) tot_used from cdb_segments group by con_id,tablespace_name ) b,
(select name,con_id from v$containers) c
where a.con_id= b.con_id and a.con_id = c.con_id and a.tablespace_name = b.tablespace_name (+)
order by 1,3;
