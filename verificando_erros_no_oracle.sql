-- olhar no alertlog as linhas mais recentes (ultimas 2 semanas, por exemplo)
$ vi /oracle/diag/rdbms/condor/condor/trace/alert_condor.log

:set number

212562 Thu Nov 11 00:05:02 2021
233546 Archived Log entry 180056 added for thread 1 sequence 180872 ID 0x18bbfd36 dest 1:

-- ver qtde de linhas
233546 - 212562 = 20984

-- gerar arquivo somente com estas linhas
$ tail -22000 /oracle/diag/rdbms/condor/condor/trace/alert_condor.log > tmp.log

-- buscar por erros
$ cat tmp.log | egrep -i 'ORA-|erro|fail|warn' > tmp.err

-- analise inicial dos erros para remover erros "simples/banais"
$ vi tmp.err

-- remover erros nao criticos
$ cat tmp.err | egrep -v 'Fatal NI|struct|result' > tmp.err2

-- exemplos
WARNING: too many parse errors, count=72160 SQL hash=0x8f722678
PARSE ERROR: ospid=55579, error=923 for statement:
Fatal NI connect error 12170.
  Tns error struct:
  Result = ORA-0
opiodr aborting process unknown ospid (379168) as a result of ORA-28

-- verificar novamente
$ vi tmp.err2

$ cat tmp.err2
