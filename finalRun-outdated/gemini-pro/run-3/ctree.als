abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no neighbors & iden
  
  all n1, n2: Node | n1 in n2.*neighbors
  all n1, n2: Node | n1->n2 in neighbors implies n2 not in n1.^(neighbors - (n1->n2 + n2->n1))
}