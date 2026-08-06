sig E {
	isas : some C,
	all_isas_attr : set C
}

sig C {
	genls : set C
}

fact {
	no E & C
}

// The inverse of genls is a DAG where every node has at most one parent
fact {
	all c : C | lone c.genls
	no c : C | c in c.^genls
}

// at most one root
fact {
	lone c : C | no c.genls
}

fact {
	all e : E | e.all_isas_attr = e.isas.*genls
}

fact {
	all e : E | all disj c1, c2 : e.isas | c1 not in c2.*genls
}