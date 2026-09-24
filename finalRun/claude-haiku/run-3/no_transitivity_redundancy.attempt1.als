sig N {
  suivant: set N
}

fact {
  acyclic[suivant]
}

fact {
  all n1, n2: n1 -> n2 in suivant implies n2 not in (n1.^suivant - n1.suivant)
}