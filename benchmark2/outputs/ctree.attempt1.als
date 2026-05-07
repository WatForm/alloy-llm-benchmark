abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact Undirected {
  neighbors = ~neighbors
}

fact AntiReflexive {
  no iden & neighbors
}

fact Connected {
  all n1, n2: Node | n2 in n1.*neighbors
}

fact Acyclic {
  all n1, n2: Node |
    n1 in n2.neighbors implies n1 not in n2.^(neighbors - n2->n1)
}