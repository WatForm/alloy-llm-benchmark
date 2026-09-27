sig N {
  suivant: set N
} {
  no iden & ^suivant
  no (^suivant & suivant)
}

pred Case1[N1, N2, N3: N] {
  N1->N2 in suivant
  N2->N3 in suivant
}

run { some disj N1, N2, N3: N | Case1[N1, N2, N3] } for exactly 3 N

pred CounterCase1[N1, N2, N3: N] {
  Case1[N1, N2, N3]
  no N1->N3 & suivant
}

run { some disj N1, N2, N3: N | CounterCase1[N1, N2, N3] } for exactly 3 N expect 0

pred Case2[N1, N2, N3, N4: N] {
  N1->N2 in suivant
  N2->N3 in suivant
  N3->N4 in suivant
}

run { some disj N1, N2, N3, N4: N | Case2[N1, N2, N3, N4] } for exactly 4 N

pred CounterCase2[N1, N2, N3, N4: N] {
  Case2[N1, N2, N3, N4]
  no N1->N4 & suivant
}

run { some disj N1, N2, N3, N4: N | CounterCase2[N1, N2, N3, N4] } for exactly 4 N expect 0