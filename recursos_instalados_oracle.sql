--# VER RECURSOS INSTALADOS
SET LINES 180 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
col comp_name for a35
col version for a15
col status for a11
col namespace for a20
col schema for a15
select comp_name,
version,
status,
modified, namespace,
schema
from dba_registry;




--# PARAMETROS ESPECIAIS ATIVOS NO BANCO
set serveroutput on
declare
  event_level number;
begin
  dbms_output.put_line('Checking for active events:');
  for i in 10000..29999 loop
    sys.dbms_system.read_ev(i,event_level);
    if (event_level > 0) then
      dbms_output.put_line('Event '||i||' set at level '|| event_level);
    end if;
  end loop;
  dbms_output.put_line('End.');
end;
/
