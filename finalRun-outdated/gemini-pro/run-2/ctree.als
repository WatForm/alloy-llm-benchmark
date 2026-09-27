abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no iden & neighbors
  all n1, n2: Node | n1->n2 in *neighbors
  all n1, n2: Node | n1->n2 in neighbors implies n1->n2 not in ^(neighbors - n1->n2 - n2->n1)
}