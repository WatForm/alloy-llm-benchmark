sig N {
  suivant: set N
}

fact Acyclic {
  no iden & ^suivant
}

fact NoTransitiveRedundancy {
  no (suivant & suivant.suivant)
}

pred Case1[N1, N2, N3: N] {
  disj[N1, N2, N3]
  N2 in N1.suivant
  N3 in N2.suivant
}

run { some N1, N2, N3: N | Case1[N1, N2, N3] } for exactly 3 N expect 1

pred CounterCase1[N1, N2, N3: N] {
  Case1[N1, N2, N3]
  N3 not in N1.suivant
}

run { some N1, N2, N3: N | CounterCase1[N1, N2, N3] } for exactly 3 N expect 0

pred Case2[N1, N2, N3, N4: N] {
  disj[N1, N2, N3, N4]
  N2 in N1.suivant
  N3 in N2.suivant
  N4 in N3.suivant
}

run { some N1, N2, N3, N4: N | Case2[N1, N2, N3, N4] } for exactly 4 N expect 1

pred CounterCase2[N1, N2, N3, N4: N] {
  Case2[N1, N2, N3, N4]
  N4 not in N1.suivant
}

run { some N1, N2, N3, N4: N | CounterCase2[N1, N2, N3, N4] } for exactly 4 N expect 0