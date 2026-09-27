enum Color { Red, Blue }

sig Node {
  neighbors: set Node,
  color: one Color
}

fact {
  // neighbors is symmetric
  neighbors = ~neighbors

  // no Node is its own neighbor
  all n: Node | n not in n.neighbors

  // the graph is connected
  all n: Node | Node in n.*neighbors

  // the graph is acyclic
  no iden & ^neighbors
}