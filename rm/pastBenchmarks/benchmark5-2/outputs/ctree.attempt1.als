abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no iden & neighbors

  all disj n1, n2: Node | n2 in n1.^neighbors

  all disj n1, n2: Node |
    n1->n2 in neighbors =>
      n2 not in n1.^(neighbors - n1->n2 - n2->n1)
}