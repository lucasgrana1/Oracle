--# BACKUP FISICO (RMAN FULL + ARCHIVELOG)
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL S_REC_ID     FOR 999999      HEA "SESSION|REC_ID"
COL S_STAMP      FOR 9999999999  HEA "SESSION|STAMP"
COL LVL          FOR 999         HEA "LvL"
COL INPUT_TYPE   FOR A11         HEA "INPUT_TYPE"
COL INPUT_TYPE_  FOR A11         HEA "INPUT_TYPE_"
COL DEVICE       FOR A9          HEA "DEVICE"
COL STATUS       FOR A11 TRU     HEA "STATUS"
COL DOW          FOR A4          HEA "DoW"
COL START_TIME   FOR A20         HEA "START_TIME"
COL END_TIME     FOR A10         HEA "END|TIME"
COL TTAKEN       FOR A9          HEA "TIME|TAKEN"
COL SIZE_MB      FOR 9,999,990   HEA "SIZE_MB"
COL OUT_PSEC     FOR 999.00      HEA "OUTPUT|MB/s"
select j.session_recid as S_REC_ID, j.session_stamp as S_STAMP, nvl(s.incremental_level,0) as LVL, j.input_type
    , case when j.input_type in ('DB INCR','DB INCREMENTAL') and nvl(s.incremental_level,0)  = 0 then 'DB FULL' else
      case when j.input_type in ('DB INCR','DB INCREMENTAL') and nvl(s.incremental_level,0) != 0 then 'DB INCR' else
        j.input_type end end as INPUT_TYPE_, s.device_type as DEVICE, j.status
    , decode(to_char(j.start_time,'d'),1,'SUN',2,'MON',3,'TUE',4,'WED',5,'THU',6,'FRI',7,'SAT') as DOW
    , to_char(j.start_time,'YYYY-MM-DD HH24:MI:SS') as START_TIME, to_char(j.end_time,'HH24:MI:SS') as END_TIME
    , j.time_taken_display as TTAKEN, ceil(sum(p.bytes)/1024/1024) as SIZE_MB
--    , round(j.output_bytes_per_sec/1024/1024,2) as OUT_PSEC
from v$rman_backup_job_details J
left join v$backup_set_details S on j.session_recid = s.session_recid
left join v$backup_piece_details P on p.set_stamp = s.set_stamp and p.set_count = s.set_count
left join v$rman_status RS
  on p.rman_status_recid = rs.recid
 and p.rman_status_stamp = rs.stamp
where j.start_time >= sysdate-1
and j.input_type in ('DB FULL', 'DB INCR','ARCHIVELOG')
group by j.session_recid, j.session_stamp, j.status, j.input_type, nvl(s.incremental_level,0)
    , j.time_taken_display, to_char(j.start_time, 'd'), to_char(j.start_time, 'YYYY-MM-DD HH24:MI:SS')
    , to_char(j.end_time, 'HH24:MI:SS'), s.device_type, j.elapsed_seconds, j.output_bytes_per_sec
order by j.session_recid ;





--# CONSULTA BACKUP RMAN SIMPLES
SET LINES 169 PAGES 1000 LONG 100000
COL SESSAO FOR 999999
COL INPUT_TYPE FOR A20
COL DEVICE_TYPE FOR A16
COL STATUS FOR A23
COL DIA FOR A4
COL HORA_INICIAL FOR A20
COL FINAL FOR A20
COL DURACAO FOR A9
COL MINUTOS FOR 999999
COL SIZE_MB FOR 9,999,990
select bjd.session_key as SESSAO, bjd.input_type, bjd.output_device_type as DEVICE_TYPE, bjd.status,
 decode(to_char(bjd.start_time,'d'),1,'DOM',2,'SEG',3,'TER',4,'QUA',5,'QUI',6,'SEX',7,'SAB') as DIA,
 to_char(bjd.start_time,'yyyy/mm/dd hh24:mi:ss') as HORA_INICIAL,
 to_char(bjd.end_time,'yyyy/mm/dd hh24:mi:ss') as FINAL,
  bjd.time_taken_display as DURACAO,
  --round(bjd.elapsed_seconds/60,0) as MINUTOS,
 round(bjd.output_bytes/1024/1024,0) as SIZE_MB
from v$rman_backup_job_details bjd
where bjd.start_time >= sysdate-1
and bjd.input_type in ('DB FULL', 'DB INCR','ARCHIVELOG')
order by bjd.session_key;





--# CONFERIR PERCENTUAL DE EXECUÇÃO DO RMAN
SELECT
sid, start_time,
totalwork, sofar,
(sofar/totalwork) * 100 pct_done
FROM v$session_longops
WHERE totalwork > sofar
AND opname NOT LIKE '%aggregate%'
AND opname LIKE 'RMAN%';





--# VERIFICAR ERROS RMAN
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
select output from gv$rman_output where session_recid = 75962
order by recid ;




--# VER DIRETORIOS DOS ARCHIVES
-------------------------------
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
COL ID         FOR 99
COL DESTINO    FOR A20
COL DIRETORIO  FOR A25
COL ERROR      FOR A48
COL DATABASE   FOR A15
COL TIMEOUT    FOR 999
select ad.dest_id as ID, ad.dest_name as DESTINO, ad.destination as DIRETORIO, substr(ad.target,1,10) as TARGET
    , ad.status, ad.archiver, ad.transmit_mode, ad.db_unique_name as DATABASE, ad.net_timeout as TIMEOUT, ad.error
from  v$archive_dest AD where ad.status != 'INACTIVE' ;




--# VER STATUS DOS DATAFILES (BEGIN BACKUP) STATUS= ATIVO SIGNIFICA QUE ESTA EM BEGIN BACKUP
------------------------------------------------------------------------------------------------
COL FILE_NAME  FOR A60
COL STATUS     FOR A11
COL CHANGE#    FOR 999999999999999
select b.file#, f.tablespace_name, f.file_name, b.status, b.change#, to_char(b.time, 'YYYY-MM-DD HH24:MI:SS') as ALTERACAO
from v$backup B, dba_data_files F
where b.file# = f.file_id
order by ALTERACAO ;




--# VER EM QUAL ARQUIVO ESTÁ O BACKUP DE UM DETERMINADO DATAFILE
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL S_REC_ID     FOR 999999      HEA "SESSION|REC_ID"
COL S_STAMP      FOR 9999999999  HEA "SESSION|STAMP"
COL BS_KEY       FOR 999999      HEA "BKP_SET|NUMBER"
COL LVL          FOR 999         HEA "LvL"
COL BS_TYPE      FOR A13         HEA "BKP_SET_TYPE"
COL INPUT_TYPE   FOR A11         HEA "INPUT_TYPE"
COL INPUT_TYPE_  FOR A11         HEA "INPUT_TYPE_"
COL DEVICE       FOR A09         HEA "DEVICE"
COL STATUS       FOR A10         HEA "STATUS"
COL DOW          FOR A04         HEA "DOW"
COL START_TIME   FOR A20         HEA "START_TIME"
COL END_TIME     FOR A09         HEA "END|TIME"
COL TTAKEN       FOR A09         HEA "TIME|TAKEN"
COL TAG          FOR A23         HEA "TAG"
COL SIZE_MB      FOR 9,999,990   HEA "SIZE_MB"
COL OUT_PSEC     FOR 999.00      HEA "OUTPUT|MB/S"
COL BKP_FILE     FOR A75         HEA "BACKUP_FILE_NAME|or DATAFILE_NAME"
select j.session_recid as S_REC_ID, j.session_stamp as S_STAMP, f.bs_key, nvl(s.incremental_level,0) as LVL
    , decode(s.backup_type,'L','ARCHIVELOG','D','DB FULL','I','DB INCR',s.backup_type) as INPUT_TYPE
    , s.device_type as DEVICE, decode(to_char(s.start_time,'D'),1,'SUN',2,'MON',3,'TUE',4,'WED',5,'THU',6,'FRI',7,'SAT') as DOW
    , to_char(j.start_time,'YYYY-MM-DD HH24:MI:SS') as START_TIME, to_char(j.end_time,'HH24:MI:SS') as END_TIME
    , s.time_taken_display as TTAKEN, nvl(f.tag,'  datafile in bkp') as TAG
    , ceil(case when (f.tag is null) then (select d.bytes/1024/1024 from v$datafile D where d.name = f.fname) else (f.bytes/1024/1024) end) AS SIZE_MB
    , case when (s.backup_type in ('D','I') and f.tag is not null) then (f.fname)
           when (s.backup_type in ('L') and f.tag is not null) then ('Thread# '||a.thread#||' - Sequence# '||a.sequence#)
           else ('  '||f.fname) end as BKP_FILE
from  v$rman_backup_job_details J
left join v$backup_set_details S on s.session_recid = j.session_recid and s.session_stamp = j.session_stamp
left join v$backup_files F on f.bs_key = s.bs_key
left join v$rman_status R on r.recid = j.session_recid and r.stamp = j.session_stamp
left join v$backup_archivelog_details A on a.session_recid = j.session_recid and a.btype_key = s.bs_key
where s.start_time >= (sysdate-1) and f.fname is not null
--  and f.tag is not null  -- comentar para listar datafiles no backup set
order by s.session_recid, f.bs_key, f.tag, BKP_FILE ;






--# VERIFICAR PEÇAS E SEQUENCIA DOS ARCHIVES
set pagesize 1000
set linesize 190
col sessao format 999999
col nivel format 9999
col device_type format a11
col input_type format a20
col input_type_calc format a15
col status format a20
col mb format 9999999
col minutos format 999999
col hora_inicial for a17
col final for a6
select bjd.session_key, bsd.bs_key, bjd.status, ad.sequence#,
 bsd.device_type,
 bjd.input_type,
 case when bjd.input_type in ('DB INCR','DB INCREMENTAL') and nvl(bsd.incremental_level,0) = 0 then 'DB FULL' else
  case when bjd.input_type in ('DB INCR','DB INCREMENTAL') and nvl(bsd.incremental_level,0) != 0 then 'INCREMENTAL' else bjd.input_type end
 end as input_type_calc,
 nvl(bsd.incremental_level,0) as nivel,
 decode(to_char(bjd.start_time,'d'),1,'DOM',2,'SEG',3,'TER',4,'QUA',5,'QUI',6,'SEX',7,'SAB') as dia,
 to_char(bjd.start_time,'yyyy/mm/dd hh24:mi') as hora_inicial,
 to_char(bjd.end_time,'hh24:mi') as final,
 round(sum(bpd.elapsed_seconds)/60,0) as minutos,
 sum(round(bpd.bytes/1024/1024,0)) as MB
from v$rman_backup_job_details bjd
 left join v$backup_set_details bsd
  on bjd.session_key = bsd.session_key
 left join v$backup_piece_details bpd
  on bpd.set_stamp = bsd.set_stamp
 and bpd.set_count = bsd.set_count
 left join v$rman_status rs
  on bpd.rman_status_recid = rs.recid
 and bpd.rman_status_stamp = rs.stamp
 left join v$backup_archivelog_details ad
  on bjd.session_key = ad.session_key
where bjd.start_time >= sysdate-10
--and bsd.bs_key= 100251 --peça do backup
--  and nvl(rs.operation,'BACKUP') = 'BACKUP'
--  and bjd.session_key = 87691
--  and not bjd.input_type in ('ARCHIVELOG')
group by bjd.session_key, bsd.bs_key, bjd.status, ad.sequence#, bjd.input_type, bsd.device_type, nvl(bsd.incremental_level,0),
 to_char(bjd.start_time,'d'), to_char(bjd.start_time,'yyyy/mm/dd hh24:mi'), to_char(bjd.end_time,'hh24:mi')
order by bjd.session_key, bjd.session_recid;





--# CONECTAR COM RMAN
RMAN target/


--# ATUALIZAR CATALOGO DO RMAN COM OS ARQUIVOS QUE HA NO DIRETORIO (incluir/excluir do banco)
CROSSCHECK BACKUP ;
CROSSCHECK BACKUPSET ;
CROSSCHECK COPY ;
CROSSCHECK ARCHIVELOG ALL ;
CROSSCHECK BACKUP OF SPFILE ;
CROSSCHECK BACKUP OF CONTROLFILE ;


--# REMOVER DO CATALOGO DO RMAN OS ARQUIVOS QUE NAO EXISTEM MAIS (remover do banco)
DELETE NOPROMPT OBSOLETE ;
DELETE NOPROMPT EXPIRED BACKUP ;
DELETE NOPROMPT EXPIRED COPY ;




--#COLOCAR A TABLESPACE EM BEGIN BACKUP (FROZEN)
ALTER TABLESPACE tbs_01 BEGIN BACKUP;




--#RETIRAR A TABLESPACE DE BEGIN BACKUP PARA CONTINUAR
ALTER TABLESPACE tbs_01 END BACKUP;




--#CASO NÃO FUNCIONAR OS COMANDOS ACIMA
alter database datafile NRO_DF end backup ;




--# SHOW PARAMETER LOG_ARCHIVE_FORMAT ;
Verificar o formato dos archives
detalhes em: https://docs.oracle.com/cd/E11882_01/backup.112/e10643/rcmsubcl010.htm#RCMRF195




--#ENTRAR COM O USUARIO RMAN
rman target/




--# MOSTRAR PARAMETRIZAÇÃO DO RMAN
show all;




-- VERIFICAR SE O BACKUP DE TAL ARCHIVE FOI EXECUTADO
list backup of archivelog logseq=271708;




--# LISTAR OS ARCHIVES
list backup of archivelog all




--#SE NECESSÁRIO EXCLUIR A LINHA DO BACKUP FULL
backup AS COMPRESSED BACKUPSET tag 'BackupArchivelogDiario' archivelog all delete input;




--# GERAR ARCHIVE (descarregar redo log)
alter system archive log current ; -- trava sesssao para gera todos os archive
alter system archive log all ;



--# Rotina backup RMAN

backup as compressed backupset tag 'BackupArchivelogDiario' archivelog like '/oraarch/prod/%' not backed up 1 times;
delete archivelog all backed up 1 times to device type DISK completed before 'sysdate-(4/24)';




-------------------------------------------------------------------------------------------------------------
--# SEMPRE QUE FORMOS CONFIGURAR O RMAN COM UMA JANELA DE RETENCAO > 14D DEVE-SE ALTERAR O PARAMETRO ABAIXO
-------------------------------------------------------------------------------------------------------------

alter system set control_file_record_keep_time = 20;

OBS: Deve sempre ficar com um tempo maior do que a retenção.
