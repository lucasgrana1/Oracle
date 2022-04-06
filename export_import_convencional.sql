export ORACLE_SID=kprd11

WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMAS=KARSTENWVWEBPRD

$ORACLE_HOME/bin/exp USERID="\"backup/b4ckup16\"" OWNER=${WSCHEMAS} FILE=exp.WVW.${WDATE}.dp LOG=exp.WVW.${WDATE}.log CONSISTENT=Y STATISTICS=none

--#EXPORT CONVENCIONAL
export ORACLE_SID=kprd11

WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMAS=KARSTENWVWEBPRD

$ORACLE_HOME/bin/exp USERID="\"backup/b4ckup16\"" OWNER=${WSCHEMAS} FILE=exp.WVW.${WDATE}.dp LOG=exp.WVW.${WDATE}.log CONSISTENT=Y STATISTICS=none



--# EXPORT CONVENCIONAL (EXP)
export ORACLE_SID=dbprod

WDATE=$(date +"%Y%m%d%H%M%S")
WSCHEMAS=NOME_DO_SCHEMA
WARQ_DMP=exp.${WSCHEMA}.${WDATE}.dmp
WARQ_LOG=exp.${WSCHEMA}.${WDATE}.log

$ORACLE_HOME/bin/exp
 USERID="\"backup/b4ckup16\""
 OWNER=${WSCHEMAS}
 FILE=${WARQ_DMP}
 LOG=${WARQ_LOG}
 CONSISTENT=Y
 STATISTICS=none



--# IMPORT CONVENCIONAL (IMP)
export ORACLE_SID=dbteste

WARQ_DMP=/backup/export/files/BACKUP.dmp
WARQ_LOG=/backup/export/files/BACKUP.imp.log

$ORACLE_HOME/bin/imp
 USERID="\"/ as sysdba\""
 FILE=${WARQ_DMP}
 LOG=${WARQ_LOG}
 STATISTICS=none
 FROMUSER=OWNER_ORIGEM
 TOUSER=OWNER_DESTINO
 FULL=Y  -- gerar DDL, direcionar log para imp.sql
 SHOW=Y  -- gerar DDL, direcionar log para imp.sql
 ROWS=N  -- sem linhas, somente metadados



--# IMPORT CONVENCIONAL (IMP) COM FIFO
WSCHEMA=NOME_DO_SCHEMA

WARQ_FIFO=/backup/datapump/tmp/imp_fifo
WARQ_DMP=/backup/datapump/files/full.20200417190302.dp.gz
WARQ_LOG=/backup/datapump/logs/full.20200417190302.imp.log

[ ! -p  ${WARQ_FIFO} ] && mknod ${WARQ_FIFO} p
gzip -d < ${WARQ_DMP} > ${WARQ_FIFO} &

imp USERID='"/ as sysdba"' BUFFER=4000000 FILE=${WARQ_FIFO} LOG=${WARQ_LOG} FROMUSER=${WSCHEMA} TOUSER=${WSCHEMA}



--# Export convencional FIFO
WDATE=$(date +"%Y%m%d%H%M%S")
WARQFIFO="/orabackup/dbprod/logico/exp_fifo"
WDUMP="/orabackup/dbprod/logico/dbprod_ull.${WDATE}.dmp.gz"
WLOG="/orabackup/dbprod/logico/log/dbprod_full.${WDATE}.log"
[ ! -p  ${WARQFIFO} ] && mknod ${WARQFIFO} p
gzip < ${WARQFIFO} > ${WDUMP} &
exp userid='"/ as sysdba"' buffer=4000000 file=${WARQFIFO} log=${WLOG} statistics=none full=y
