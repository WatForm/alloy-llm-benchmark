sig Color {
    Red, Blue
}

sig Node {
    neighbors: set Node,
    color: Color
}

fact {
    // Each Node has exactly one color
    all n: Node | one n.color
    
    // neighbors relation is symmetric
    all n, m: Node | n in m.neighbors iff m in n.neighbors
    
    // No Node is in its own neighbors set
    all n: Node | n !in n.neighbors

    // The graph formed by neighbors is connected
    // Ensuring every node has at least one neighbor
    all n: Node | some m: Node | m in n.neighbors
}

pred acyclic {
    // Acyclic graph condition
    no (n: Node | n in n.neighbors)
}

fact acyclic_fact {
    acyclic
}

run {} for 2 but 5 Node, 2 Color