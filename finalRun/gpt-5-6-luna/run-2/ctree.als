abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
    neighbors: set Node,
    color: one Color
}

fact {
    neighbors = ~neighbors
    all n: Node | n not in n.neighbors
    all n: Node | Node in n.*neighbors
    all n, m: Node |
        m in n.neighbors implies
            let remaining = neighbors - (n->m + m->n) |
                m not in n.^remaining
}