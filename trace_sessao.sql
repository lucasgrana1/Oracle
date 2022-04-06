[ TRACE DE SESSAO ]

" 1 - Identificar a sessão, filtrando por owner/usuário/maquina, verificar com cliente "
"--------------------------------------------------------------------------------------"


" 2 - Anotar SID, Serial e OSPID "
"--------------------------------"


" 3 - Iniciar o trace "
"---------------------"
EXECUTE DBMS_MONITOR.SESSION_TRACE_ENABLE(489,57663, TRUE, true);

SID_SERIAL     OS_PID STATUS  TEMPO        LOGON         OWNER_USUARIO_ESTACAO                    PROGRAMA_MODULO_ACAO            EVENTO             SQL_ID
------------- ------- ------- ------------ ------------- ---------------------------------------- ------------------------------- ------------------ --------------
872,29643,@1    12664 INATIVA 00h 00m 29s  10/09 10:54h  TEXTIL5,root,SystextilWeb06,10.50.38.86  systextilweb,obrf_f277 1-ARNO,  SQL*Msg fr client  *gzpv5bbnfbw5z


" 4 - Informar ao usuário que ele pode iniciar o/a processo/rotina "
"------------------------------------------------------------------"


" 5 - Finalizar o trace "
"-----------------------"
caso retornar falha é porque usuário desconectou-se da sessão

EXECUTE DBMS_MONITOR.SESSION_TRACE_DISABLE(489,57663);


" 6 - Gerar 2 arquivos de saidas "
"--------------------------------"
arquivos são gerados no mesmo diretório do alert.log

filtrando pelo OS_PID da sessão gerar os 2 arquivos abaixo
ls -lstrh *OS_PID*
ls -lstrh *12664*

cnfbr_ora_12664.trc

tkprof cnfbr_ora_12664.trc cnfbr_ora_12664.trc.out

tkprof cnfbr_ora_12664.trc cnfbr_ora_12664.fchela.out sort=fchela

grep -n "^total" orablu_ora_23087.trc.out --#traz o numero total de execuções e tempo utilizado pela query


" 7 - Analisar os arquivos de saida "
"-----------------------------------"
tentar identificar o(s) comando(s) mais custos/demorados, e verificar se estão utilizando os índices corretamente,
comparar os campos no filtro com os índices existentes.

fchela -> ordena por custo de CPU
normal -> ordena por ordem de execução
