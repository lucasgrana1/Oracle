# HISTORICO DE EXECUCOES DA ROTINA (LOG) #
COL OWNER       FOR A30
COL INICIO      FOR A20
COL FIM         FOR A20
COL STATUS      FOR A15
COL DURACAO     FOR A10
COL METHOD_OPT  FOR A30
COL OPTIONS     FOR A13
select l.owner, to_char(l.begin_collection, 'YYYY-MM-DD HH24:MI') as INICIO
    , to_char(l.end_collection, 'YYYY-MM-DD HH24:MI') as FIM
    , to_char(to_date(mod(ceil((l.end_collection-l.begin_collection)*86400), 86400), 'sssss'),'HH24":"MI":"SS') as DURACAO
    , l.status_collection as STATUS, l.method_opt, l.options
from  luzadm.gather_stats_logs L
where l.begin_collection between (sysdate-1) and (sysdate)
order by INICIO ;
