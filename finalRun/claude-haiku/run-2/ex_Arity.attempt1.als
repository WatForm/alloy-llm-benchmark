sig A, B, C {}

r: A -> B -> C

fact {
  all a: A | some b: B, c: C | r[a, b, c]
}