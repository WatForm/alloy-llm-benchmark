sig C {
    genls: set C
}

sig E {
    isas: some C,
    all_isas_attr: set C
}

fact {
    // The inverse of "genls" forms a directed acyclic graph in which every node has at most one parent and there is at most one root.
    no c: C | c in c.^genls
    all c: C | lone c.genls
    lone c: C | no c.genls

    // The set of "C"s that related to an individual "E" using "all_isas_attr" is equal to the set of "C"s resulting from the "C"s that can be reached in zero or more steps of "genls" starting from the "C"s that are connected to the "E" via "isas".
    all e: E | e.all_isas_attr = e.isas.*genls

    // For every element of "E", there is no element of its "isas" set that is reachable by zero or more "genls" steps from another distinct element of its "isas" set.
    all e: E | no disj c1, c2: e.isas | c1 in c2.*genls
}