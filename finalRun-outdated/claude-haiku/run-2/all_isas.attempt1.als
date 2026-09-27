sig E {
  isas: some C,
  all_isas_attr: set C
}

sig C {
  genls: set C
}

// At most one parent per node in the inverse of genls
fact {
  all c: C | lone (genls.c)
}

// genls is acyclic
fact {
  acyclic[genls]
}

// At most one root
fact {
  lone {c: C | no (genls.c)}
}

// all_isas_attr is the reflexive transitive closure of genls from isas
fact {
  all e: E | e.all_isas_attr = e.isas.*(genls)
}

// Elements in isas are mutually unreachable via genls
fact {
  all e: E | all c1, c2: e.isas | c1 != c2 implies c1 not in c2.*(genls)
}