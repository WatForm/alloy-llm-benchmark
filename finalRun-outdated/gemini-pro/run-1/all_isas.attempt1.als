sig E {
  isas: some C,
  all_isas_attr: set C
}

sig C {
  genls: set C
}

fact {
  no c: C | c in c.^genls
  all c: C | lone c.genls
  lone c: C | no c.genls
}

fact {
  all e: E | e.all_isas_attr = e.isas.*genls
}

fact {
  all e: E | no c1, c2: e.isas | c1 != c2 and c2 in c1.*genls
}