abstract sig Color {}
one sig Red extends Color {}
one sig Blue extends Color {}

sig Node {
    neighbors: set Node,
    color: one Color
}

fact symmetric_neighbors {
    neighbors = ~neighbors
}

fact no_self_neighbors {
    no n: Node | n in n.neighbors
}

fact connected_acyclic {
    all n1, n2: Node | n1 != n2 implies n1 in n2.^neighbors
    no n: Node | n in n.^neighbors
}