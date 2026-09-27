abstract sig Color {}

one sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  neighbors = ~neighbors
  no n: Node | n in n.neighbors

  all disj n, m: Node | m in n.^neighbors

  all n: Node |
    all disj a, b: n.neighbors |
      b not in a.^(neighbors - (n -> Node) - (Node -> n))
}