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
  all nodes: set Node |
    some nodes implies some n: nodes | lone n.neighbors & nodes
}