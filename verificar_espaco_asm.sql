--# VERIFICAR ESPACO NO ASM
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL NUM#         FOR 999
COL NOME         FOR A20
COL REDUNDANCIA  FOR A12
COL SEC_SIZE     FOR 9,999,990
COL BLK_SIZE     FOR 9,999,990
COL AU_SIZE      FOR 9,999,990
COL LIVRE_PCT    FOR 99,990.00   HEA "LIVRE_%"
COL USADO_PCT    FOR 99,990.00   HEA "USADO_%"
COL LIVRE_MB     FOR 999,999,990
COL USADO_MB     FOR 999,999,990
COL TOTAL_MB     FOR 999,999,990
select dg.group_number AS NUM#, dg.name as NOME, dg.state
    ,  dg.sector_size as SEC_SIZE, dg.block_size AS BLK_SIZE, dg.allocation_unit_size as AU_SIZE
    ,   decode(dg.type,'EXTERN','1 EXTERN','NORMAL','2 NORMAL','HIGH','3 HIGH')       as REDUNDANCIA
    ,  (dg.free_mb/decode(dg.type,'EXTERN',1,'NORMAL',2,'HIGH',3))                    as LIVRE_MB
    , (dg.total_mb/decode(dg.type,'EXTERN',1,'NORMAL',2,'HIGH',3)) -
       (dg.free_mb/decode(dg.type,'EXTERN',1,'NORMAL',2,'HIGH',3))                    as USADO_MB
    , (dg.total_mb/decode(dg.type,'EXTERN',1,'NORMAL',2,'HIGH',3))                    as TOTAL_MB
    , ((dg.free_mb/decode(dg.type,'EXTERN',1,'NORMAL',2,'HIGH',3)) /
     ((dg.total_mb/decode(dg.type,'EXTERN',1,'NORMAL',2,'HIGH',3))) * 100)            as LIVRE_PCT
,100-(((dg.free_mb/decode(dg.type,'EXTERN',1,'NORMAL',2,'HIGH',3)) /
      (dg.total_mb/decode(dg.type,'EXTERN',1,'NORMAL',2,'HIGH',3))) * 100)            as USADO_PCT
from  v$asm_diskgroup DG order by 1 ;


--# VERIFICAR DISCOS DO ASM
COL NAME      FOR A15
COL LABEL     FOR A15
COL PATH      FOR A15
COL FREE_MB   FOR 9,999,990
COL USED_MB   FOR 9,999,990
COL TOTAL_MB  FOR 9,999,990
select ad.group_number as GROUP#, ad.disk_number as DISK#, ad.name, ad.label, ad.path
    , ad.mode_status as STATUS, ad.state, ad.free_mb, ad.total_mb-ad.free_mb as USED_MB, ad.total_mb
from  v$asm_disk AD
order by group#, disk#, ad.name ;



--# Informações sobre ACFS
SET LINES 237 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL CON_ID FOR 9999999999
COL FS_NAME FOR A30
COL VOL_DEVICE FOR A15
COL PRIMARY_DEVICE FOR A5
COL TOTAL_MB FOR 9,999,990
COL FREE_MB FOR 9,999,990
select asmv.con_id, asmv.fs_name,
asmv.vol_device,
asmv.primary_vol,
asmv.total_mb, asmv.free_mb
from v$asm_acfsvolumes ASMV;



--# Informações sobre I/O ASM
SET LINES 237 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
col insname for a20
col db_uqname for a20
col clustername for a15
select io.instname, io.dbname as db_uqname,
io.clustername, io.group_number, io.disk_number,
io.reads, io.writes,
io.read_time, io.write_time,
io.bytes_read, io.bytes_written,
io.read_errs as error_read,
io.write_errs as error_write
from v$asm_disk_iostat io;
