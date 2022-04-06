--# CRIANDO UMA TABELA TEMPORÁRIA (APÓS O FIM DA SESSÃO OS DADOS SÃO REMOVIDOS DA TABELA)
create global temporary table TEMP_TESTE
(cod_prod number(5),
desc_prod varchar2(30),
dat_cadas date) on commit preserve rows;


--# INSERIR DADOS
insert into TEMP_TESTE
values (100,'Computador',sysdate);


--# VERIFICAR DADOS NA TABELA
select * from TEMP_TESTE;



--# CONFIRMAR
commit;


--# CANCELAR
rollback;


--# VER SE FICOU GRAVADO
select * from TEMP_TESTE;



--# DESCONECTAR DA BASE
exit


--# CONECTAR NOVAMENTE


--# VERIFICAR SE FICARAM REGISTROS NA TABELA
select * from TEMP_TESTE;


--# VER A ESTRUTURA DA TABELA
desc TEMP_TESTE;


--# EXCLUIR A TABELA
DROP TABLE TEMP_TESTE;
