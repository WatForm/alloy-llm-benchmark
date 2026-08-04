sig List {
    header: lone Node
}

sig Node {
    link: lone Node
}

fact {
    // Ensuring that for every List, either it has no header or
    // among the nodes reachable from the header, there is at least one node with no link
    all l: List | 
        (l.header = none) or 
        (some n: Node | n in reachable(l.header) && n.link = none)
}

fun reachable(n: Node): set Node {
    n + link.n.reachable(n.link)
}