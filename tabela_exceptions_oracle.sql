---------------------------------
--# Criar a tabela de exceptions
---------------------------------

@?/rdbms/admin/utlexcpt.sql


--# Inserir na tabela de exceções
exceptions into exceptions


--# Conectar com o replica
conn replica

--# habilitar a constraint
alter table TEXTIL5.MQOP_045 enable validate constraint SYS_C0076625 exceptions into replica.exceptions;

--# verificar na tabela de exceptions
select * from replica.exceptions;
