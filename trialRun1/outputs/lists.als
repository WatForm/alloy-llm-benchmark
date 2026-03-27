sig Thing {}

abstract sig List {
  equivTo: set List,
  prefixes: set List
}

sig NonEmptyList extends List {
  car: one Thing,
  cdr: one List
}

sig EmptyList extends List {}

fact {
  Thing in NonEmptyList.car
}

pred isFinite[L: List] {
  some e: EmptyList | e in L.*cdr
}

fact {
  all l: List | isFinite[l]
}

fact equivalence {
  all a, b: List |
    b in a.equivTo iff (
      (a in EmptyList and b in EmptyList) or
      (a in NonEmptyList and b in NonEmptyList and
        a.car = b.car and
        b.cdr in a.cdr.equivTo and
        #(a.*cdr) = #(b.*cdr))
    )
}

assert reflexive {
  all l: List | l in l.equivTo
}

assert symmetric {
  all a, b: List | b in a.equivTo implies a in b.equivTo
}

assert empties {
  all a, b: EmptyList | b in a.equivTo
}

fact prefix {
  all a, b: List |
    b in a.prefixes iff (
      a in NonEmptyList and b in NonEmptyList and
      a.car = b.car and
      a.cdr in b.cdr.prefixes and
      #(a.*cdr) < #(b.*cdr)
    )
}

pred show {
  some a, b: NonEmptyList |
    a != b and
    b in a.prefixes
}

run show for 4 expect 1