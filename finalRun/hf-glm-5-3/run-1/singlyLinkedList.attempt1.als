sig List {
    header: lone Node
}

sig Node {
    link: lone Node
}

fact {
    all l: List |
        some l.header implies
            some n: l.header.*link | no n.link
}