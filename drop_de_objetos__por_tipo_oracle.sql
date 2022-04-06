SET FEED OFF
SET LINES 150
SET PAGES 6000
SELECT 'drop '||object_type||' '||owner||'.'||'"'||object_name||'"'||' cascade constraints;'
FROM dba_objects
WHERE object_type IN ('TABLE')
AND owner IN ('URENAUXVIEWTREINO','LOGINP','UV3DADGLB')

spool drop_URENAUXVIEWTREINO.sql
/
spool off

SET feed ON
@drop_URENAUXVIEWTREINO.sql

SET FEED OFF
SET LINES 150
SET PAGES 6000
SELECT 'drop '||object_type||' '||owner||'.'||'"'||object_name||'"'||';'
FROM dba_objects
WHERE object_type NOT IN ('TABLE','INDEX')
  AND owner IN ('URENAUXVIEWTREINO','LOGINP','UV3DADGLB')

spool drop_all.sql
/
spool off
SET feed ON
@drop_all.sql
