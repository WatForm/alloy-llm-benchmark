open util/relation

sig N {
  suivant: set N
}

fact acyclicOverN {
  no n: N | n in n.^suivant
}

fact suivantAcyclic {
  acyclic[suivant, N]
}

fact noOneStepAndMoreSteps {
  no n: N | some (n.suivant & n.suivant.^suivant)
}