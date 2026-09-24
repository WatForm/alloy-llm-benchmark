abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
    neighbors: set Node,
    color: one Color
}

fact {
    neighbors = ~neighbors
    all n: Node | n not in n.neighbors
    all n1, n2: Node | n1 in n2.*neighbors
    all n, m: Node | m in n.neighbors implies m not in n.^(neighbors - (n->m + m->n))
}