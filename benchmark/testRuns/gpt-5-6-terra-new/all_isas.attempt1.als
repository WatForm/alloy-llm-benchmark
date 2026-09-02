sig E {
  isas: some C,
  all_isas_attr: set C
}

sig C {
  genls: set C
}

fact {
  no iden & ^(~genls)
  all c: C | lone (~genls).c
  lone { c: C | no (~genls).c }
  all e: E | e.all_isas_attr = e.isas.*genls
  all e: E | no disj c1, c2: e.isas | c2 in c1.*genls
}