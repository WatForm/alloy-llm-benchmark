enum Color { Red, Blue }

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no iden & neighbors
  all n: Node | Node in n.*neighbors
  no n: Node | n in n.^neighbors
}