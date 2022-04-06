---------------------
--# COMMON USER
---------------------


Oracle oferece uma nova opḉão em ambientes Multitenant(PDB's)' que permite a consolidação de forma simplificada.


Nestes ambientes temos 2 tipos de usuários, roles e privilégios.


--# USUARIOS

-> Common User: Usuário que está presente em todos os containers.

-> Local User: Usuário que está presente em apenas um PDB.


--# ROLE

-> Common Role: Role que está presente em todos os containers.

-> Local Role: Role que está presente em apenas um PDB.




---------------------------------------------------------------------
--- CRIAÇÃO DE COMMON USERS
---------------------------------------------------------------------


-> Deve-se estar conectado no cdb$root e o prefixo deve respeitar o parametro do banco 'common_user_prefix'.



--# COMANDO PARA VERIFICAR ESTE PARAMETRO

select name, value from v$parameter where name like 'common%';



--# CRIANDO O USUÁRIO

Create user c##usuario identified by 123 container=all;


Obs: Por default, quando estamos no cdb$root, será utilizada a opção container=all



--# VERIFICAR CRIAÇÃO DO USUÁRIO

SELECT USERNAME, CON_ID FROM CDB_USERS WHERE USERNAME LIKE 'C##%' ORDER BY 2,1;





------------------------------------------
--# CONCEDER PRIVILÉGIOS A COMMON USERS
------------------------------------------


GRANT CREATE SESSION TO C##USUARIO CONTAINER=ALL;
