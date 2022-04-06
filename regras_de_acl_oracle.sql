--#CONSULTAR REGRAS ACL
SET PAGES 1000 LINES 190 LONG 10000
COL ACL FOR A30
COL PRINCIPAL FOR A30
SELECT acl,
       principal,
       privilege,
       is_grant,
       TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date,
       TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date
FROM   dba_network_acl_privileges;




--#CONSULTAR HOSTS DA ACL
SET PAGES 1000 LINES 169 LONG 10000
COL HOST FOR A40
COL ACL FOR A30
SELECT host, lower_port, upper_port, acl
FROM   dba_network_acls;




--------------------------------
--# ACL 12c
--------------------------------

set pages 1000
set lines 190
col host format a20
col lower_port format 99999
col upper_port format 99999
col ace_order format 99999
col start_date format a20
col end_date format a20
col grant format a20
col inverted_principal format a20
col principal format a20
col principal_type format a20
col privilege format a20
select host, lower_port, upper_port, ace_order, start_date, end_date, grant_type, inverted_principal, principal, principal_type, privilege
from dba_host_aces;


set pages 1000
set lines 190
col host format a20
col lower_port format 99999
col upper_port format 99999
col acl format a70
col aclid format a20
col acl_owner format a20
select host, lower_port, upper_port, acl, aclid, acl_owner
from dba_host_acls
order by host;


set pages 1000
set lines 190
col host format a20
col lower_port format 99999
col upper_port format 99999
col status format a20
col privilege format a20
select host, lower_port, upper_port, privilege, status
from user_host_aces
order by host, privilege;
--#CONSULTAR REGRAS ACL 12C
SET PAGES 1000 LINES 190 LONG 10000
COL PRINCIPAL FOR A30
select host,
principal,
privilege,
grant_type,
lower_port,
upper_port,
to_char(start_date, 'DD-MON-YYYY') AS start_date,
to_char(end_date, 'DD-MON-YYYY') AS end_date
from dba_host_aces;




--#CONSULTAR HOSTS DA ACL 12C
SET PAGES 1000 LINES 190 LONG 10000
COL ACL FOR A30
COL ACL_OWNER FOR A20
select acl,
host, lower_port,
upper_port, acl_owner
from dba_host_acls;


exec dbms_network_acl_admin.append_host_ace(host=>'*', ace=>xs$ace_type(privilege_list=>xs$name_list('connect','resolve'), principal_name=>'METISADBA', principal_type=>xs_acl.ptype_db));


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--#CRIAÇÃO DE ACL
EXECUTE dbms_network_acl_admin.create_acl(acl=> 'utl_mail.xml',description => 'Allow mail to be send TASY',principal=> 'TASY',is_grant=> TRUE,privilege=> 'connect');
commit;




--#ADICIONAR OWNERS A ACL
EXECUTE dbms_network_acl_admin.add_privilege(acl=> 'utl_mail.xml',principal => 'TASY',is_grant  => TRUE,privilege => 'resolve');
Commit;
EXECUTE dbms_network_acl_admin.add_privilege(acl=> 'utl_mail.xml',principal => 'TASY',is_grant  => TRUE,privilege => 'connect');
Commit;




--#ADICIONAR HOST A ACL
EXECUTE  dbms_network_acl_admin.assign_acl(acl=> 'utl_mail.xml',host => 'mail.servidor.com.br');
Commit;
EXECUTE  dbms_network_acl_admin.assign_acl(acl=> 'utl_mail.xml',host => '192.168.3.253');
Commit;



--#REMOVE UM HOST DA ACL
EXECUTE  DBMS_NETWORK_ACL_ADMIN.unassign_acl (acl => 'utl_mail.xml', host => '192.168.3.253');
COMMIT;



--# DELETAR UM PRIVIĹÉGIO DA ACL
EXECUTE DBMS_NETWORK_ACL_ADMIN.delete_privilege (acl => 'utl_mail.xml', principal   => 'TASY', is_grant    => TRUE, privilege   => 'connect');
COMMIT;
