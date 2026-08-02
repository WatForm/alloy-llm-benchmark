abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no iden & neighbors
  all disj n, m: Node | m in n.^neighbors
  all disj n, m: Node | m in n.neighbors implies m not in n.^(neighbors - (n->m + m->n))
}