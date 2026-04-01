pred isTree[r: univ -> univ] {
  some root: univ |
    no root.~r and
    all n: univ - root | one n.~r and
    univ in root.*r
}

pred spans[r1, r2: univ -> univ] {
  r1 in r2 + ~r2
}

pred show[r, t1, t2: univ -> univ] {
  spans[t1, r]
  isTree[t1]
  spans[t2, r]
  isTree[t2]
  t1 != t2
}

run show for 3