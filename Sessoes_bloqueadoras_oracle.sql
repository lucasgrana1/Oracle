--# VERIFICAR O COMANDO SQL DA SESSAO
set pages 1000 lines 169 long 100000
COL COMANDO_SQL FOR A160
select x.sql_id, x.sql_fulltext as COMANDO_SQL from v$sql X where rownum = 1 and x.sql_id = 'bh2gq1z6zs8b8';



--# VERIFICAR ULTIMO E PENULTIMO COMANDO SQL DA SESSAO
DEFINE V_SID  = 722
DEFINE V_INST = 2
select 'Ultimo comando SQL executado pela sessao '||s.sid||':' as ULTIMO_CMD, x.sql_id, x.sql_fulltext as COMANDO_SQL
from v$sql X, gv$session S where x.sql_id=s.sql_id and s.sid = &V_SID and s.inst_id = &V_INST and rownum = 1 union all
select 'Penultimo comando SQL executado pela sessao '||s.sid||':' as ULTIMO_CMD, x.sql_id, x.sql_fulltext as COMANDO_SQL
from v$sql X, gv$session S where x.sql_id=s.prev_sql_id and s.sid = &V_SID and s.inst_id = &V_INST and rownum = 1 ;



--#VERIFICAR AS TABELAS BLOQUEADAS - COMPLETO
set pages 1000 lines 169 long 10000
COL OS_PID         FOR 999999
COL INST           FOR 999
COL SID_SESSAO     FOR A12
COL STATUS         FOR A7
COL OWNER          FOR A15
COL USUARIO        FOR A20
COL ESTACAO        FOR A25
COL TABELAS        FOR A35 HEA "TABELA_BLOQUEADA"
COL MODO_BLOQUEIO  FOR A20
COL LOGON          FOR A20
select s.inst_id as INST, l.session_id||','||s.serial# as SID_SESSAO, to_number(p.spid) as OS_PID
    , decode(s.status, 'ACTIVE', 'ATIVA', 'INACTIVE', 'INATIVA', s.status) as STATUS
    , substr(l.oracle_username,1,100)           as OWNER
    , substr(l.os_user_name,1,100)              as USUARIO
    , substr(s.machine,1,100)                   as ESTACAO
    , substr(o.owner||'.'||o.object_name,1,100) as TABELAS
    , decode(l.locked_mode, 1,'NO LOCK', 2,'(SS) Row Share', 3,'(SX) Row Exclusive', 4,'(S) Share',
        5,'(SSX) Share Row Exc', 6,'Exclusive', null) as MODO_BLOQUEIO, s.sql_id
--    , to_char(s.logon_time,'YYYY-MM-DD HH24:MI:SS') as LOGON
--select 'alter system kill session '''||l.session_id||','||s.SERIAL#||',@'||s.inst_id||''' immediate;' as comando
from  gv$locked_object L
inner join dba_objects O on o.object_id = l.object_id
inner join gv$session S on s.inst_id = l.inst_id and s.sid = l.session_id
inner join v$process P on p.addr = s.paddr
--where l.session_id = 596
--  and l.inst_id = 99999999
--  and o.owner       in ('OWNER')
  where o.object_name in ('EMPR_013')
order by 1 ;



--#CONTAGEM DE OBJETOS BLOQUEADOS
---------------------------------------
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
DEFINE V_SESSAO = 9999
DEFINE V_INST = 1
COL QTDE  NEW_V QTDE
select count(*) as QTDE from gv$locked_object L inner join dba_objects O on o.object_id = l.object_id where l.session_id = &V_SESSAO and l.inst_id = &V_INST ;
COL TABELAS  FOR A50  HEA "Ha &QTDE tabelas bloqueadas pela sessao &V_SESSAO:"
select o.owner||'.'||o.object_name as TABELAS from gv$locked_object L inner join dba_objects O on o.object_id = l.object_id
where l.session_id = &V_SESSAO and l.inst_id = &V_INST order by TABELAS ;




--# VERIFICAR AS TABELAS BLOQUEADAS - SIMPLES
set pages 1000 lines 190 long 10000
COL TABELAS  FOR A50  HEA "Tabelas bloqueadas pela sessão:"
select substr(o.owner||'.'||o.object_name,1,100) as TABELAS
from gv$locked_object L
inner join dba_objects O on o.object_id = l.object_id
inner join gv$session S on s.inst_id = l.inst_id and s.sid = l.session_id
inner join v$process P on p.addr = s.paddr
where l.session_id =2002
--and l.inst_id = 2
order by TABELAS ;




--# VER SESSOES BLOQUEADORAS
set pages 1000 lines 169 long 10000
COL OS_PID                 FOR 999999
COL BLK                    FOR A1
COL SID_SESSAO             FOR A13
COL BLOQ_POR               FOR A10
COL STATUS                 FOR A7
COL LOGON                  FOR A17
COL TEMPO                  FOR A11 TRU
COL EVENTO                 FOR A18 TRU
COL SQL_ID                 FOR A14
COL OWNER_USUARIO_ESTACAO  FOR A40
COL PROGRAMA_MODULO_ACAO   FOR A37
select decode(l.request, 0, 'X', '-') as BLK
    , s.inst_id||','||s.sid||','||s.serial# as SID_SESSAO
    , to_number(p.spid) as OS_PID, s.blocking_instance||','||s.blocking_session as BLOQ_POR
    , decode(s.status, 'ACTIVE', 'ATIVA', 'INACTIVE', 'INATIVA', s.status) as STATUS
--    , to_char(s.logon_time, 'YYYY-MM-DD HH24:MI') as LOGON
    , substr(decode(trunc(s.seconds_in_wait/86400), 0, '', to_char(trunc(s.seconds_in_wait/86400), '99')||'d ')||
        to_char(to_date(mod(s.seconds_in_wait, 86400), 'sssss'),'HH24"h "MI"m "SS"s"'),1,20) as TEMPO
    , substr(s.username,1,100)||','||substr(s.osuser,1,100)||','||substr(s.machine,1,100)||','||
        substr(s.client_info,1,100) as OWNER_USUARIO_ESTACAO
    , substr(s.program,1,100)||case when s.program != s.module then ','||substr(s.module,1,100)
        else '' end ||','||substr(s.action,1,100) as PROGRAMA_MODULO_ACAO
    , decode(s.event, 'SQL*Net message from client','SQL*Msg fr client','SQL*Net message to client','SQL*Msg TO client'
        , 'SQL*Net more data from client','SQL+Data fr client', 'SQL*Net more data to client','SQL+Data TO client'
        , s.event) as EVENTO, case when s.sql_id is null then '*'||s.prev_sql_id else s.sql_id end as SQL_ID
from  gv$lock L
left join gv$session S on s.inst_id = l.inst_id and s.sid = l.sid
left join gv$process P on p.inst_id = s.inst_id and p.addr = s.paddr
where (l.id1, l.id2, l.type) in (select l2.id1, l2.id2, l2.type from gv$lock L2 where l2.request > 0)
order by l.request asc, s.last_call_et desc, l.id1 ;




--# VISUALIZAR SESSAO BLOQUEADORA COM LOCK TREE
set pages 1000 lines 237 long 10000
COL OS_PID                 FOR 999999
COL STATUS                 FOR A7
COL SID_SESSAO             FOR A22
COL LOGON                  FOR A12
COL SQL_ID                 FOR A14
COL TEMPO                  FOR A12 TRU
COL EVENTO                 FOR A18 TRU
COL OWNER_USUARIO_ESTACAO  FOR A60
COL PROGRAMA_MODULO_ACAO   FOR A60
with a as (select level lev, connect_by_root C1 blocker, C1 lev1
    from (select inst_id||','||sid as C1, blocking_instance||','||blocking_session C2 from gv$session)
    connect by nocycle prior C2=C1 start with C2 in (
        select blocking_instance||','||blocking_session
        from gv$session where blocking_session is NOT null))
, b as (select distinct lev1 from a where (lev, blocker) in (select max(lev), blocker from a group by blocker))
select lpad(' ',2*(level-1))||sp.C1||','||sp.serial# as SID_SESSAO, to_number(sp.spid) as OS_PID
    , decode(sp.status, 'ACTIVE', 'ATIVA', 'INACTIVE', 'INATIVA', sp.status) as STATUS
    , to_char(to_date(mod(sp.seconds_in_wait, 86400),'sssss'),'HH24"h "MI"m "SS"s"') as TEMPO
    , substr(sp.username,1,100)||','||substr(sp.osuser,1,100)||','||substr(sp.machine,1,100)||','||
        substr(sp.client_info,1,100)||','||substr(sp.client_identifier,1,100) as OWNER_USUARIO_ESTACAO
    , case when sp.program like '%(J%)' then (
           case when sp.module is null then (select 'Job "'||j.job||' - '||j.schema_user||'"' from dba_jobs_running R
              inner join dba_jobs J on r.job = j.job inner join gv$session SI on si.sid = r.sid
              where si.inst_id||','||si.sid = sp.C1)
           else (select 'Sched. "'||sr.owner||'"."'||sr.job_name||'"'
              from  dba_scheduler_running_jobs SR
              inner join gv$session SI on si.sid = sr.session_id and si.inst_id = sr.running_instance
              where si.inst_id||','||si.sid = sp.C1) end)
      else substr(sp.program,1,100)||case when sp.program != sp.module then ','||substr(sp.module,1,100)
           else '' end ||','||substr(sp.action,1,100) end as PROGRAMA_MODULO_ACAO
    , decode(sp.event, 'SQL*Net message from client','SQL*Msg fr client','SQL*Net message to client','SQL*Msg 2 client'
        , 'SQL*Net more data from client','SQL+Data fr client', 'SQL*Net more data to client','SQL+Data 2 client'
        , sp.event) as EVENTO, case when sp.sql_id is null then '*'||sp.prev_sql_id else sp.sql_id end as SQL_ID
from (select s.inst_id||','||s.sid as C1, s.serial#, p.spid, s.status, s.seconds_in_wait
      , s.username, s.osuser, s.machine, s.client_identifier,s.client_info, s.program, s.module, s.action
      , s.logon_time, s.event, s.sql_id, s.prev_sql_id, s.blocking_instance||','||s.blocking_session as C2
      from gv$session S left outer join gv$process P on p.inst_id = s.inst_id and p.addr = s.paddr) SP
connect by nocycle prior C1=C2
start with C1 in (select lev1 from b)
order siblings by tempo desc ;









--# SESSÕES BLOQUEADORAS SIMPLES
col "Sessao" FOR a45
SELECT DECODE(l.request, 0, 'Bloqueando: ', 'Bloqueado: ') || 'Inst-> ' || s.inst_id ||' Sid/Serial: '||l.sid ||'/'|| s.serial# "Sessao",
s.serial#,
substr(s.username,1,15) Username,
l.lmode,
seconds_in_wait
FROM GV$LOCK L, GV$SESSION S
WHERE (l.id1, l.id2, l.type) IN
(SELECT l2.id1, l2.id2, l2.type FROM GV$LOCK l2 WHERE l2.request > 0)
AND s.sid = l.sid
ORDER BY l.id1, l.request;








--MATAR A SESSÃO
alter system kill session '1682,25027' immediate;


--MATAR SESSÃO RAC
alter system kill session '1034,7167,@2' immediate;


--Sempre que identificar uma sessão com ID <100 para ver se não é um processo do banco que esta trazendo info errada:
ps -ef | grep OS_PID
