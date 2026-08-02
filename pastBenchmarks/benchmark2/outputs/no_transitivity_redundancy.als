sig N {
  suivant: set N
}

fact Acyclic {
  no iden & ^suivant
}

fact NoTransitivityRedundancy {
  no (suivant.suivant & suivant)
}