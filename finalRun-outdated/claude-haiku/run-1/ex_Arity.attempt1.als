sig A {}
sig B {}
sig C {}

r: A -> B -> C

fact {
  all a: A, b: B | one c: C | a -> b -> c in r
}