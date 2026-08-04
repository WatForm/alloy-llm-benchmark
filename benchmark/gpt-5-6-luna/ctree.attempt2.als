abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  #Color = 2
  neighbors = ~neighbors
  no iden & neighbors
  all n: Node | Node in n.*neighbors
  no n: Node | n in n.^neighbors
}