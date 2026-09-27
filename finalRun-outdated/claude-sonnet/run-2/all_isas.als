sig C {
  genls: set C
}

sig E {
  isas: some C,
  all_isas_attr: set C
}

fact genlsAcyclic {
  no c: C | c in c.^genls
}

fact atMostOneParent {
  all c: C | lone genls.c
}

fact atMostOneRoot {
  lone c: C | no genls.c
}

fact allIsasAttrDefinition {
  all e: E | e.all_isas_attr = e.isas.*genls
}

fact noRedundantIsas {
  all e: E | no disj c1, c2: e.isas | c1 in c2.*genls
}