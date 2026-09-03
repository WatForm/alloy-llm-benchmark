abstract sig Color {}
one sig Red extends Color {}
one sig Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact symmetric {
  all n1, n2: Node | n1 in n2.neighbors iff n2 in n1.neighbors
}

fact noSelfLoop {
  all n: Node | n not in n.neighbors
}

fact acyclic {
  all n: Node | n not in n.^neighbors
}

fact connected {
  all n1, n2: Node | n2 in n1.^neighbors or n1 = n2
}