-------------------------------------------------
--# FAZER BACKUP /CRIAR CONTROLFILE PARA STANDBY
-------------------------------------------------

alter database create standby controlfile as '/tmp/stdby.ctl';
