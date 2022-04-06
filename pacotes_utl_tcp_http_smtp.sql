-------------
--# UTL_TCP
-------------

Possibilita que programas atuem como clientes em uma comunicação com um servidor TCP/IP, com este pacote os programas podem se comunicar com outros servidores para envio ou recebimento de informaçoes.


-> Exemplo:

O pacote UTL_HTTP utiliza o pacote UTL_TCP abrindo uma conexão TCP/IP na porta 28 onde o servidor web fica aguardando requisições, o mesmo ocorre com o pacote UTL_SMTP
que abre uma conexão TCP/IP na porta 25 onde um servidor SMTP fica na escuta.


--# PRIVILÉGIO
GRANT EXECUTE ON SYS.UTL_TCP TO USERNAME;



-------------
--# UTL_HTTP
-------------

Comunicação com servidores web (HTTP Server), a comunicação ocorre por meio dos protocolos HTTP e HTTPS.

Essa package possibilita enviar uma requisição a um servidor web e receber uma resposta.


--# PRIVILÉGIO
GRANT EXECUTE ON SYS.UTL_HTTP TO USERNAME;


-------------
--# UTL_SMTP
-------------

Essa package é para envio de e-mails de dentro de programas PL/SQL por meio do protocolo SMTP.

O protocolo SMTP só possibilita o envio de mensagens eletrônicas, sendo assim, não é possível o recebimento de e-mails de dentro de programas PL/SQL.


--# PRIVILÉGIO
GRANT EXECUTE ON SYS.UTL_SMTP TO USERNAME;
