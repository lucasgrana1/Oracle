--# SEGMENTOS RETIDOS
set pages 1000 lines 169 long 10000
COL TABLESPACE FOR A20
select
   srt.tablespace,
   srt.segfile#,
   srt.segblk#,
   srt.blocks,
   a.sid,
   a.serial#,
   a.username,
   a.osuser,
   a.status
from v$session a, v$sort_usage srt
where a.saddr = srt.session_addr
order by srt.tablespace, srt.segfile#, srt.segblk#, srt.blocks;




--# VERIFICAR USO DA TEMP POR SESSAO
set pages 1000 lines 169 long 10000
COL INST                   FOR 999
COL OS_PID                 FOR 999999
COL SID_SERIAL             FOR A13
COL STATUS                 FOR A7
COL EVENTO                 FOR A18 TRU
COL TABLESPACE             FOR A10
COL USADO_MB               FOR 999,990
COL OWNER_USUARIO_ESTACAO  FOR A45
COL PROGRAMA_MODULO_ACAO   FOR A35
select s.sid||','||s.serial#||',@'||s.inst_id as SID_SERIAL, to_number(p.spid) as OS_PID
    , decode(s.status, 'ACTIVE', 'ATIVA', 'INACTIVE', 'INATIVA', s.status) as STATUS
    , s.username||','||s.osuser||','||s.machine||','||s.client_info||','||s.client_identifier as OWNER_USUARIO_ESTACAO
    , s.program||case when s.module != s.program then ','||s.module else '' end ||','||s.action as PROGRAMA_MODULO_ACAO
    , decode(s.event, 'SQL*Net message from client','SQL*Msg FR client','SQL*Net message to client','SQL*Msg TO client'
        , 'SQL*Net more data from client','SQL+Data FR client', 'SQL*Net more data to client','SQL+Data TO client'
        , s.event) as EVENTO, case when s.sql_id is null then '*'||s.prev_sql_id else s.sql_id end as SQL_ID
    , round(((u.blocks*t.block_size)/1024/1024)) as USADO_MB, u.tablespace
from  gv$session S, gv$sort_usage U, gv$process P, dba_tablespaces T
where s.saddr(+) = u.session_addr
  and u.inst_id = s.inst_id
  and p.inst_id = s.inst_id
  and p.addr = s.paddr
  and t.tablespace_name = u.tablespace
  and ceil(((u.blocks*t.block_size)/1024/1024)) > 1  -- > 1 MB
--  and s.status = 'ACTIVE'
--  and s.sid = 99999999
order by u.blocks desc ;


--# VERIFICAR USO DA TEMP POR SESSAO
set pages 1000 lines 169 long 10000
COL SID_SERIAL_   FOR A169
COL OS_PID_       FOR A169
COL OWNER_        FOR A169
COL USUARIO_      FOR A169
COL ESTACAO_      FOR A169
COL CLIENT_ID_    FOR A169
COL CLIENT_INFO_  FOR A169
COL PROGRAMA_     FOR A169
COL MODULO_       FOR A169
COL ACAO_         FOR A169
COL EVENTO_       FOR A169
COL STATUS_       FOR A169
COL LOGON_        FOR A169
COL SQL_ID_       FOR A169
COL TABLESPACE_   FOR A169
COL USADO_MB_     FOR A169
select 'SID/Serial: '||s.sid||','||s.serial#||',@'||s.inst_id as SID_SERIAL_
,'OS_PID: '  ||p.spid              as OS_PID_
,'Owner: '   ||s.username          as OWNER_
,'Usuario: ' ||s.osuser            as USUARIO_
,'Estacao: ' ||s.machine           as ESTACAO_
,'Cliente: ' ||s.client_identifier as CLIENT_ID_
,'Info: '    ||s.client_info       as CLIENT_INFO_
,'Programa: '||s.program           as PROGRAMA_
,'Modulo: '  ||s.module            as MODULO_
,'Acao: '    ||s.action            as ACAO_
,'Evento: '  ||s.event             as EVENTO_
,'Status: '  ||decode(s.status, 'ACTIVE', 'Ativa', 'INACTIVE', 'Inativa', s.status)||
    ' por '  ||substr(decode(trunc(s.last_call_et/86400),0,'',to_char(trunc(s.last_call_et/86400),'9')||'d ')||
                 to_char(to_date(mod(s.last_call_et,86400),'sssss'),'HH24"h "MI"min "SS"s"'),1,20) as STATUS_
,'Logon: '   ||to_char(s.logon_time, 'DD/MM/YYYY "as" HH24":"MI"h"') as LOGON_
,'SQL_ID: '  ||case when s.sql_id is null then '*'||s.prev_sql_id else s.sql_id end as SQL_ID_
,'Tablespace: '||u.tablespace as TABLESPACE_
,'Utilizacao: '||to_char(ceil(((u.blocks*t.block_size)/1024/1024)), '999G999')|| ' MB' as USADO_MB_
from  gv$session S, gv$sort_usage U, gv$process P, dba_tablespaces T
where s.saddr(+) = u.session_addr
  and u.inst_id = s.inst_id
  and p.inst_id = s.inst_id
  and p.addr = s.paddr
  and t.tablespace_name = u.tablespace
  and ceil(((u.blocks*t.block_size)/1024/1024)) > 1  -- > 1 MB
order by u.blocks desc ;



--# USO DE TEMP3
set pages 1000
set lines 190
col inst format 9999
col sid_sessao format a13
col username format a20
col owner_usuario_maquina_programa format a75
col horario format a17
col module format a15
col status format a8
col tbs format a10
col action format a5
col mb_uso format 999999
select s.sid || ',' || s.serial# || ',@' || s.inst_id as sid_sessao,
 decode(status, 'ACTIVE', 'ATIV', 'INACTIVE', 'INAT', status) as status,
 replace(replace(s.username||','||s.osuser||','||s.machine||','||s.client_identifier||','||s.client_info||','||s.action||','||substr(s.program||case when s.program != s.module then ','||s.module else '' end,1,150),',,,',','),',,',',') as owner_usuario_maquina_programa,
 s.sql_id, u.tablespace as tbs, sum(round(((u.blocks*8192)/1024/1024))) as mb_uso
from gv$session s, gv$sort_usage u
where s.saddr (+) = u.session_addr
  and u.inst_id = s.inst_id
  and round(((u.blocks*8192)/1024/1024)) > 1
--and s.status = 'ACTIVE'
--and s.sid = 485
group by s.sid || ',' || s.serial# || ',@' || s.inst_id,
 decode(status, 'ACTIVE', 'ATIVA', 'INACTIVE', 'INATIVA', status),
 replace(replace(s.username||','||s.osuser||','||s.machine||','||s.client_identifier||','||s.client_info||','||s.action||','||substr(s.program||case when s.program != s.module then ','||s.module else '' end,1,150),',,,',','),',,',','),
 s.sql_id, u.tablespace
order by mb_uso desc;



--# VERIFICAR O COMANDO SQL DA SESSAO
set pages 1000 lines 169 long 10000
COL COMANDO_SQL FOR A160
select x.sql_id, x.sql_fulltext as COMANDO_SQL from v$sql X where rownum = 1 and x.sql_id = '9by8g05x753h3';
