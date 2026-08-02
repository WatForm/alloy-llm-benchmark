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
  no n, m: N | m in n.suivant and m in n.(suivant.suivant.^suivant)
}