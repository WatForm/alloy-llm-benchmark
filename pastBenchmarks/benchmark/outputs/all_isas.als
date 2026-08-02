sig C {
  genls: set C
}

sig E {
  isas: some C,
  all_isas_attr: set C
} {
  no ci: isas | ci in ci.^(genls - ci->ci)
}

fact GenlsInverseIsTree {
  lone ~genls
  one root: C | no root.~genls and C in root.*(~genls)
}

fun all_isas[Es: set E]: set C {
  Es.isas.*genls
}

run {} for exactly 1 E, exactly 5 C