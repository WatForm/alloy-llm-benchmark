abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
    neighbors: set Node,
    color: one Color
}

fact symmetricNeighbors {
    neighbors = ~neighbors
}

fact noSelfNeighbors {
    no n: Node | n in n.neighbors
}

fact connected {
    all n: Node | Node = n.*neighbors
}

fact acyclic {
    #neighbors = 2 * (#Node - 1)
}