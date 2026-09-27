open util/integer

abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact symmetric {
  neighbors = ~neighbors
}

fact irreflexive {
  no n: Node | n in n.neighbors
}

fact connected {
  all n: Node | Node in n.*neighbors
}

fact acyclic {
  #neighbors = mul[2, minus[#Node, 1]]
}