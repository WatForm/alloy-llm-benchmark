sig N {
  suivant: set N
} {
  no iden & ^suivant
  no (suivant.suivant & suivant)
}