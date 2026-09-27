abstract sig Color {}
sig Red, Blue extends Color {}

sig Node {
  neighbors: set Node,
  color: one Color
}

fact SymmetricNeighbors {
  neighbors = ~neighbors
}

fact AntireflexiveNeighbors {
  no iden & neighbors
}

fact ConnectedGraph {
  all n1, n2: Node | n2 in n1.*neighbors
}

fact AcyclicGraph {
  all a, b: Node |
    b in a.neighbors implies all c: b.neighbors - a | a not in c.*neighbors
}

run {} for 3 Node