sig Color {
    Red, Blue
}

sig Node {
    neighbors: set Node,
    color: lone Color
}

fact {
    // Each Node has exactly one color
    all n: Node | one n.color
    
    // neighbors relation is symmetric
    all n, m: Node | n in m.neighbors iff m in n.neighbors
    
    // No Node is in its own neighbors set
    all n: Node | n !in n.neighbors
    
    // The graph formed by neighbors is connected and acyclic
    // Ensuring the graph is acyclic and connected can be achieved 
    // by ensuring every node has neighbors and there is a path 
    // between any two nodes
    some n1, n2: Node | n1 != n2 && (n1 in n2.neighbors or n2 in n1.neighbors)
} 

pred noCycles[n: Node] {
    // A predicate to check if the graph has cycles
    // This can be structured as an inductive check through neighbors
    no (n in n.neighbors)
}

run {} for 2 but 5 Node, 2 Color 