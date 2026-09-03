sig E {
  isas: some C,
  all_isas_attr: set C
}

sig C {
  genls: set C
}

fact genlsDAG {
  no c: C | c in c.^genls
  all c: C | lone c.genls
  lone c: C | no c.genls
}

fact allIsasAttrDef {
  all e: E | e.all_isas_attr = e.isas.*genls
}

fact isasAntichain {
  all e: E | all c1, c2: e.isas | c1 != c2 implies c2 not in c1.*genls
}