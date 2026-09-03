sig E {
    isas: some C,
    all_isas_attr: set C
}

sig C {
    genls: set C
}

fact noCycles {
    no c: C | c in c.^(genls)
}

fact atMostOneParent {
    all c: C | lone (~genls)[c]
}

fact atMostOneRoot {
    lone {c: C | no (~genls)[c]}
}

fact all_isas_attr_closure {
    all e: E | e.all_isas_attr = e.isas.*(genls)
}

fact isasAntichain {
    all e: E | all c1, c2: C | 
        (c1 in e.isas and c2 in e.isas and c1 != c2) implies (c1 not in c2.*(genls))
}