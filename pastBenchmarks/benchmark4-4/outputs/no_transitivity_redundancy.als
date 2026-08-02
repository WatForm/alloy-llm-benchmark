sig N {
  suivant: set N
}

fact {
  no iden & ^suivant
  no iden & ^suivant
  no suivant & suivant.suivant.*suivant
}