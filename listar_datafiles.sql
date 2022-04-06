--LISTAR DATAFILES--
set pages 1000 lines 190 long 10000;
col name for a45;
col file# for 99;
col block_size for 9999;
col bytes for 9999999999;
col status for a6;
col creation_time for a13;
col last_time for a16;
col enabled for a10;
select name,
file#,
block_size,
bytes,
status,
creation_time,
--to_char(last_time,'yyyy/mm/dd hh24:mi') as last_time,
enabled from v$datafile;
