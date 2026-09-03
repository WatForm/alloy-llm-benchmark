sig E {
	isas : some C,
	all_isas_attr : set C
}

sig C {
	genls : set C
}

fact atMostOneParent {
	all c : C | lone c.genls
}

fact acyclic {
	all c : C | c not in c.^genls
}

fact atMostOneRoot {
	lone c : C | no c.genls
}

fact allIsasAttrDefinition {
	all e : E | e.all_isas_attr = e.isas.*genls
}

fact noRedundantIsas {
	all e : E | all disj c1, c2 : e.isas | c2 not in c1.*genls
}