[CRIAR SERVICOS - "ALIAS" PARA CONEXAO COM BANCO]


-- criar os servicos
exec dbms_service.CREATE_SERVICE('NewService','DestService');

-- iniciar os servicos
exec dbms_service.start_service('dbhomol_19');

-- habilitar auto-start de todos PDBS
ALTER pluggable BASE ALL save state;

-- fechar o PDB
ALTER pluggable BASE dbhomol close;

-- abrir o PDB
ALTER pluggable BASE dbhomol OPEN services=ALL;

-- criar entrada no TNSNames com novo servico (service_name=dbhomol_19)
-- testar acesso via TNS/servico


--# No 11G
exec dbms_service.create_service('rvtst','rvtst');

--# Start do serviço
exec dbms_service.start_service('rvtst');
