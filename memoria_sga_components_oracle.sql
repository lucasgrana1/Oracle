-------------------
--# SGA Components
-------------------


'*****************
-> Buffer cache
*****************'

É um componente da SGA que atua como buffer para armazenar quaisquer dados que estão sendo consultados ou modificados.
Todos os clientes conectados ao banco de dados compartilham o acesso ao buffer cache.

    -> Ajuda a evitar acessos repetidos no disco físico, que é mais demorado.


'***************
-> Shared pool
***************'

A shared pool armazena em cache informações operacionais e códigos que podem ser compartilhados entre os usuários.


--> Exemplos:

   -> As instruções SQL são armazenadas em cache para que possam ser reutilizadas.

   -> As informações do dicionário de dados, como dados da conta do usuário, descrições de tabela e índice e privilégios são
      armazenadas em cache para acesso rápido e reutilização.

   -> Os procedimentos armazenados são armazenados em cache para acesso mais rápido.



'******************
-> Redo log buffer
*******************'

O redo log buffer melhora o desempenho armazenando em cache as informações de redo (usadas para recuperação de instância)
até que possam ser gravadas imediatamente e em um momento mais oportuno nos arquivos de redo log físicos armazenados no disco.




'**************
-> Large pool
**************'

É uma área opcional usada para armazenar em buffer grandes solicitações de I/O para vários processos do servidor.
