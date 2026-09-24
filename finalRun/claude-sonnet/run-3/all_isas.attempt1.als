sig E {
	isas: some C,
	all_isas_attr: set C
}

sig C {
	genls: set C
}

fact GenlsDAG {
	all c: C | lone c.genls
	no c: C | c in c.^genls
	lone c: C | no c.genls
}

fact AllIsasAttrDefinition {
	all e: E | e.all_isas_attr = e.isas.*genls
}

fact IsasAntichain {
	all e: E | no disj c1, c2: e.isas | c2 in c1.*genls
}