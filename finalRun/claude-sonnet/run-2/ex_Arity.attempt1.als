sig A, B, C {}

sig r in A -> B -> C {}

fact {
  all a: A | some a.r
}