sig List {
  header: lone Node
}

sig Node {
  link: lone Node
}

fact {
  all l: List |
    no l.header or some n: l.header.*link | no n.link
}