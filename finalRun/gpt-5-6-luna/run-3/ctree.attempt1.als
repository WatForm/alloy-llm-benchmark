abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
    neighbors: set Node,
    color: one Color
}

fact {
    neighbors = ~neighbors
    no (neighbors & iden)
    all n: Node | Node in n.*neighbors
    no a, b: Node |
        a -> b in neighbors and
        b in a.(^(neighbors - (a -> b + b -> a)))
}