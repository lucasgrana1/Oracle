--# CHECAR/SALVAR ESTADO DO PDB AO REINICIAR INSTANCIA
COL CON_NAME       FOR A20
COL INSTANCE_NAME  FOR A20
select * from dba_pdb_saved_states ;
-- sem linhas, ou seja, o PDB nao esta salvo

alter pluggable database NOME_DATABASE save state ;

select * from dba_pdb_saved_states ; -- na base DEV da Metisa por exemplo
CON_ID CON_NAME INSTANCE_NAME  CON_UID GUID                             STATE RES
------ -------- ------------- -------- -------------------------------- ----- ---
     3 MTDEV    cdbdev        88201575 BC1C592E8AF927B0E053A596A8C001C8 OPEN  NO
