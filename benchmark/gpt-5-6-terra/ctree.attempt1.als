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
  all n: Node, m: n.neighbors |
    m not in n.*(neighbors - n->m - m->n)
}