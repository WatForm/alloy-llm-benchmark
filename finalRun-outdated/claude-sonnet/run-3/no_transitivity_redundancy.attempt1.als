sig N {
  suivant: set N
}

fact AcyclicOverN {
  no n: N | n in n.^suivant
}

fact Acyclic {
  no n: N | n in n.^suivant
}

fact NoOneAndMultiStep {
  all n: N | no (n.suivant & n.(suivant.^suivant))
}