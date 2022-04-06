------------------------
--# Oracle PDB's 12c
------------------------

Database Type container (CDB): É um banco que tem a capacidade de armazenar logicamente vários bancos de dados, estes bancos internos
são chamados de PDB "pluggable database"..


Database Type Pluggable (PDB): Um PDB é um conjunto de esquemas de bancos de dados, isso significa que cada PDB não tem a sua
própria instância, mas os "N" PDBs que existem dentro de um CDB compartilham a mesma instância.


------------------# Características das versões 12c

-> Anteriores ao 12c todos são "non-cdb".
-> Iniciado na versão 12c, o banco pode ser do tipo Container ou pode continuar sendo "non-cdb".
-> Suporta a arquitetura multitenant que permite diversos sub bancos dentro de m banco "mestre".
-> Um container chamado "ROOT" (cdb$root) possui as tablespaces SYSTEM, SYSAUX, UNDO E TEMP, e com isso os controlfiles e redo logs
-> Um container chamado "SEED" (PDB$SEED) possui as tablespaces SYSTEM, SYSAUX, TEMP E EXAMPLE.
-> todo CDB possui um SEED e um ROOT
-> Seed não pode ser aberto no modo 'read-write'



------------------# Características dos PDBs

-> Permite que DBAs consolidem um grande numero de aplicações de banco em uma unica instalação de software
-> Cada PDB pode manter seus próprios usuários
-> Um PDB mantem seus dados e o codigo das aplicações, mantem seus próprios metadados dentro das tablespaces SYSTEM, SYSAUX e opcionalmente TEMP.
-> Cada PDB possui um identificador unico dentro do CDB
-> Um PDB pode ser criado com base um um SEED
-> Um PDB pode ser criado com base em um banco non-cdb
-> É possível criar diversas tablespaces dentro de um PDB, mas o PDB sempre usara os controlfiles, e a tablespace UNDO e os arquivos de redo logs do CDB.
-> Os PDBs podem ser removidos de um CDB e logo em seguida plugados em outro CDB.
-> Os dados de undo e redo dos PDBS serão agregados dentro dos arquivos de redo logs do CDB. Golden Gate 12c foi modificado para que possa entender este tipo de arquivo de redo.


------------------# Vantagens de utilizar CDBs e PDBs

-> Consolida a utilização múltiplas instâncias de bancos dentro de uma unica, centralizada, evitando que os processos e estruturas de memória sejam duplicados N vezes, onde N é o numero de banco de dados
-> O tempo do DBA é otimizado para terefas como atualização de veroa e aplicação de patches
-> Não é necessário realizar nenhuma alteração nas aplicações para poder utilizar um PDB, pois é apresentado ao usuário como independente
-> O provisionamento de bancos é rápido e fácil, por ter opções de "clone, plug e unplug"
-> É compatível com RAC
-> Em um servidor é preferível criar um maior numero de PDBs do que instâncias.

