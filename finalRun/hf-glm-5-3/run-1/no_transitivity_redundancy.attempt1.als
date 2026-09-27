sig N {
  suivant : set N
}

fact acyclic {
  all n : N | n not in n.^suivant
}

fact noMultiStepReach {
  all n : N | no n.suivant & n.suivant.^suivant
}