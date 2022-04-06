-------------------
--# Oracle Tuning
-------------------


-> Tuning: Top Ten Mistakes

  1. Gerenciamento ruim de conexoes
  2. Uso incorreto de cursores e do shared pool
  3. Bad SQL
*  4. Uso de parametros de inicialização não padronizados
*  5. Obtendo I/O errado do banco de dados
*  6. Problemas de configuração do redo log online
*  7. Serialização de blocos de dados no buffer cache devido a falta de "free lists", grupos de "free lists", slots de transação (INITRANS) ou falta de argumentos de rollback
*  8. Longos table scans
  9. Altas quantidades de SQL recursivo (SYS)
*  10. Erros de implantação e migração


--# Tempo Computacional

R=S+W


Response Time = Service Time + Wait Time



--# Evolucação dos Waits Events Oracle OWI

-> Versão 7.0.12: 104 Wait Events
-> Versão 8: 140
-> Versão 8i: 220
-> Versão 9i: ~400
-> Versão 10gR1: ~800
-> Versão 11gR2: ~1100
-> Versão 12cR1: ~1650
-> Versão 12cR2: ~1800



'----------------------------
--# Wait Events mais comuns
----------------------------'

● buffer busy / read by oher session / latch: cache buffers chains

● free buffer

● control file single write / control file parallel write / control file sequential read

● db file single write / db file parallel read / db file parallel write / db file async I/O submit

● db file scatteread read / db file sequential read

● direct path read / direct path write

● enqueue

● free buffer

● latch free / latch: shared pool / latch: library cache

● library cache pin / library cache lock

● log buffer space

● log file parallel write / log file single write / log file sequential read

● log file switch (archiving needed)

● log file switch (checkpoint incomplete) / log file switch completion

● log file sync

● SQL*Net message from client / SQL*Net message to client

● SQL*Net more data from client / SQL*Net more data to client

● SQL*Net break/reset from client / SQL*Net break/reset to client



--# Análise de desempenho


-> Granularidades de análise

   ● SQL Statement
   ● Session
   ● Instance


-> Cenários de Análise

   ● Há lentidão agora?
   ● Tivemos lentidão ontem.


-> Ferramentas de análise

    ● Dynamic Performance Views
    ● Extended SQL Trace (Event 10046)
    ● Statspack/AWR



--# OBSERVAÇÃO:

Ao criar uma tabela de testes, e duplicar os registros...

Enquanto os inserts executam, verifiquei a V$session_wait.

Observado que a maior parte do tempo é gasta esperando retorno do usuário "SQL*Net message from client"


--# Utilizado os comandos simples abaixo:

SELECT SID FROM V$SESSION WHERE USERNAME = 'LUCASG';


SELECT EVENT, TIME_WAITED FROM V$SESSION_EVENT WHERE SID = 279
ORDER BY TIME_WAITED;


Realizado um CTAS

create table xpto as select *from teste;

Visto que após essa criação foram gerados mais esperas do evento "db file sequential read"




---------------------------------------------------------
--# Comandos para ajudar a nivel de sistema operacional
---------------------------------------------------------

vmstat   iostat

iotop    iftop

smem     hdparm -tT /dev/sda



'###############################
--# Huge pages/large pages
###############################'

Conferir detalhes em: (hugepages for Oracle on Linux)

https://oracle-base.com/articles/linux/configuring-huge-pages-for-oracle-on-linux-64

