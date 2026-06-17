sig N {
  suivant: set N
}

sig Node in N {}

fact {
  no n: N | n in n.^suivant
}

fact {
  no iden & ^suivant
}

fact {
  no n, m: Node | m in n.suivant and m in n.(suivant.suivant.suivant.*suivant)
}