abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no iden & neighbors
  all n: Node | Node in n.*neighbors
  all n: Node | no disj a, b: n.neighbors | a in b.^(neighbors - (n->Node + Node->n))
}