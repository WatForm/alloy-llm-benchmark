open util/relation
open util/graph[C]

sig C {
  genls: set C
} {
  tree[~genls]
}

sig E {
  isas: some C,
  all_isas_attr: set C
} {
  all ci: isas |
    ci not in (isas - ci).^genls
}

fun all_isas[Es: set E]: set C {
  Es.isas.*genls
}