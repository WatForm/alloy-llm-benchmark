abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact SymmetricNeighbors {
  neighbors = ~neighbors
}

fact Irreflexive {
  no (neighbors & iden)
}

fact Connected {
  all n: Node | Node in n.*neighbors
}

fact Acyclic {
  #neighbors = mul[2, minus[#Node, 1]]
}