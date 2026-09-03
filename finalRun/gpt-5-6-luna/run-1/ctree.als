abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no n: Node | n in n.neighbors
  all n: Node | Node in n.*neighbors
  no n: Node | n in n.^neighbors
}