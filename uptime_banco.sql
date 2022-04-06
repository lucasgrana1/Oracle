-- UPTIME BANCO DE DADOS
SET PAGES 1000 LINES 169 LONG 10000
COL INSTANCIA FOR A15
COL HOST FOR A25
COL VERSAO FOR A10
COL STATUS FOR A12
select instance_name as INSTANCIA,
host_name as HOST,
version as VERSAO,
status,
to_char(startup_time,'yyyy/mm/dd hh24:mi') as startup
from v$instance;
