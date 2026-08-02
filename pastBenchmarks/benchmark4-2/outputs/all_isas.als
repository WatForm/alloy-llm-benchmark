sig C {
  genls: set C
}

sig E {
  isas: some C,
  all_isas_attr: set C
}

fact {
  no (iden & ^(~genls))
  one { c: C | no (~genls).c }

  all e: E | e.all_isas_attr = e.isas.*genls

  all e: E | no disj c1, c2: e.isas | c1 in c2.*genls
}