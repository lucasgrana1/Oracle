--# VER CONFIG MEMORIAS (+ exemplo valores)
show parameter pool
  shared_pool_size     > Shared Pool  : 2048 MB
  java_pool_size       > Java Pool    :  128 MB
  large_pool_size      > Large Pool   : 1024 MB
  streams_pool_size    > Streams Pool :  256 MB

show parameter pga
  pga_aggregate_target > PGA Size     : 2048 MB

show parameter db_cache
  db_cache_size        > Buffer Cache : 2048 MB
