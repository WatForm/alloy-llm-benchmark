sig N {
  suivant: set N
}

fact {
  no n: N | n in n.^suivant
}

fact {
  no n: N | n in n.^suivant
}

fact {
  no n1, n2: N | (n1->n2 in suivant) and (n1->n2 in (^suivant - suivant))
}