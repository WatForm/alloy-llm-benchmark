module SinglyLinkedList

sig List {
  header : lone Node
}

sig Node {
  link: lone Node
}

fact Acyclic {
    all l: List | no l.header or some n: l.header.*link | no n.link
}
