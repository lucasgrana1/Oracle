---------------------------
--# LISTENER BPBUNGE
---------------------------



--# Quando for alterado para ip fixo criar a entrada no tnsnames.ora

LOCAL_LISTENER =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 10.172.179.91)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SID = PIMS)
    )
  )



--# conectar no banco e executar os parametros abaixo

alter system set local_listener='LOCAL_LISTENER';

alter system register;








--# REINICIAR O LISTENER (LIGAR)
lsnrctl start LNS_MLHPY


--# QUANDO TIVER +DE 1 LISTENER NA BASE PARA REINICIAR O LISTENER
lsnrctl start NOME_LISTENER


--# PARAR O LISTENER
lsnrctl stop



--# QUANDO TIVER +DE 1 LISTENER NA BASE PARA DESLIGAR O LISTENER
lsnrctl stop NOME_LISTENER



--# DIRETORIO DO LISTENER GERALMENTE EM:
$ORACLE_HOME/network/admin/listener.ora



--# VERIFICAR O LISTENER
tnsping tnsname







--# PROCEDIMENTO DE RECICLAGEM DO LISTENER.LOG
" diretório padrão "

/oracle/app/diag/tnslsnr/NOME_SERVIDOR/listener/trace/

/oraprd01/app/oracle/product/10.2.0/network/log/





--# VERIFICAR O STATUS DO LISTENER E DIRETORIO OU PEGAR NO MONITORAMENTO
lsnrctl status



--# RECICLAR O LISTENER.LOG
lsnrctl set log_status off -- desabilitar log do listener



WDT=`date "+%Y%m%d_%H%M%S"` -- criar variavel com data



mv listener.log listener_${WDT}.log -- renomear arquivo com a data



lsnrctl set log_status on -- habilitar log do listener


gzip listener_${WDT}.log & -- compactar log



--# setar service_names no banco
alter system set service_names='fey';


--#APONTAMENTO CHAMADO

Realizado procedimento de reciclagem do log do listener.

Verificado log do listener OK.

Verificada sessões no banco, OK.
