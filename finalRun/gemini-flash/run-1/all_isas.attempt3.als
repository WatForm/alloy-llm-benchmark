sig C {
	genls: set C
}

sig E {
	isas: some C,
	all_isas_attr: set C
}

fact {
	all c: C | c not in c.^genls
	all c: C | lone c.genls
	lone c: C | no c.genls
	all e: E | e.all_isas_attr = e.isas.*genls
	all e: E | all c1, c2: e.isas | (c1 != c2) implies (c1 not in c2.*genls)
}