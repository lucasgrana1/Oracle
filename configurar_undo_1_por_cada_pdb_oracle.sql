--# CONFIGURACAO UNDO - SHARED (1 CDB) ou LOCAL (1 por PDB) +12.2
-----------------------------------------------------------------
SET LINES 237 PAGES 10000 LONG 1000000 FEED 1 ECHO ON TI ON TRIM ON TRIMS ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
COL PROPERTY_NAME  FOR A40
COL PROPERTY_VALUE FOR A40
select P.property_name, P.property_value from database_properties P where P.property_name = 'LOCAL_UNDO_ENABLED';

-- parar banco, iniciar modo upgrade, ativar local undo
shutdown immediate;
startup upgrade;
alter database local undo on;
-- ira criar uma tablespace undo em cada PDB
