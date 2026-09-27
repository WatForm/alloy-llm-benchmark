-- all_isas relation from isa relation

open util/relation
open util/graph[C]

sig E
{
  isas: some C,
  all_isas_attr: set C
}
{
	all_isas_attr = all_isas
  no Ci: isas | Ci in (isas-Ci).*genls
}

sig C
{
  genls: set C
}
fact
{ 
  tree[~genls]
}

fun all_isas[Es: set E] : set C
{
	Es.isas.*genls
}

run
{
} for 0 but exactly 1 E, 5 C
