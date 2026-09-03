open util/relation

sig N {
  suivant: set N
}

fact {
  acyclic[suivant]
  no suivant & suivant.^suivant
}