SELECT d.NAME, d.VALUE_STRING, sysdate AS dataaaaaaaaaaaa, c.OSUSER, c.USERNAME, c.MACHINE, c.PROGRAM, c.STATUS, c.SID, c.EVENT, e.SQL_ID, e.SQL_FULLTEXT, e.SQL_PROFILE, e.SQL_TEXT,
e.FETCHES, e.SORTS, e.CPU_TIME, e.USER_IO_WAIT_TIME, e.ROWS_PROCESSED, c.STATE, c.WAIT_CLASS, c.LOGON_TIME
FROM v$sqlarea e, v$session c, v$sql_bind_capture d
WHERE e.SQL_ID = c.SQL_ID
  AND c.SQL_ID = d.SQL_ID
--  and c.SID in (23)
--  and  c.EVENT = 'pipe get'
--   and upper(c.OSUSER) like upper('%aline%')
--  and e.SQL_ID = 'c52v6shrgasgq'
--  and c.EVENT = 'PL/SQL lock timer'
  AND c.STATUS = 'ACTIVE'
--and c.EVENT in ('control file parallel write', 'control file sequential read', 'db file parallel write', 'log file parallel write', 'log file sync')
ORDER BY C.SID DESC;
