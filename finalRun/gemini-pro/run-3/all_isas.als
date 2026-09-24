sig C {
  genls: set C
}

sig E {
  isas: some C,
  all_isas_attr: set C
}

fact {
  no ^genls & iden
  all c: C | lone c.genls
  lone c: C | no c.genls
  all e: E | e.all_isas_attr = e.isas.*genls
  all e: E | no c1, c2: e.isas | c1 != c2 and c1 in c2.*genls
}