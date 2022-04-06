Cliente 192.168.88.175 solicita que movimente os redo logs do local atual para area disponibilizada hoje para REDO, fazer o procedimento para todos aqui aprenderem.

Caso não saiba como fazer, vamos fazendo ao vivo e vamos aprendendo.


a atividade pode ser iniciada hoje as 15hs, já alinhada com o Pericles



Passo a passo da atividade que foi realizada.



Primeiramente foi verificado onde estava os grupos de Redo:


THREAD# GROUP# SEQUENCE# MEMBER                      SIZE_MB ARC STATUS  BLK_SIZE FIRST_TIME
------- ------ --------- --------------------------- ------- --- ------- -------- -------------------
      1      2       239 +DG_DATA/CDBRAFA/redo02.log     200 YES ACTIVE       512 2021-10-07 14:46:13
      1      3       240 +DG_DATA/CDBRAFA/redo03.log     200 YES ACTIVE       512 2021-10-07 15:01:04
      1      1       241 +DG_DATA/CDBRAFA/redo01.log     200 NO  CURRENT      512 2021-10-07 15:16:00


Foi verificado que havia um novo DiskGroup:



GROUP_NUMBER NAME    STATE     TYPE   TOTAL_MB FREE_MB
------------ ------- --------- ------ -------- -------
           1 DG_DATA CONNECTED NORMAL   20,464   9,112
           2 DG_REDO CONNECTED EXTERN    3,071   3,012



Em seguida foram criados 3 novos grupos de Redo nesta nova área, com os comandos abaixo:



alter database add logfile group 4 ('+DG_REDO/CDBRAFA/redo04.log') size 200M;
alter database add logfile group 5 ('+DG_REDO/CDBRAFA/redo05.log') size 200M;
alter database add logfile group 6 ('+DG_REDO/CDBRAFA/redo06.log') size 200M;


Posteriormente foi forçado a troca do redo em uso com o comando abaixo:

alter system switch logfile;


Em seguida foi forçado descarregar a área de Redo, para liberar os arquivos deixá-los inativos.

Desta forma será possível excluí-los do banco.

alter system checkpoint;


Em seguida o grupo 1 de redo foi excluído com o comando abaixo:

alter database drop logfile group 1;


Neste momento os arquivos existentes eram:

THREAD# GROUP# SEQUENCE# MEMBER                      SIZE_MB ARC STATUS   BLK_SIZE FIRST_TIME
------- ------ --------- --------------------------- ------- --- -------- -------- -------------------
      1      3       240 +DG_DATA/CDBRAFA/redo03.log     200 YES INACTIVE      512 2021-10-07 15:01:04
      1      2       242 +DG_DATA/CDBRAFA/redo02.log     200 NO  CURRENT       512 2021-10-07 15:26:26
      1      6         0 +DG_REDO/CDBRAFA/redo06.log     200 YES UNUSED       4096
      1      5         0 +DG_REDO/CDBRAFA/redo05.log     200 YES UNUSED       4096
      1      4         0 +DG_REDO/CDBRAFA/redo04.log     200 YES UNUSED       4096


Em seguida então, os demais arquivos de redo foram removidos:


alter database drop logfile group 2;
alter database drop logfile group 3;


Até ficar somente os novos grupos (4, 5 e 6):

THREAD# GROUP# SEQUENCE# MEMBER                      SIZE_MB ARC STATUS  BLK_SIZE FIRST_TIME
------- ------ --------- --------------------------- ------- --- ------- -------- -------------------
      1      4       243 +DG_REDO/CDBRAFA/redo04.log     200 NO  CURRENT     4096 2021-10-07 15:28:36
      1      6         0 +DG_REDO/CDBRAFA/redo06.log     200 YES UNUSED      4096
      1      5         0 +DG_REDO/CDBRAFA/redo05.log     200 YES UNUSED      4096


Neste momento foram criados 3 novos grupos, com os mesmo números de antes:

alter database add logfile group 1 ('+DG_REDO/CDBRAFA/redo01.log') size 200M;
alter database add logfile group 2 ('+DG_REDO/CDBRAFA/redo02.log') size 200M;
alter database add logfile group 3 ('+DG_REDO/CDBRAFA/redo03.log') size 200M;



Neste momento a área de REDO era desta forma:


THREAD# GROUP# SEQUENCE# MEMBER                      SIZE_MB ARC STATUS  BLK_SIZE FIRST_TIME
------- ------ --------- --------------------------- ------- --- ------- -------- -------------------
      1      4       243 +DG_REDO/CDBRAFA/redo04.log     200 NO  CURRENT     4096 2021-10-07 15:28:36
      1      3         0 +DG_REDO/CDBRAFA/redo03.log     200 YES UNUSED      4096
      1      5         0 +DG_REDO/CDBRAFA/redo05.log     200 YES UNUSED      4096
      1      6         0 +DG_REDO/CDBRAFA/redo06.log     200 YES UNUSED      4096
      1      1         0 +DG_REDO/CDBRAFA/redo01.log     200 YES UNUSED      4096
      1      2         0 +DG_REDO/CDBRAFA/redo02.log     200 YES UNUSED      4096


Observado que ao excluir os grupos de Redo que estavam no DG_DATA, seu espaço "em disco" não foi liberado:


GROUP_NUMBER NAME    STATE     TYPE   TOTAL_MB FREE_MB
------------ ------- --------- ------ -------- -------
           1 DG_DATA CONNECTED NORMAL   20,464   9,112
           2 DG_REDO CONNECTED EXTERN    3,071   1,800


Portanto faz-se necessário conectar no ASM e excluir o arquivo manualmente.

Para tal deve-se conectar com usuário GRID a partir do ROOT com o comando "su - grid".

Em seguida carregar os parâmetros do GRID com ". /etc/parametros_grid".

Então abrir o programa do ASM "asmcmd" que é bem similar ao shell do linux, aceitando comandos de cópia (cp), listagem (ls), por exemplo.

Com o comando "lsdg" são listados os DiskGroups presentes nesta instância do ASM.


ASMCMD> lsdg
State    Type    Rebal  Sector  Logical_Sector  Block       AU  Total_MB  Free_MB  Req_mir_free_MB  Usable_file_MB  Offline_disks  Voting_files  Name
MOUNTED  NORMAL  N         512             512   4096  4194304     20464     9112             5116            1998              0             N  DG_DATA/
MOUNTED  EXTERN  N        4096            4096   4096  1048576      3071     1800                0            1800              0             N  DG_REDO/


Então deve-se navegar nos diretórios até o local desejado com comando "cd":

ASMCMD> cd DG_REDO
ASMCMD> cd CDBRAFA


Para listar os arquivos no diretório, executar "ls -l"

ASMCMD> ls -l

Type         Redund  Striped  Time             Sys  Name
                                               Y    C9D543C047BC6381E053AF58A8C0B946/
                                               Y    C9D5F1F1D0C87A9FE053AF58A8C0B974/
                                               Y    CONTROLFILE/
                                               Y    DATAFILE/
                                               Y    ONLINELOG/
                                               Y    PARAMETERFILE/
                                               Y    TEMPFILE/
CONTROLFILE  HIGH    FINE     OCT 07 11:00:00  N    control01.ctl => +DG_DATA/CDBRAFA/CONTROLFILE/Current.257.1080896789
CONTROLFILE  HIGH    FINE     OCT 07 11:00:00  N    control02.ctl => +DG_DATA/CDBRAFA/CONTROLFILE/Current.258.1080896789
                                               N    pdbrafa/
                                               N    pdbseed/
ONLINELOG    MIRROR  COARSE   OCT 07 15:00:00  N    redo01.log => +DG_DATA/CDBRAFA/ONLINELOG/group_1.259.1080896789
ONLINELOG    MIRROR  COARSE   OCT 07 15:00:00  N    redo02.log => +DG_DATA/CDBRAFA/ONLINELOG/group_2.260.1080896789
ONLINELOG    MIRROR  COARSE   OCT 07 15:00:00  N    redo03.log => +DG_DATA/CDBRAFA/ONLINELOG/group_3.261.1080896789
DATAFILE     MIRROR  COARSE   OCT 07 15:00:00  N    sysaux01.dbf => +DG_DATA/CDBRAFA/DATAFILE/SYSAUX.264.1080896817
DATAFILE     MIRROR  COARSE   OCT 07 15:00:00  N    system01.dbf => +DG_DATA/CDBRAFA/DATAFILE/SYSTEM.262.1080896791
TEMPFILE     MIRROR  COARSE   OCT 07 11:00:00  N    temp01.dbf => +DG_DATA/CDBRAFA/TEMPFILE/TEMP.268.1080896843
DATAFILE     MIRROR  COARSE   OCT 07 15:00:00  N    undotbs01.dbf => +DG_DATA/CDBRAFA/DATAFILE/UNDOTBS1.266.1080896835
DATAFILE     MIRROR  COARSE   OCT 07 15:00:00  N    users01.dbf => +DG_DATA/CDBRAFA/DATAFILE/USERS.270.1080896867


Em seguida, então excluir os arquivos desejados.

Antes de excluir confirmar se o local/caminho é o desejado "pwd"


ASMCMD> pwd
+DG_DATA/CDBRAFA

ASMCMD> rm redo01.log
ASMCMD> rm redo02.log
ASMCMD> rm redo03.log


Ao listar novamente os arquivos no diretório, não existem mais:

ASMCMD> ls -l
Type         Redund  Striped  Time             Sys  Name
                                               Y    C9D543C047BC6381E053AF58A8C0B946/
                                               Y    C9D5F1F1D0C87A9FE053AF58A8C0B974/
                                               Y    CONTROLFILE/
                                               Y    DATAFILE/
                                               Y    PARAMETERFILE/
                                               Y    TEMPFILE/
CONTROLFILE  HIGH    FINE     OCT 07 11:00:00  N    control01.ctl => +DG_DATA/CDBRAFA/CONTROLFILE/Current.257.1080896789
CONTROLFILE  HIGH    FINE     OCT 07 11:00:00  N    control02.ctl => +DG_DATA/CDBRAFA/CONTROLFILE/Current.258.1080896789
                                               N    pdbrafa/
                                               N    pdbseed/
DATAFILE     MIRROR  COARSE   OCT 07 15:00:00  N    sysaux01.dbf => +DG_DATA/CDBRAFA/DATAFILE/SYSAUX.264.1080896817
DATAFILE     MIRROR  COARSE   OCT 07 15:00:00  N    system01.dbf => +DG_DATA/CDBRAFA/DATAFILE/SYSTEM.262.1080896791
TEMPFILE     MIRROR  COARSE   OCT 07 11:00:00  N    temp01.dbf => +DG_DATA/CDBRAFA/TEMPFILE/TEMP.268.1080896843
DATAFILE     MIRROR  COARSE   OCT 07 15:00:00  N    undotbs01.dbf => +DG_DATA/CDBRAFA/DATAFILE/UNDOTBS1.266.1080896835
DATAFILE     MIRROR  COARSE   OCT 07 15:00:00  N    users01.dbf => +DG_DATA/CDBRAFA/DATAFILE/USERS.270.1080896867


Por fim, de forma preventiva, é ajustado o parâmetro de conversão de nomes no PFILE (init) do Standby:

É incluído o caminho da novo DiskGroup no parâmetro "log_file_name_convert", ficando portanto conforme abaixo:

$ORACLE_HOME/dbs/initcdbrafa.ora
/oracle/product/19.0.3/db_home/dbs/initcdbrafa.ora

*.log_file_name_convert='+DG_DATA/CDBRAFA','/ora01/oradata/CDBRAFA','+DG_REDO/CDBRAFA','/ora01/oradata/CDBRAFA'


Atividade finalizada.
