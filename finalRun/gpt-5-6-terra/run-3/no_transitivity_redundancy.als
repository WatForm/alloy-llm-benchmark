sig N {
  suivant: set N
}

fact {
  no n: N | n in n.^suivant
  no iden & ^suivant
  all n, m: N |
    m in n.suivant implies m not in n.suivant.^suivant
}