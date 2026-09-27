sig C {
  genls: set C
}

sig E {
  isas: set C,
  all_isas_attr: set C
}

// The inverse of genls forms a DAG in which every node has
// at most one parent and there is at most one root.
fact genlsDag {
  // acyclic
  all c: C | c not in c.^genls
  // every node has at most one parent (in the inverse graph)
  all c: C | lone c.genls
  // at most one root
  lone { c: C | no c.genls }
}

fact eConstraints {
  all e: E {
    // each E is related by isas to one or more C
    some e.isas
    // all_isas_attr equals the genls-reflexive-transitive closure of isas
    e.all_isas_attr = e.isas.*genls
    // no isas element is reachable from another distinct isas element
    no disj c1, c2: e.isas | c2 in c1.*genls
  }
}