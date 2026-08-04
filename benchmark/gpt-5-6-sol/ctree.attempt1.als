abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no iden & neighbors

  all disj n1, n2: Node |
    n2 in n1.^neighbors

  all n: Node |
    no disj n1, n2: n.neighbors |
      n2 in n1.^(neighbors - (n -> Node + Node -> n))
}