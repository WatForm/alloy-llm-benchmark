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
  #neighbors = 2 * (#Node - 1)
}