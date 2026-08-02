sig Father {}

sig Mother {}

sig Child {
  father: one Father,
  mother: one Mother,
  brothers: set Child
}

fact BrotherReciprocalForSameParents {
  all c1, c2: Child |
    c2 in c1.brothers and c1.father = c2.father and c1.mother = c2.mother implies c1 in c2.brothers
}

fact NoSelfBrother {
  all c: Child | c not in c.brothers
}