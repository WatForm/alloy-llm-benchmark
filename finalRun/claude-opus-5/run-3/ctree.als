abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact symmetric {
  neighbors = ~neighbors
}

fact irreflexive {
  no n: Node | n in n.neighbors
}

fact connected {
  all n: Node | Node in n.*neighbors
}

fact acyclic {
  all n: Node, m: n.neighbors |
    m not in n.^(neighbors - (n->m) - (m->n))
}