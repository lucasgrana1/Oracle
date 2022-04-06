--# Habilitar trace dos comandos que vou fazer
set autotrace traceonly explain



--# Desabilitar o autotrace
set autotrace off


--# Ativar a captura dos melhores planos de execução
alter session set optimizer_capture_sql_plan_baselines = true;



 (0) Full table scan: Caminho de acesso em que os dados são recuperados percorrendo todas as linhas de uma tabela.
     É mais eficiente para recuperar uma grande quantidade de dados da tabela.

(1) Index Lookup: Caminho de acesso em que os dados são recuperados através do uso de índices. É mais eficiente para recuperar
    um pequeno conjunto de linhas da tabela.

(2) Nested loop join: Método de acesso de ligação (join) entre 2 tabelas ou origens de dados, utilizado quando pequenos
    conjuntos de dados estão sendo ligados e se a condição de ligação é um caminho eficiente para acessar a segunda tabela.

(3) Hash join: Método de acesso de ligação (join) entre 2 tabelas ou origens de dados, utilizado para ligar grandes conjuntos de dados.


'------------------------------
--# Plano de execução Oracle
------------------------------'


-> O que é:


Antes de realizar um SELECT na base, o otimizador traça um plano de execução, de modo a avaliar que dados recolher, onde e como os deve obter.

O plano de execução é influenciado por múltiplos fatores e varia ao longo do tempo, isto é, varia consoante o estado presente da base.


--# Principais fatores

-> Dimensão das tabelas
-> Diversidade de dados das tabelas (selectividade)
-> Existência ou não de índices


O otimizador obtem essas informações através das estatísticas da base, elas registram os principais fatores que definem o plano de execução.

Dessa forma, ao invés de percorrer todos os dadis afetados pelo SELECT, já tem uma ideia do que vai encontrar porém, para que as
estatísticas produzam bons resultados nas queries, é fundamental que estejam atualizadas.


-> Exemplo: Se a estatística nos diz que uma tabela tem 10 registros mas, entretanto, carregamos um milhão de novos registros, a estatística
produzirá valores errados e induzirá um caminho que não é o melhor.



--# Criar a tabela PLAN_TABLE

Os planos são registrados em uma tabela, usualmente definida como PLAN_TABLE, sob a forma de linhas com relações hiuerarquicas entre si.
Por isso é possível registrar vários planos de execução na PLAN_TABLE.


A PLAN_TABLE poderá não estar disponível no ambiente, a Oracle fornece um script que permite criar essa tabela facilmente, este script pode
ser encontrado em "/ORACLE_HOME/rdbms/admin/UTLXLPAN.SQL"

Tendo a garantisa de que a tabels , devemos limpar seu conteúdo, recorrendo a instrução "TRUNCATE TABLE PLAN_TABLE".




--# Determinar o plano de execução


Primeiramente devemos registrar o plano de execução na PLAN_TABLE, recorrendo a instrução EXPLAIN PLAN SET STATEMENT_ID='XPTO' FOR, seguida
da query que queremos analisar, por exemplo:

EXPLAIN PLAN SET STATEMENT_ID = 'XPTO' FOR
SELECT C.COD_ASSOC FROM ASSOCIADOS A INNER JOIN CARTOES C ON C.COD_ASSOC = A.CODIGO
WHERE A.CODIGO BETWEEN 21000 AND 21500;


O statement_id atribuído é o identificador do plano do tipo varchar2. O plano está criado e podemos continuar a determinar os planos
de execução de outras queries ou, por exemplo, verificar os planos antes e após o cálculo das estatísticas. Os planos ficam registrados
na tabela e só seo eliminados manualmente, pelo que se poderão guardar os registros para consulta futura.




--# Analisar o plano de execução

Se a PLAN_TABLE é uma tabela, a visualização do plano de execução é feita com um SELECT à mesma tabela. Alguns editores SQL de Oracle
já possuem essa funcionalidade a um clique. O que fazem é executar um dos muitos "SELECTs" possíveis à tabela. O Oracle facilita a consulta
dos planos através da seguintes instrução, já adaptada ao comando feito acima, com o respectivo statement_id:

SELECT *FROM TABLE (dbms_xplan.display('plan_table','xpto','all'));

O resultado da query foi salvo no arquivo: /home/usuf01/LUCAS GRANA/Informacoes/Oracle/plan_exec_resultado_exemplo




-> A forma correta de ler o mapa do plano é começar pela instrução mais à direita (maior nível). Quando duas instruções estão ao mesmo nível,
começa-se pela que tem o id menor. Neste caso, vemos que a primeira instrução a ser executada foi a nº2 .




Vejamos, primeiro, as colunas da PLAN_TABLE apresentadas nesta query:


-> ID: identificador da linha da instrução do presente plano. Atenção, não é o id da linha na PLAN_TABLE, mas sim o id da amostra de dados
retirada dessa mesma tabela. Lembremo-nos que a PLAN_TABLE pode conter vários planos de execução.


-> Operation: O tipo de instrução a ser executada

-> Name: Tabela ou indice a que se refere a operation

-> Rows: Número de linhas afetadas ou acedidas

-> Bytes: Total de bytes que serão movimentados para ler os dados da instrução

-> Cost: O custo de cPU para a instrução. Esse campo não tem qualquer unidade, pelo que o mesmo deverá ser utilizado como meio de comparação

   Exemplo: Comparando o Cost CPU de uma query leve com uma query mais pesada. Este valor é parametrizado num ficheiro de configuração
   do Oracle e sua compreensão mais profunda seria alvo de um tema de administração de base de dados.


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Note-se que os campos apresentados pela função do Oracle não correspondem aos campos da PLAN_TABLE em bruto. A função não faz mais
do que criar uma VIEW com a selecção de dados da tabela do plano de execução.

Analisemos, agora, a informação apresentada para este plano. Os IDs 2 e 3 estão sob a operação de junção NESTED LOOPS
este é um dos tipos de junção de tabelas que consiste em:


(2) Escolher a tabela sem indice na condição, neste caso a tabela CARTOES que não possui um indice no campo de junção COD_ASSOC. É feito um
FULL TABLE SCAN filtrando as linhas com a condição:


filter("C"."COD_ASSOC"<=21500 AND "C"."COD_ASSOC">=21000)


Repare-se no * antes do 2, referente à nota em baixo (Predicate Information), que indica o filtro no SCAN com os números de código do SELECT:

WHERE A.CODIGO BETWEEN 21000 AND 21500;


(3) Para cada uma das 514 linhas da tabela anterior, já filtrada, é feito um acesso ao índice da tabela ASSOCIADOS,
ASSOCIADOS_PK, obtendo apenas os dados com:

filter("A"."CODIGO"<=21500 AND
"A"."CODIGO">=21000)



Tendo em conta que cada linhas das duas tabelas são cruzadas obedecendo ao match:

access("C"."COD_ASSOC"="A"."CODIGO")



(1) O Oracle pode agora juntar as tabelas, fazendo o INNER JOIN através do algoritmo de NESTED LOOPS.

Obtêm-se 394 linhas, no final, e terão sido acedidos 3940 bytes.





--# Conclusão

É uma ferramenta poderosa para fazer uma avaliação prévia do impacto da nossa query na base de dados.

Seja para avaliar o impacto de uma query num ambiente de produção em alturas criticas ou simplesmente para otimizar e procurar queries
com menor consumo de CPU ou IO.


Há casos específicos que necessitam de especial atenção e de uma avaliação pós-processamento através de outra ferramenta, o SQL Trace.
O SQL Trace vai registar as operações realizadas pelo Oracle, permitindo-nos analisar detalhadamente o que ocorreu no SELECT enquanto
o plano de execução permite fazer uma avaliação a priori, o SQL Trace faz uma avaliação a posteriori.


frisar que, para que o plano de execução seja o mais fiel possível, as estatística deverão estar atualizadas, o que nem sempre é possível
ou viável se a dimensão das bases de dados for muito grande.







--# Não é possível realizar este tipo de select na tabela de plano de execução

SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
COL STATEMENT_ID FOR A30
COL PLAN_ID FOR FOR 99999
COL DATA FOR A17
COL OPERATION FOR A30
COL OWNER_OBJETO FOR A30
COL OBJECT_TYPE FOR A20
select statement_id, plan_id,
to_char(timestamp,'YYYY-MM-DD HH24:MI:SS') as data
operation,
object_owner ||','|| object_name as owner_objeto
object_type,
bytes,
cost as custo,
cardinality as cardinalidade,
temp_space,
time
FROM PLAN_TABLE
--WHERE STATEMENT_ID='TESTE'
--AND TIMESTAMP >= sysdate-2
--and object_name in ('XPTO')
--and object_type in ('XYZ')
ORDER BY COST DESC;
