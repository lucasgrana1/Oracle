Block Change Tracking (BCT)

No Oracle 10g foi adicionado a feature do Block Change Tracking (BCT). Com esse recurso habilitado, as alterações que são realizadas nos blocos
são rastreadas através de um arquivo de rastreamento (tracking file).

Os logs das alterações aplicadas, são gravados no tracking file e, no moemtno do backup, o RMAN consulta este arquivo (tracking file) para
identificar quais blocos devem ser feito backup, deixando o backup mais rápido.


O tracking file não deve ser alocado no mesmo disco onde estão os Redo Logs ou os archives

------------------------------------------------------------
--# VERIFICAR SE O BLOCK CHANCE TRACKING (BCT) ESTÁ ATIVADO
------------------------------------------------------------
select *from v$block_change_tracking;


----------------------------------
--# DESCREVER CONTEÚDO DA TABELA
----------------------------------
desc v$block_change_tracking;


-------------------------------------------
--# MENSAGEM SE O PARAMETRO ESTIVER ATIVO
-------------------------------------------

STATUS  FILENAME                   BYTES
------- --------------------- ----------
ENABLED +BLOCKING_TRACK/BCT.F   11599872



------------------
--# ATIVAR O BCT
------------------
ALTER DATABASE ENABLE BLOCK CHANGE TRACKING;


/OBS:/ O tracking file será criado no diretório informado no parametro db_create_file_dest



--------------------
--# DESATIVAR O BCT
--------------------
ALTER DATABASE DISABLE BLOCK CHANGE TRACKING;




---------------------------------------------------------
--# INFORMAR O DIR NO MOMENTO DA HABILITAÇÃO DO RECURSO
---------------------------------------------------------

ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE '+BLOCKING_TRACK/BCT.F';


---------------------------------------------------------
--# CASO O ARQUIVO JÁ EXISTA E QUEREMOS RECRIAR O MESMO
---------------------------------------------------------

ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE '+BLOCKING_TRACK/BCT.F' REUSE;



- Para verificar se o BCT está funcionando corretamente, deve-se verificar na view v$backup_datafile, se existe linhas com valor da coluna USED_CHANGE_TRACKING for 'YES'.

- Essa view pode determinar a efetividade do uso do tracking file no backup incremental.


--# EFETIVIDADE DO TRACKING FILE
SELECT file#,
avg(datafile_blocks),
avg(blocks_read),
avg(blocks_read/datafile_blocks) * 100 as "% read for backup"
FROM v$backup_datafile
WHERE incremental_level > 0
AND used_change_tracking = 'YES'
GROUP BY file#
ORDER BY file#;
