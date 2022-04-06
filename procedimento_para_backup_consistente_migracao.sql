--# INTERROMPER JOBS
alter system set job_queue_processes = 0 ;


--# BAIXAR A BASE
shutdown immediate ;


--# PARAR O LISTENER
lsnrctl stop


--# SUBIR A BASE
startup ;


--# REALIZAR O BACKUP (ajustar script para nao usar TNS)
nohup sh backup.sh &
