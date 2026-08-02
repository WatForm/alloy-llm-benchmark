open util/relation

sig N { suivant: set N }

fact
{
  -- only acyclic relation
  acyclic[suivant, N]
  -- constraint to check against examples and counter examples
  no suivant.^suivant & suivant
}

pred Case1[N1, N2, N3: N]
{
  N1->N2 in suivant
  N2->N3 in suivant
}
Case1: run Case1 for exactly 3 N expect 1

pred CounterCase1[N1, N2, N3: N]
{
	Case1[N1, N2, N3]
  N1->N3 in suivant
}
CounterCase1: run CounterCase1 for exactly 3 N expect 0


pred Case2[N1, N2, N3, N4: N]
{
  N1->N2 in suivant
  N2->N3 in suivant
  N3->N4 in suivant
}
Case2: run Case2 for exactly 4 N expect 1

pred CounterCase2[N1, N2, N3, N4: N]
{
	Case2[N1, N2, N3, N4]
  N1->N4 in suivant
}
CounterCase2: run CounterCase2 for exactly 4 N expect 0

