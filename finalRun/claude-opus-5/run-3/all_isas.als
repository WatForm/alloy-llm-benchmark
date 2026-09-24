module ontology

sig E {
	isas : some C,
	all_isas_attr : set C
}

sig C {
	genls : set C
}

fact disjointSets {
	no E & C
}

fact genlsDAG {
	// acyclic
	no c : C | c in c.^genls
	// every node has at most one parent in the inverse graph
	all c : C | lone c.genls
	// at most one root
	lone c : C | no c.genls
}

fact allIsasAttrDefinition {
	all e : E | e.all_isas_attr = e.isas.*genls
}

fact noRedundantIsas {
	all e : E | all disj c1, c2 : e.isas | c2 not in c1.*genls
}