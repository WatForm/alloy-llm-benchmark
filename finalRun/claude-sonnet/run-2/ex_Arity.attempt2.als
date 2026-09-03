sig A, B, C {}

sig A2 {} 

fact {
  no A & B
  no A & C
  no B & C
}

one sig r {
  map: A -> B -> C
} {
  all a: A | some b: B, c: C | a->b->c in map
  all a: A | one b1: B, c1: C, b2: B, c2: C | (a->b1->c1 in map and a->b2->c2 in map) implies (b1 = b2 and c1 = c2)
}