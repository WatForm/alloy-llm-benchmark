sig List {
    header: lone Node
}

sig Node {
    link: lone Node
}

fact {
    all l: List | 
        (l.header = none) or 
        (some n: Node | n in reachable(l.header) && n.link = none)
}

fun reachable(n: Node): set Node {
    n + (n.link.reachable())
}

fun reachable(n: Node): set Node {
    n + (if n.link != none then reachable(n.link) else none)
}