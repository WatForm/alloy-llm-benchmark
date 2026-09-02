abstract sig Color {}
one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no n: Node | n in n.neighbors
  all n1, n2: Node | n2 in n1.*neighbors
  all s: set Node |
    some s implies some n: s | lone (n.neighbors & s)
}