-----------------------------
--# CLAUSULAS
-----------------------------



'--------------------
--# TRANSFORM CLAUSE
--------------------'

TRANSFORM=OID:N = É utilizada a clausula para ignorar o id existe um objeto com o mesmo id.

TRANSFORM=STORAGE:N = Faz a reorganização dos dados, reduzindo a fragmentação


'------------------
--# LOGTIME CLAUSE
------------------'

A partir do 12c

Especifica que as mensagens exibidas durante as operações de export/import tenham carimbo de data, util para saber descobrir o tempo decorrido entre diferentes partes.


LOGTIME=NONE    -> SEM DATA DEFAULT

LOGTIME=STATUS  -> MENSAGENS DE STATUS

LOGTIME=LOGFILE -> MENSAGENS DE ARQUIVOS DE LOG

LOGTIME=ALL     -> MOSTRA TUDO


'------------------------
--# METRICS CLAUSE
------------------------'

A partir do 12c.


Esta clausula lista o tempo gasto em cada categoria

METRICS=Y




'-------------------------
--# TABLE_EXISTS CLAUSE
-------------------------'

define o que vai ser feito caso a tabela já exista.

--# Default
TABLE_EXISTS_ACTION=SKIP

--# Vai jogar os novos dados no final
TABLE_EXISTS_ACTION=APPEND


--# vai truncar a tabela e importar os dados
TABLE_EXISTS_ACTION=TRUNCATE


--# vai recriar a tabela com os dados
TABLE_EXISTS_ACTION=REPLACE





--------------------------------
--# SCRIPTS
--------------------------------




--------------------------------------------------------------------------------------------------------------------------------------------------
--# EXPDP_OWNER COM CONTAINER DATABASE
--------------------------------------------------------------------------------------------------------------------------------------------------


export ORACLE_SID=henndsv
WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMA=EDOC

$ORACLE_HOME/bin/expdp USERID="\"BACKUP_TMP/BACKUP_TMP1@172.16.101.243/henndsv\"" SCHEMAS=${WSCHEMA} DIRECTORY=MANTER DUMPFILE=${WSCHEMA}.${WDATE}.dp.dmp LOGFILE=${WSCHEMA}.${WDATE}.dp.log FLASHBACK_TIME=${WDATE} EXCLUDE=STATISTICS LOGTIME=ALL METRICS=Y



--------------------------------------------------------------------------------------------------------------------------------------------------
--# EXPDP SEM VARIAVEL
--------------------------------------------------------------------------------------------------------------------------------------------------



export ORACLE_SID=DB01

$ORACLE_HOME/bin/expdp USERID="\"backup/backup\"" SCHEMAS=RAFAEL,RAFA DIRECTORY=BKP_FILES DUMPFILE=RAFAEL_RAFA_20210720.dmp.dp LOGFILE=RAFAEL_RAFA_20210720.dmp.log FLASHBACK_TIME=20210720170530 EXCLUDE=STATISTICS






--------------------------------------------------------------------------------------------------------------------------------------------------
--MODELO PARA EXPDP_FULL
--------------------------------------------------------------------------------------------------------------------------------------------------



export ORACLE_SID=DB01
WDATE=$(date +"%Y%m%d%H%M%S")

$ORACLE_HOME/bin/expdp USERID="\"backup/\"" DIRECTORY=BACKUP DUMPFILE=FULL_teste.${WDATE}.dp.dmp FULL=YES LOGFILE=BKPLOG:FULL_teste.${WDATE}.dp.log FLASHBACK_TIME=${WDATE} EXCLUDE=STATISTICS





--------------------------------------------------------------------------------------------------------------------------------------------------
--# MODELO PARA EXPDP_OWNER
--------------------------------------------------------------------------------------------------------------------------------------------------


export ORACLE_SID=kprd11

WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMA=SAPIENS

$ORACLE_HOME/bin/expdp USERID="\"backup/\"" SCHEMAS=${WSCHEMA} DIRECTORY=BACKUP DUMPFILE=${WSCHEMA}.${WDATE}.dmp.dp LOGFILE=${WSCHEMA}.${WDATE}.dmp.log FLASHBACK_TIME=${WDATE} EXCLUDE=STATISTICS



--------------------------------------------------------------------------------------------------------------------------------------------------
--# EXPDP_OWNER VARIAVEIS NO ARQUIVO
--------------------------------------------------------------------------------------------------------------------------------------------------


export ORACLE_SID=dbprod

WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMA=I4IFLOW
ARQ_DMP=${WSCHEMA}.${WDATE}.dp.dmp
ARQ_LOG=${WSCHEMA}.${WDATE}.dp.log

$ORACLE_HOME/bin/expdp USERID="\"backup/backup1\"" SCHEMAS=${WSCHEMA} DIRECTORY=BACKUP DUMPFILE=${ARQ_DMP} LOGFILE=${ARQ_LOG} FLASHBACK_TIME=${WDATE} EXCLUDE=STATISTICS LOGTIME=ALL METRICS=Y



--------------------------------------------------------------------------------------------------------------------------------------------------
--#MODELO EXPDP_OWNER COM EXCLUDE_TABLE SEM PARFILE
--------------------------------------------------------------------------------------------------------------------------------------------------

export ORACLE_SID=sistemas

WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMA=SAPIENSSUPREMO

$ORACLE_HOME/bin/expdp USERID="\"backup/\"" SCHEMAS=${WSCHEMA} DIRECTORY=BACKUP DUMPFILE=${WSCHEMA}.${WDATE}.dp.dmp LOGFILE=${WSCHEMA}.${WDATE}.dp.log FLASHBACK_TIME=${WDATE} EXCLUDE=STATISTICS EXCLUDE=TABLE:"\"IN ('R960PAR','USU_TESCMSG')"\"



--------------------------------------------------------------------------------
--#	BACKUP AVULSO OWNER RM BASE SERVPROD (PMZ) RAC COM PDB
--------------------------------------------------------------------------------

export NLS_DATE_FORMAT='yyyy/mm/dd'

export ORACLE_SID=cdbpmz1

WDATE=$(date +"%Y%m%d%H%M%S")
DB_USER=BACKUP1
DB_PASSWD=BACKUP1
DB_SERVICE_NAME=pemaza-scan/servprod.grupopmz.com.br
DB_NAME=SERVPROD
WSCHEMAS=RM
DIR_BKP=CARGA_TMP
WARQ_DMP=expdp.${DB_NAME}.${WSCHEMAS}.${WDATE}.dp.dmp
WARQ_LOG=expdp.${DB_NAME}.${WSCHEMAS}.${WDATE}.dp.log

${ORACLE_HOME}/bin/expdp USERID=${DB_USER}/${DB_PASSWD}@${DB_SERVICE_NAME} SCHEMAS=${WSCHEMAS} DIRECTORY=${DIR_BKP} DUMPFILE=${WARQ_DMP} LOGFILE=${WARQ_LOG} FLASHBACK_TIME=${WDATE} EXCLUDE=STATISTICS METRICS=YES



--------------------------------------------------------------------------------------------------------------------------------------------------
--BACKUP COM O USUÁRIO SYS
--------------------------------------------------------------------------------------------------------------------------------------------------


USERID="\"/ as sysdba\""



--------------------------------------------------------------------------------------------------------------------------------------------------
--#MODELO PARA EXPDP_+DE_1_OWNER AGENDADO CRONTAB
--------------------------------------------------------------------------------------------------------------------------------------------------



#!/bin/sh

WDATE=$(date +"%Y%m%d%H%M%S")

DB_USER=BACKUP

DB_PASSWD=

DIR_BKP=BACKUP

USUARIO=SAPIENS,VETORH

ARQ_DMP=SAPIENS_VETORH.${WDATE}.dp.dmp

ARQ_LOG=SAPIENS_VETORH.${WDATE}.dp.log

$ORACLE_HOME/bin/expdp ${DB_USER}/${DB_PASSWD} DIRECTORY=${DIR_BKP} FLASHBACK_TIME=${WDATE} SCHEMAS=${USUARIO} DUMPFILE=${ARQ_DMP} LOGFILE=${ARQ_LOG} EXCLUDE=STATISTICS



--------------------------------------------------------------------------------------------------------------------------------------------------
--#MODELO PARA EXPDP_TABELA
--------------------------------------------------------------------------------------------------------------------------------------------------



export ORACLE_SID=DB01
WDATE=$(date +"%Y%m%d%H%M%S")

$ORACLE_HOME/bin/expdp USERID="\"backup/\"" TABLES = LUCASM.testes1 DIRECTORY=BACKUP DUMPFILE=LUCASM.${WDATE}.dp.dmp LOGFILE=BKPLOG:LUCASM.${WDATE}.dp.log FLASHBACK_TIME=${WDATE} EXCLUDE=STATISTICS



--------------------------------------------------------------------------------------------------------------------------------------------------
--#MODELO PARA EXPDP_TABLESPACE
--------------------------------------------------------------------------------------------------------------------------------------------------



export ORACLE_SID=DB01
WDATE=$(date +"%Y%m%d%H%M%S")

$ORACLE_HOME/bin/expdp USERID="\"backup/\"" TABLESPACES =TS_TESTES DIRECTORY=BACKUP DUMPFILE=ts_testes.${WDATE}.dp.dmp LOGFILE=BKPLOG:ts_testes.${WDATE}.dp.log FLASHBACK_TIME=${WDATE} EXCLUDE=STATISTICS



--------------------------------------------------------------------------------------------------------------------------------------------------
--MODELO PARA EXPDP COM EXCLUDE SEM PARFILE
--------------------------------------------------------------------------------------------------------------------------------------------------



WDATE=$(date +"%Y%m%d%H%M%S") -- DATA PARA O FLASHBACK_TIME (CONSISTENCIA)
WSCHEMAS=VETORH -- OWNER PARA REALIZAR BAKCUP

$ORACLE_HOME/bin/expdp -- UTILITARIO ORACLE PARA BACKUP (EXPORT DATAPUMP)
USERID="\"backup/bkplunender\"" -- USUARIO/SENHA NO BANCO, COMO OS VALORES ESTARAO EM " DEVE-SE DAR UM ESCAPE NESTES CARACTERES POR ESTAR EM LINHA DE COMANDO, SE FOSSE UM PARFILE NAO SERIA NECESSARIO
SCHEMAS=${WSCHEMAS} -- SCHEMAS PARA REALIZAR BACKUP, FOI USADO UMA VARIAVEL
DIRECTORY=BACKUP_LND -- DIRETORIO ONDE FICARA O DUMP
DUMPFILE=RHBR.${WSCHEMAS}.${WDATE}.dp.dmp -- NOME DO ARQUIVO DO DUMP, USADO VARIAVEIS
LOGFILE=RHBR.${WSCHEMAS}.${WDATE}.dp.log -- NOME DO LOG DO DUMP, USADO VARIAVEIS
FLASHBACK_TIME=${WDATE} -- HORARIO DO SNAPSHOT "FOTO" DAS TABELAS, CONSISTENTE
EXCLUDE=STATISTICS -- EXCLUIR ESTATISTICAS, MAIS RAPIDO E MENOR
EXCLUDE=TABLE:"\"IN ('R067CMD','R067COM','...','R067SAL','R070ACC','R070CRI')"\" -- EXCLUIR AS TABELAS SOLICITADAS, NOVAMENTE DEVE-SE DAR ESCAPE NO "




----------------------------------
--# EXPORT COM PARFILE
----------------------------------

vi expdp_hmgcnfbr_tabs_textil5.sh


. /etc/.parametros_oracle11g_hcnfbr
WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMA=TEXTIL5
WPARFILE=/hmg-orabases/backup/textil5_tabs.par

$ORACLE_HOME/bin/expdp USERID="\"sys/oracle11g as sysdba\"" SCHEMAS=${WSCHEMA} DIRECTORY=BKP_2 DUMPFILE=${WSCHEMA}.${WDATE}.dp.dmp LOGFILE=${WSCHEMA}.${WDATE}.dp.log FLASHBACK_TIME=${WDATE} PARFILE=${WPARFILE}


Script Parfile: vi textil5_tabs.par

INCLUDE=TABLE:"IN ('LNL_C100','LNL_H010','LNL_K200','LNL_RCPE_K200_H010')"








--------------------------------------------------------------------------------------------------------------------------------------------------
-- MODELO PARA IMPDP_FULL
--------------------------------------------------------------------------------------------------------------------------------------------------




export ORACLE_SID=ktst2
WDATE=$(date +"%Y%m%d%H%M%S")

impdp userid="\"backup/\"" REMAP_SCHEMA=SAPIENS:SIMULADO directory=BKP dumpfile=expdp.SAPIENS.20210318091358.dp.dmp FULL=y logfile=expdp.SAPIENS.20210318091358.dp.log TRANSFORM=OID:N TRANSFORM=STORAGE:N

cp -v LUCASM.20210128175448.dp.dmp /u01/oracle/DB01/backups/datapump/files


--------------------------------------------------------------------------------------------------------------------------------------------------
--REMAP TABLESPACE
--------------------------------------------------------------------------------------------------------------------------------------------------



impdp hr REMAP_TABLESPACE=tbs_1:tbs_6 DIRECTORY=dpump_dir1
DUMPFILE=employees.dmp



--------------------------------------------------------------------------------------------------------------------------------------------------
--#PARFILE ON IMPDP
--------------------------------------------------------------------------------------------------------------------------------------------------



WPARFILE=/caminho/do/parfile.par
PARFILE=${WPARFILE}
< parfile.par >
EXCLUDE=TABLE:"IN ('SRA010', 'ASD1020')"
REMAP_TABLE=OWNER.TABELA_OLD:TABELA_NEW

WARQ_DMP=${WSCHEMAS}.${WDATE}.dp.dmp



--------------------------------------------------------------------------------------------------------------------------------------------------
--#IMPDP COM CONTAINER DATABASE
--------------------------------------------------------------------------------------------------------------------------------------------------



export ORACLE_SID=henndsv

$ORACLE_HOME/bin/impdp USERID="\"backup1/@172.16.101.243/henndsv\"" DIRECTORY=CARGA SCHEMAS=HANDIT DUMPFILE=HENNPROD.HANDIT.20210304190009.dp.dmp LOGFILE=HENNPROD.HANDIT.20210304190009.imp.log REMAP_SCHEMA=HANDIT:HANDITDSV TRANSFORM=STORAGE:N TRANSFORM=OID:N



--------------------------------------------------------------------------------------------------------------------------------------------------
--# import tabela remapeando tabela e owner
--------------------------------------------------------------------------------------------------------------------------------------------------



. /cnf_br_oracle/.parametros_oracle_cnfbr

WSCHEMAS=TEXTIL5
WARQ_DMP=CNFBR.full.dp.dmp
WARQ_LOG=impdp.TEXTIL5.TMRP_650_HIST.imp.log

${ORACLE_HOME}/bin/impdp
USERID="\"backup/senha@cnfbr\"" SCHEMAS=${WSCHEMAS} DIRECTORY=DATA_PUMP_DIR DUMPFILE=${WARQ_DMP} LOGFILE=${WARQ_LOG} TRANSFORM=STORAGE:N TRANSFORM=OID:N METRICS=Y INCLUDE=TABLE:"\"IN ('TMRP_650')"\" REMAP_SCHEMA=TEXTIL5:ADMDB REMAP_TABLE=TEXTIL5.TMRP_650:TMRP_650_HIST



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--# IMPDP MAX MOHR HML (NOVO 19C) (OBS: NÃO DEIXOU EXECUTAR OS DOIS IMPORTS JUNTOS, ENTÃO FORAM EXECUTADOS 2 IMPORTS UM PARA CADA OWNER POIS O BACKUP ERA POR OWNER ENTÃO O IMPDP NÃO DEIXOU FAZER 2 DE UMA VEZ)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



#!/bin/sh

$ORACLE_HOME/bin/impdp userid="\"backup/\"" directory=BACKUP dumpfile=DBPROD.SSERVER.01.20210328003001.dp.dmp logfile=DBPROD.SSERVER.20210328003001.imp.log schemas=SSERVER transform=storage:n transform=oid:n metrics=y

$ORACLE_HOME/bin/impdp userid="\"backup/\"" directory=BACKUP dumpfile=DBPROD.RH.01.20210328003001.dp.dmp logfile=DBPROD.RH.20210328003001.imp.log schemas=RH transform=storage:n transform=oid:n metrics=y



----------------------------------------------------------------------------------------------------------------------------------
--#IMPDP ESPAIDER
----------------------------------------------------------------------------------------------------------------------------------


export ORACLE_SID=ktst2
WDATE=$(date +"%Y%m%d%H%M%S")

$ORACLE_HOME/bin/impdp USERID="\"backup/\"" DIRECTORY=BKP DUMPFILE=kprd11_espaider_20210518090414.dmp.dp LOGFILE=kprd11_espaider_20210518090414.imp.log TRANSFORM=STORAGE:N TRANSFORM=OID:N REMAP_SCHEMA=ESPAIDER:ESPAIDER_TST REMAP_TABLESPACE=ESPAIDER_DATA:ESPAIDER_TST_DATA,ESPAIDER_INDEX:ESPAIDER_TST_INDEX




----------------------------------------------------------------------------------------------------------------------------------
--#EXPDP COM PARFILE
----------------------------------------------------------------------------------------------------------------------------------



WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMA=AUTOMA

WPARFILE=/backup/datapump/tmp/automa.par
$ORACLE_HOME/bin/expdp USERID=bkpexport/ DIRECTORY=BACKUP SCHEMAS=${WSCHEMA} DUMPFILE=expdp_${WSCHEMA}_${WDATE}.dmp.dp LOGFILE=expdp_${WSCHEMA}_${WDATE}.log FLASHBACK_TIME=${WDATE} PARFILE=${WPARFILE}


----------------------------------------------------------------------------------------------------------------------------------
--# CONTEUDO PARFILE
----------------------------------------------------------------------------------------------------------------------------------


EXCLUDE=STATISTICS
EXCLUDE=TABLE:"IN('MOVIMENTO_OLD','MOVIMENTO_OLD2')"





-----------------------------------
-- EXPDP COM CONTAINER DATABASE --
-----------------------------------


export ORACLE_SID=cdbprd

WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMA=BETONMIX

$ORACLE_HOME/bin/expdp USERID="\"backup/SENHA@PDB\"" SCHEMAS=${WSCHEMA} DIRECTORY=BACKUP DUMPFILE=${WSCHEMA}.${WDATE}.dmp.dp LOGFILE=${WSCHEMA}.${WDATE}.dmp.log FLASHBACK_TIME=${WDATE} EXCLUDE=STATISTICS





---------------------------------
-- EXPDP FULL RN SÓ ESTRUTURA --
---------------------------------

export ORACLE_SID=cnfbr

WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMA=TEXTIL5

$ORACLE_HOME/bin/expdp USERID="\"backup/\"" SCHEMAS=${WSCHEMA} DIRECTORY=BACKUP_LND DUMPFILE=${WSCHEMA}.${WDATE}.dmp.dp LOGFILE=${WSCHEMA}.${WDATE}.dmp.log FLASHBACK_TIME=${WDATE} CONTENT=METADATA_ONLY EXCLUDE=STATISTICS
