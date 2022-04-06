--STATUS DOS SEGMENTOS DE UNDO
set pages 1000 lines 169 long 10000
col status format a10
select status,
 round(sum_bytes / (1024*1024), 0) as MB,
 round((sum_bytes / undo_size) * 100, 0) as PERC
 from (select status, sum(bytes) as sum_bytes
       from dba_undo_extents
       group by status),
(select sum(a.bytes) as undo_size
 from dba_tablespaces c
  join v$tablespace b
   on b.name = c.tablespace_name
  join v$datafile a
   on a.ts# = b.ts#
where c.contents = 'UNDO'
  and c.status = 'ONLINE');
