pred show[r: univ -> univ] {
  some r
  all x, y, z: univ | (x->y in r and y->z in r) implies x->z in r
  no iden & r
  all x, y: univ | x->y in r implies y->x in r
  all x: univ | lone x.r
  all y: univ | lone r.y
  all x: univ | some x.r
  all y: univ | some r.y
}

run show for 4

assert ReformulateNonEmptinessOK {
  all r: univ -> univ |
    (some r) iff (some x, y: univ | x->y in r)
}

check ReformulateNonEmptinessOK for 4