sig C {
  genls: set C
}

sig E {
  isas: some C,
  all_isas_attr: set C
}

fact {
  no iden & ^(~genls)

  all c: C | lone (~genls).c

  lone { c: C | no (~genls).c }

  all e: E | e.all_isas_attr = e.isas.*genls

  all e: E |
    no c, d: e.isas |
      c != d and c in d.*genls
}