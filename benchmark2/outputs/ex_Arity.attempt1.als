sig B {}
sig C {}

sig A {
  r: B -> C
}

fact {
  all a: A | all b: B | one a.r[b]
}