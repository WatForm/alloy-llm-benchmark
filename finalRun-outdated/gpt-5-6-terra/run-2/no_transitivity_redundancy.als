open util/relation

sig N {
  suivant: set N
}

fact {
  acyclic[suivant, N]
  acyclic[suivant, univ]
  no suivant & suivant.^suivant
}