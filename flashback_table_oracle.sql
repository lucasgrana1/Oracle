'--------------------
--# Flashback table
--------------------'

Use a flashback table para restaurar um estado anterior de uma tabela em caso de erro humano ou de aplicativo. O tempo no passado
para o qual a tabela pode ser restaurada depende da quantidade de dados de undo no sistema.

-------------------# Pré-req

Para realizar o flashback de uma tabela para um SCN ou carimbo de data/hora anterior, deve-se ter o privilégio de objeto na tabela
ou o 'FLASHBACK ANY TABLE', alem disso voce deve ter privilégio de leitura na tabela e ter os privilegios de inser,delete e update na mesma.


Para fazer o flashback de uma tabela para um ponto de restauraçaõ. deve-se ter o privilégio do sistema ou a select any dictionary
flashback any tableselect_catalog_role.


-------------------# Semantica

Durante uma operação Flashback table, o Oracle adquire bloqueios DML exclusivos em todas as tabelas especificas na lista flashback
Esses bloqueios impedem qualquer operação nas tabelas enquanto elas estão revertendo para seu estado anterior.

Na conclusão, os dados são consistentes com o tempo anterior, no entando flashback table to scn ou timestamp não preserva rowids
e flashback to before drop não recupera restriçoes referenciais.

-----------------# Schema

Deve-se especificar o schema que contem a tabela, se a opção for omitida o banco assumirá que a tabela está no seu próprio schema.


-----------------# Restrições do Flashback table

Não são válidas para os seguintes tipos de objetos: tabelas que fazem parte de um cluster, view materializada, advanced queuing (AQ tables)
tabelas do dicionario de dados, tabelas do sistema, tabelas remotas, tabelas aninhadas ou partições individuais ou subpartições


----------------# Clausula para SCN

Especifique o SCN correspondente ao momento para qual você deseja retornar a tabela.


---------------# Clausula Timestamp

Especificar um valor de data/hora correspondente ao momento para qual você deseja retornar a tabelas
