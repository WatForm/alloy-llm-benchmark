sig E {}

sig C {
    genls: set C
}

fact {
    // Each element of C is related by genls to zero or more elements of C
    all c: C | c.genls in C

    // Inverse of genls forms a directed acyclic graph in which every node has at most one parent and at most one root
    no (c: C | c in c.genls) // No cycles
    all c: C | lone parent: C | parent.genls = c // At most one parent
}

sig isas: E -> set C {}
sig all_isas_attr: E -> set C {}

fact {
    // Each element of E is related by isas to one or more elements of C
    all e: E | some e.isas

    // Each element of E is also related by all_isas_attr to zero or more elements of C
    all e: E | all e.all_isas_attr in C

    // Set of C's related to an individual E using all_isas_attr equals the reachable C's from isas via genls
    all e: E | e.all_isas_attr = 
        { c: C | c in e.isas or some g: C | g in e.isas && g in c.genls }
}

fact {
    // For every element of E, no element of its isas set is reachable by zero or more genls steps from another distinct element of its isas set
    all e: E | 
        no c1, c2: C | 
           c1 in e.isas and c2 in e.isas and c1 != c2 and 
           (c2 in { g: C | g in c1.genls })
}