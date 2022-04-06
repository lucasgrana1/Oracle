--# script de CREATE de tablespaces:
-----------------------------------
set pagesize 10000
set linesize 190
col Comando format a130
select 'create tablespace ' || t.tablespace_name || ' logging datafile
''/ora01/caminho/' || lower(t.tablespace_name) || '_01.dbf'' size ' || case when round(ar.usado,0) <= 64 then 64 else round(ar.usado,0) end || 'M autoextend on next 64M maxsize 30G
extent management local segment space management auto;' as Comando
from dba_tablespaces t,
(select df.tablespace_name tablespace,
 sum(nvl(df.user_bytes,0))/1024/1024 Alocado,
 (sum(df.bytes) - sum(NVL(df_fs.bytes, 0))) / 1024 / 1024 Usado,
 sum(NVL(df_fs.bytes, 0)) / 1024 / 1024 Livre,
 sum(decode(df.autoextensible,'YES',decode(sign(df.maxbytes - df.bytes),1,df.maxbytes - df.bytes,0),0)) / 1024 / 1024 Expansivel,
 sum(df.bytes) / 1024 / 1024 Total
 from dba_data_files df,
 (select tablespace_name, file_id, sum(bytes) bytes
 from dba_free_space
 group by tablespace_name, file_id) df_fs
 where df.tablespace_name = df_fs.tablespace_name(+)
 and df.file_id = df_fs.file_id(+)
 group by df.tablespace_name
 union
 select tf.tablespace_name tablespace,
 sum(nvl(tf.user_bytes,0))/1024/1024 Alocado,        
 sum(tf_fs.bytes_used) / 1024 / 1024 Usado,
 sum(tf_fs.bytes_free) / 1024 / 1024 Livre,
 sum(decode(tf.autoextensible,'YES',decode(sign(tf.maxbytes - tf.bytes),1,tf.maxbytes - tf.bytes,0),0)) / 1024 / 1024 Expansivel,
 sum(tf.bytes) / 1024 / 1024 Total
 from dba_temp_files tf, v$temp_space_header tf_fs
 where tf.tablespace_name = tf_fs.tablespace_name
 and tf.file_id = tf_fs.file_id
 group by tf.tablespace_name) ar,
 (select df.tablespace_name tablespace, 'ILIMITADO' limite
 from dba_data_files df
 where df.maxbytes / 1024 / 1024 / 1024 > 32
 and df.autoextensible = 'YES'
 group by df.tablespace_name
 union
 select tf.tablespace_name tablespace, 'ILIMITADO' limite
 from dba_temp_files tf
 where tf.maxbytes / 1024 / 1024 / 1024 > 32
 and tf.autoextensible = 'YES'
 group by tf.tablespace_name) cresc
 where cresc.tablespace(+) = t.tablespace_name
 and ar.tablespace(+) = t.tablespace_name
 and t.contents = 'PERMANENT'
 and not t.tablespace_name in ('SYSAUX','SYSTEM','UNDOTBS1','UNDOTBS2','USERS')
order by ar.usado;


--# TEMP tablespaces:
--------------------
set pagesize 10000
set linesize 190
col Comando format a130
select 'create temporary tablespace ' || t.tablespace_name || ' tempfile
''/rh_br_dados/rhbr/' || lower(t.tablespace_name) || '_01.dbf'' size ' || case when round(ar.usado,0) <= 100 then 100 else round(ar.usado,0) end || 'M autoextend on next 100M maxsize 31G;' as Comando
from dba_tablespaces t,
(select df.tablespace_name tablespace,
 sum(nvl(df.user_bytes,0))/1024/1024 Alocado,
 (sum(df.bytes) - sum(NVL(df_fs.bytes, 0))) / 1024 / 1024 Usado,
 sum(NVL(df_fs.bytes, 0)) / 1024 / 1024 Livre,
 sum(decode(df.autoextensible,'YES',decode(sign(df.maxbytes - df.bytes),1,df.maxbytes - df.bytes,0),0)) / 1024 / 1024 Expansivel,
 sum(df.bytes) / 1024 / 1024 Total
 from dba_data_files df,
 (select tablespace_name, file_id, sum(bytes) bytes
 from dba_free_space
 group by tablespace_name, file_id) df_fs
 where df.tablespace_name = df_fs.tablespace_name(+)
 and df.file_id = df_fs.file_id(+)
 group by df.tablespace_name
 union
 select tf.tablespace_name tablespace,
 sum(nvl(tf.user_bytes,0))/1024/1024 Alocado,        
 sum(tf_fs.bytes_used) / 1024 / 1024 Usado,
 sum(tf_fs.bytes_free) / 1024 / 1024 Livre,
 sum(decode(tf.autoextensible,'YES',decode(sign(tf.maxbytes - tf.bytes),1,tf.maxbytes - tf.bytes,0),0)) / 1024 / 1024 Expansivel,
 sum(tf.bytes) / 1024 / 1024 Total
 from dba_temp_files tf, v$temp_space_header tf_fs
 where tf.tablespace_name = tf_fs.tablespace_name
 and tf.file_id = tf_fs.file_id
 group by tf.tablespace_name) ar,
 (select df.tablespace_name tablespace, 'ILIMITADO' limite
 from dba_data_files df
 where df.maxbytes / 1024 / 1024 / 1024 > 32
 and df.autoextensible = 'YES'
 group by df.tablespace_name
 union
 select tf.tablespace_name tablespace, 'ILIMITADO' limite
 from dba_temp_files tf
 where tf.maxbytes / 1024 / 1024 / 1024 > 32
 and tf.autoextensible = 'YES'
 group by tf.tablespace_name) cresc
 where cresc.tablespace(+) = t.tablespace_name
 and ar.tablespace(+) = t.tablespace_name
 and t.contents = 'TEMPORARY'
order by ar.usado desc;
