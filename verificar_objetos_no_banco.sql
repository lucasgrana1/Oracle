--# VERIFICAR OBJETOS NO BANCO
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL OWNER        FOR A20
COL NOME_OBJETO  FOR A40
COL TIPO_OBJETO  FOR A20
COL STATUS       FOR A10
COL CRIADO       FOR A17
COL ULTIMO_DDL   FOR A17
COL TIMESTAMP    FOR A17
select o.owner, o.object_name AS NOME_OBJETO, o.object_type as TIPO_OBJETO, o.status
    , to_char(o.created,'YYYY-MM-DD HH24:MI') as CRIADO, to_char(o.last_ddl_time,'YYYY-MM-DD HH24:MI') as ULTIMO_DDL
    , to_char(to_date(o.timestamp,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI') as TIMESTAMP
--select count(*)
from  dba_objects O
where o.owner       in ('OWNER')
  and o.object_name in ('NOME_OBJETO')
  and o.object_type in ('TIPO_OBJETO')
--  and o.status != 'VALID'
--  and o.last_ddl_time >= sysdate-1
--  and o.created >= sysdate-1
--  and to_char(to_date(o.timestamp,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') !=
--      to_char(o.last_ddl_time,'YYYY-MM-DD HH24:MI:SS')
--group by o.owner, o.object_type
order by OWNER, TIPO_OBJETO, NOME_OBJETO ;
