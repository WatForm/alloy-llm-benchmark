sig C {
  genls: set C
}

sig E {
  isas: some C,
  all_isas_attr: set C
}

fact {
  no c: C | c in c.^(~genls)
  all c: C | lone c.genls
  lone { c: C | no c.genls }

  all e: E |
    e.all_isas_attr = e.isas.*genls

  all e: E |
    all disj c1, c2: e.isas |
      c1 not in c2.*genls
}