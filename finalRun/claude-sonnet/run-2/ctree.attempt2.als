abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact Symmetric {
  neighbors = ~neighbors
}

fact NoSelfLoop {
  no n: Node | n in n.neighbors
}

fact Connected {
  all n1, n2: Node | n1 != n2 implies n2 in n1.^neighbors
}

fact Acyclic {
  all n: Node | n not in n.^neighbors
  all disj n1, n2: Node | lone (n1.neighbors & n2.neighbors) or n1 in n2.neighbors
}