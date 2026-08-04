abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
    neighbors: set Node,
    color: one Color
}

fact {
    neighbors = ~neighbors
    no iden & neighbors
    all n: Node | Node in n.*neighbors
    no n: Node |
        some disj a, b: n.neighbors |
            b in a.^(neighbors & ((Node - n) -> (Node - n)))
}