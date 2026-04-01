abstract sig List {
  equivTo: set List,
  prefixes: set List
}

sig Thing {}

sig NonEmptyList extends List {
  car: one Thing,
  cdr: one List
}

sig EmptyList extends List {}

fact NoStrayThings {
  Thing = NonEmptyList.car
}

pred isFinite[l: List] {
  some e: EmptyList | e in l.*cdr
}

fact finite {
  all l: List | isFinite[l]
}

fun len[l: List]: one Int {
  #{x: NonEmptyList | x in l.*cdr}
}

fact Equivalence {
  all e1, e2: EmptyList | e2 in e1.equivTo
  all e: EmptyList, n: NonEmptyList | n not in e.equivTo and e not in n.equivTo
  all a, b: NonEmptyList |
    (b in a.equivTo) iff
      (a.car = b.car and b.cdr in a.cdr.equivTo and len[a] = len[b])
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

fact Prefixes {
  all e: EmptyList, l: List | e in l.prefixes
  all a: NonEmptyList, b: List |
    (a in b.prefixes) iff
      (some nb: NonEmptyList |
        b = nb and
        a.car = nb.car and
        a.cdr in nb.cdr.prefixes and
        len[a] < len[nb])
}

pred show {
  some disj a, b: NonEmptyList | b in a.prefixes
}

check reflexive for 4
check symmetric for 4
check empties for 4
run show for 4 but 4 Int