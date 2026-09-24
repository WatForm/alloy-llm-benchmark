abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no n: Node | n in n.neighbors
  all n1, n2: Node | n1 in n2.*neighbors
  all n1, n2: Node | n1 in n2.neighbors implies n1 not in n2.^(neighbors - (n1->n2 + n2->n1))
}